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
  my $list = Promulger::List->new(
    listname  => $args->[0],
  );
  $list->setup;
}

1;
