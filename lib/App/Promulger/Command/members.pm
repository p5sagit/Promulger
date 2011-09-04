package App::Promulger::Command::members;
use strictures 1;
use autodie;

use App::Promulger -command;
use Promulger::List;

sub abstract {
  return "shows the subscribers to a list";
}

sub run {
  my ($self, $opt, $args) = @_;
  @$args >= 1 or die "pmg members needs a list name\n";
  
  my $listname = $args->[0];
  my $list = Promulger::List->resolve($listname);

  if(!$list) {
    die "$listname doesn't exist\n";
  }

  for my $subscriber (keys %{ $list->subscribers } ) {
    print "$subscriber\n";
  }
}

'Make it so';
