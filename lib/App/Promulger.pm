package App::Promulger;
use strict;
use warnings;

use App::Cmd::Setup -app;

use Promulger::Config;

sub global_opt_spec {
  return (
    [ "config|c=s", "configuration file", { required => 1 } ],
  );
}

1;
