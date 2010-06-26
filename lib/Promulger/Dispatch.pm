package Promulger::Dispatch;
use strict;
use warnings;

use Email::Address;
use Email::Simple;
# XXX allow the user to specify their own Email::Sender::Transport -- apeiron,
# 2010-03-13 
use Email::Sender::Simple qw(sendmail);
# XXX not yet -- apeiron, 2010-06-25 
#use Mail::Verp;

use Promulger::Config;

# XXX no bounce parsing yet -- apeiron, 2010-03-13 
sub dispatch {
  my ($message) = @_;
  my $config = Promulger::Config->config;

  my $email = Email::Simple->new($message);
  my $recipient = $email->header('To');
  my $local_user = user_for_address($recipient);
  my $sender = $email->header('From');
  my $subject = $email->header('Subject');

  my $list = Promulger::List->resolve($local_user);
  unless($list) {
    reject($recipient, $sender);
    return;
  }

  if($local_user =~ /-request$/) {
    handle_request($list, $sender, $local_user, $subject, $config);
    return;
  }

  # they don't have a request for us, so they want to post a message
  post_message($list, $email, $config);
  return;
}

sub handle_request {
  my ($list, $sender, $recipient, $subject) = @_;

  my $sender_address = bare_address($sender);
  if($subject =~ /^\s*subscribe/i) {
    $list->subscribe($sender_address) 
      or already_subscribed($list, $recipient, $sender_address);
  } elsif($subject =~ /^\s*unsubscribe/i) {
    $list->unsubscribe($sender_address) 
      or not_subscribed($list, $recipient, $sender_address);
  }
}

sub post_message {
  my ($list, $email, $config) = @_;

  my $sender = $email->header('From');
  my $sender_address = bare_address($sender);
  my $recipient = $email->header('To');

  unless($list->accept_posts_from($sender_address) && $list->active) {
    reject($recipient, $sender);
    return;
  }

  # they're allowed to post (subscribed or not), the list is active. let's do
  # this thing.

  # XXX no MIME or other fancy handling for now -- apeiron, 2010-03-13 
  my $body = $email->body;
  for my $subscriber (keys %{$list->subscribers}) {
    #my $verped_from = Mail::Verp->encode($recipient, $subscriber);
    # XXX we let the MTA create the message-id for us for now -- apeiron,
    # 2010-03-13 
    my $new_message = Email::Simple->create(
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
    sendmail($new_message);
  }
}

# XXX make this actually not suck -- apeiron, 2010-03-13 
sub reject {
  my ($recipient, $sender) = @_;
  my $email = Email::Simple->create(
    header => [
      From => $recipient,
      To   => $sender,
      Subject => 'Rejected',
    ],
    body => <<BODY,
Sorry, your message to $recipient has been denied.
BODY
  );
  sendmail($email);
}

sub not_subscribed {
  my ($list, $recipient, $sender) = @_;
  my $email = Email::Simple->create(
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
  sendmail($email);
}

sub already_subscribed {
  my ($list, $recipient, $sender) = @_;
  my $email = Email::Simple->create(
    header => [
      From => $recipient,
      To   => $sender,
      Subject => 'Already subscribed',
    ],
    body => <<BODY,
Sorry, you are already subscribed to $list.
BODY
  );
  sendmail($email);
}

sub bare_address {
  my ($full_addr) = @_;
  my ($addr_obj) = Email::Address->parse($full_addr);
  return $addr_obj->address;
}

sub user_for_address {
  my ($full_addr) = @_;
  my ($addr_obj) = Email::Address->parse($full_addr);
  return $addr_obj->user;
}

'http://www.shadowcat.co.uk/blog/matt-s-trout/oh-subdispatch-oh-subdispatch/';
