package Promulger::Dispatch;
use strict;
use warnings;

use Email::Simple;
# XXX allow the user to specify their own Email::Sender::Transport -- apeiron,
# 2010-03-13 
use Email::Sender::Simple qw(sendmail);
use Mail::Verp;

use Promulger::Config;

# XXX no bounce parsing yet -- apeiron, 2010-03-13 
sub dispatch {
  my($message) = @_;
  my $config = Promulger::Config->config;

  my $email = Email::Simple->new($message);
  my $recipient = $email->header('To');
  my $sender = $email->header('From');
  my $subject = $email->header('Subject');

  my $list = Promulger::List->resolve($recipient);
  unless($list) {
    reject($recipient, $sender);
  }

  if($recipient =~ /-request$/) {
    handle_request($list, $sender, $recipient, $subject, $config);
  }

  # they don't have a request for us, so they want to post a message
  post_message($list, $email, $config);
}

sub handle_request {
  my ($list, $sender, $recipient, $subject) = @_;

  if($subject =~ /^subscribe/i) {
    $list->subscribe($sender) 
      or already_subscribed($list, $sender);
  } elsif($subject =~ /^unsubscribe/i) {
    $list->unsubscribe($sender) 
      or not_subscribed($list, $sender);
  }
}

sub post_message {
  my($list, $email, $config) = @_;

  my $sender = $email->header('From');
  my $recipient = $email->header('To');

  reject($recipient, $sender) unless $list->accept_posts_from($sender);
  reject($recipient, $sender) unless $list->active;

  # they're allowed to post (subscribed or not), the list is active. let's do
  # this thing.

  # XXX no MIME or other fancy handling for now -- apeiron, 2010-03-13 
  my $body = $email->body;
  for my $subscriber ($list->subscribers) {
    my $verped_from = Mail::Verp->encode($list->address, $subscriber);
    # XXX we let the MTA create the message-id for us for now -- apeiron,
    # 2010-03-13 
    my $new_message = Email::Simple->create(
      header => [
        From => $verped_from,
        To   => $subscriber,
        Subject => $email->subject,
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
  my($recipient, $sender) = @_;
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
  my($list, $sender) = @_;
  my $list_address = $list->address;
  my $email = Email::Simple->create(
    header => [
      From => $list->admin_address,
      To   => $sender,
      Subject => 'Not subscribed',
    ],
    body => <<BODY,
Sorry, you are not subscribed to $list_address;
BODY
  );
  sendmail($email);
}

sub already_subscribed {
  my($list, $sender) = @_;
  my $list_address = $list->address;
  my $email = Email::Simple->create(
    header => [
      From => $list->admin_address,
      To   => $sender,
      Subject => 'Already subscribed',
    ],
    body => <<BODY,
Sorry, you are already subscribed to $list_address;
BODY
  );
  sendmail($email);
}

'http://www.shadowcat.co.uk/blog/matt-s-trout/oh-subdispatch-oh-subdispatch/';
