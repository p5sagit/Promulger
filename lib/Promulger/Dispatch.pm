package Promulger::Dispatch;
use Moo;
use Method::Signatures::Simple;
use autodie ':all';
use Scalar::Util 'blessed';

use Email::Address;
use Email::MIME;
use Email::Sender::Simple ();
# XXX not yet -- apeiron, 2010-06-25 
#use Mail::Verp;

use Promulger::Config;

has transport => (
  is => 'rw',
  isa => sub {
    my $proto = $_[0];
    blessed $proto and
    $proto->can('does') and
    $proto->does('Email::Sender::Transport') 
      or die "transport must do Email::Sender::Transport role";
  },
  default => sub {
    my $config = Promulger::Config->config;
    my $class;
    if($class = $config->{mailer}) {
      if($class !~ /::/) {
        $class = "Email::Sender::Transport::${class}";
      }
    } else {
      $class = 'Email::Sender::Transport::Sendmail';
    }
    Class::MOP::load_class($class);
    $class->new;
  },
);

# XXX no bounce parsing yet -- apeiron, 2010-03-13 
method dispatch ($message) {
  my $config = Promulger::Config->config;

  my $email = Email::MIME->new($message);
  my $recipient = $email->header('To');
  my $local_user = $self->user_for_address($recipient);
  my $sender = $email->header('From');
  my $subject = $email->header('Subject');

  my $list = Promulger::List->resolve($local_user);
  unless($list) {
    $self->reject($recipient, $sender);
    return;
  }

  if($local_user =~ /-request$/) {
    $self->handle_request($list, $sender, $local_user, $subject, $config);
    return;
  }

  # they don't have a request for us, so they want to post a message
  $self->post_message($list, $email, $config);
  return;
}

method handle_request ($list, $sender, $recipient, $subject) {
  my $sender_address = $self->bare_address($sender);
  if($subject =~ /^\s*subscribe/i) {
    $list->subscribe($sender_address) 
      or $self->already_subscribed($list, $recipient, $sender_address);
  } elsif($subject =~ /^\s*unsubscribe/i) {
    $list->unsubscribe($sender_address) 
      or $self->not_subscribed($list, $recipient, $sender_address);
  }
}

method post_message ($list, $email, $config) {
  my $sender = $email->header('From');
  my $sender_address = $self->bare_address($sender);
  my $recipient = $email->header('To');

  unless($list->accept_posts_from($sender_address) && $list->active) {
    $self->reject($recipient, $sender);
    return;
  }

  # XXX no MIME or other fancy handling for now -- apeiron, 2010-03-13 
  my $body = $email->body_str;
  for my $subscriber (keys %{$list->subscribers}) {
    # my $verped_from = Mail::Verp->encode($recipient, $subscriber);

    # XXX we let the MTA create the message-id for us for now -- apeiron,
    # 2010-03-13 
    my $new_message = Email::MIME->create(
      header => [
        From       => $sender_address,
        To         => $subscriber,
        Subject    => $email->header('Subject'),
        'Reply-to' => $recipient,
      ],
      body => $body,
    );
    # XXX no queuing or job distribution for now beyond what the MTA provides
    # -- apeiron, 2010-03-13 
    $self->send_message($new_message);
  }
}

method send_message ($message) {
  Email::Sender::Simple::sendmail(
    $message,
    {
      transport => $self->transport,
    }
  );
}

# XXX make this actually not suck -- apeiron, 2010-03-13 
method reject ($recipient, $sender) {
  my $email = Email::MIME->create(
    header => [
      From => $recipient,
      To   => $sender,
      Subject => 'Rejected',
    ],
    body => <<BODY,
Sorry, your message to $recipient has been denied.
BODY
  );
  $self->send_message($email);
}

method not_subscribed ($list, $recipient, $sender) {
  my $email = Email::MIME->create(
    # XXX need admin address
    header => [
      From => $recipient,
      To   => $sender,
      Subject => 'Not subscribed',
    ],
    body => <<BODY,
Sorry, you are not subscribed to $list.
BODY
  );
  $self->send_message($email);
}

method already_subscribed ($list, $recipient, $sender) {
  my $email = Email::MIME->create(
    header => [
      From => $recipient,
      To   => $sender,
      Subject => 'Already subscribed',
    ],
    body => <<BODY,
Sorry, you are already subscribed to $list.
BODY
  );
  $self->send_message($email);
}

method bare_address ($full_addr) {
  my ($addr_obj) = Email::Address->parse($full_addr);
  return $addr_obj->address;
}

method user_for_address ($full_addr) {
  my ($addr_obj) = Email::Address->parse($full_addr);
  return $addr_obj->user;
}

'http://www.shadowcat.co.uk/blog/matt-s-trout/oh-subdispatch-oh-subdispatch/';
