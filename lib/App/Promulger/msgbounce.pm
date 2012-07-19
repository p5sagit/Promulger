package App::Promulger::Command::msgbounce;
use strictures 1;
use autodie;

use App::Promulger -command;
use parent 'App::Promulger::Command';
use Promulger::Dispatch;

sub abstract {
  return "handle a potential bounce";
}

sub run {
  my ($self, $opt, $args) = @_;
  my $message = do {
    local $/;
    <STDIN>
  };
  Promulger::Dispatch->new->handle_bounce($message);
}

1;
