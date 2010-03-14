package Promulger::Config;

my $config;
sub config {
  my $class = shift;
  if(my $new = shift) {
    $config = $new;
  }
  return $config;
};

'http://reductivelabs.com/products/puppet/';
