package Promulger::Config;
use strict;
use warnings;

use Config::General;

my $config;

sub load_config {
  my ($class, $config_file) = @_;
  $config = { Config::General->new($config_file)->getall };
  $config->{config_file} = $config_file;
  return $config;
};

sub config {
  die "No configuration loaded" unless $config;
  return $config;
}

'http://reductivelabs.com/products/puppet/';
