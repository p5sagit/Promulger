package Promulger::Dispatch;
use strict;
use warnings;

use Email::Simple;
# XXX allow the user to specify their own Email::Sender::Transport -- apeiron,
# 2010-03-13 
use Email::Sender::Simple qw(sendmail);
use Mail::Verp;

sub dispatch {
  my($message, $config) = @_;

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
  my ($list, $sender, $recipient, $subject, $config) = @_;

  if($subject =~ /^subscribe/i) {
    $list->subscribe($sender, $config) 
      or already_subscribed($list, $sender, $config);
  } elsif($subject =~ /^unsubscribe/i) {
    $list->unsubscribe($sender, $config) 
      or not_subscribed($list, $sender, $config);
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

sub reject {}
sub not_subscribed {}
sub already_subscribed {}

'http://www.shadowcat.co.uk/blog/matt-s-trout/oh-subdispatch-oh-subdispatch/';
