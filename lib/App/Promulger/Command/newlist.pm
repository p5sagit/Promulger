package App::Promulger::Command::newlist;
use strictures 1;
use autodie;

use App::Promulger -command;
use Promulger::List;

sub abstract {
  return "creates a new list";
}

sub run {
  my ($self, $opt, $args) = @_;
  @$args == 1 or die "pmg newlist needs a list name\n";
  
  my $listname = $args->[0];
  my $list = Promulger::List->new(
    listname  => $listname,
    active => 1,
    subscribers => {},
  );
  $list->setup;
}

'Make it so';
