package App::Promulger::Command::newlist;
use strict;
use warnings;

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
  );
  $list->setup;
}

'Make it so';
