package Promulger::Config;
use strict;
use warnings;

use Config::General;

my $config;

my @NECESSARY = qw/aliases list_home/;

sub load_config {
  my ($class, $config_file) = @_;
  $config = { Config::General->new($config_file)->getall };
  $config->{config_file} = $config_file;

  $class->validate_config($config);

  return $config;
};

sub config {
  die "No configuration loaded" unless $config;
  return $config;
}

sub validate_config {
  my ($class, $config) = @_;
  for my $nec (@NECESSARY) {
    die "Required key '${nec}' missing in " . $config->{config_file}
      unless $config->{$nec};
  }

  die "cannot read aliases file " . $config->{aliases}
    unless -r $config->{aliases};
  die "cannot write to list home " . $config->{list_home}
    unless -w $config->{list_home};
}

'http://reductivelabs.com/products/puppet/';
