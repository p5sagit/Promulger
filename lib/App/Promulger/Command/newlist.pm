package App::Promulger::Command::newlist;
use strict;
use warnings;

use App::Promulger -command;
use Promulger::List;
use Config::General;

sub abstract {
  return "creates a new list";
}

sub opt_spec {
  return (
    [ "config|c=s", "configuration file", { required => 1 } ],
  );
}

sub validate_args {
  my ($self, $opt, $args) = @_;
  my $cf = $opt->{config};

  unless(-e $cf) {
    die "Config file $cf doesn't exist\n";
  }
  unless(-f $cf) {
    die "Config file $cf not a file\n";
  }
  unless(-r $cf) {
    die "Config file $cf not readable\n";
  }

  $self->{config} = { Config::General->new($cf)->getall };
  $self->{config}{config_file} = $cf;
}


sub run {
  my ($self, $opt, $args) = @_;
  @$args == 1 or die "pmg newlist needs a list name\n";
  my $list = Promulger::List->new(
    listname  => $args->[0],
  );
  $list->setup($self->{config});
}

1;
