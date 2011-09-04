package App::Promulger::Command;
use strict;
use warnings;

use App::Cmd::Setup -command;

use Promulger::Config;

sub validate_args {
  my ($self, $opt, $args) = @_;
  my $cf = $self->app->global_options->{config};

  unless(-e $cf) {
    die "Config file $cf doesn't exist\n";
  }
  unless(-f $cf) {
    die "Config file $cf not a file\n";
  }
  unless(-r $cf) {
    die "Config file $cf not readable\n";
  }

  Promulger::Config->load_config($cf);
}

1;
