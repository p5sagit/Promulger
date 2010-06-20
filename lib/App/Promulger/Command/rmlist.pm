package App::Promulger::Command::rmlist;
use strict;
use warnings;

use App::Promulger -command;
use Promulger::List;

sub abstract {
  return "removes a list";
}

sub run {
  my ($self, $opt, $args) = @_;
  @$args == 1 or die "pmg rmlist needs a list name\n";

  my $listname = $args->[0];
  my $list = Promulger::List->resolve($listname);

  if($list) {
    $list->delete;
  } else {
    die "$listname doesn't exist\n";
  }
}

'Make it so';

