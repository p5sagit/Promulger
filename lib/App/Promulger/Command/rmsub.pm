package App::Promulger::Command::rmsub;
use strictures 1;
use autodie;

use App::Promulger -command;
use Promulger::List;

sub abstract {
  return "subscribes a user to a list";
}

sub run {
  my ($self, $opt, $args) = @_;
  @$args >= 2 or die "pmg newsub needs a list name and a departing member\n";
  
  my $listname = $args->[0];
  my $list = Promulger::List->resolve($listname);

  if(!$list) {
    die "$listname doesn't exist\n";
  }

  my $ex_sub = $args->[1];
  $list->unsubscribe($ex_sub);
}

'Make it so';
