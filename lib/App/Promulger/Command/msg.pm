package App::Promulger::Command::msg;
use strict;
use warnings;

use App::Promulger -command;
use parent 'App::Promulger::Command';
use Promulger::Dispatch;

sub abstract {
  return "interacts with a list";
}

sub run {
  my ($self, $opt, $args) = @_;
  my $message = do {
    local $/;
    <STDIN>
  };
  Promulger::Dispatch->new->dispatch($message);
}

'Engage';
