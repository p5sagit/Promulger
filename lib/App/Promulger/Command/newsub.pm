package App::Promulger::Command::newsub;
use strictures 1;
use autodie;

use App::Promulger -command;
use Promulger::List;

sub abstract {
  return "subscribes a user to a list";
}

sub run {
  my ($self, $opt, $args) = @_;
  @$args >= 1 or die "pmg newsub needs a list name\n";
  
  my $listname = $args->[0];
  my $list = Promulger::List->resolve($listname);

  if(!$list) {
    die "$listname doesn't exist\n";
  }

  if(@$args == 2) {
    # got the subscriber as an arg
    my $new_sub = $args->[1];
    $list->subscribe($new_sub);
  } else {
    # reading from stdin
    while(chomp(my $new_sub = <STDIN>)) {
      $list->subscribe($new_sub);
    }
  }
}

'Make it so';
