package Promulger::List;
use Moose;

use Carp;
use Dir::Self;
use File::Slurp qw/read_file write_file/;

has listname => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

has active => (
  is       => 'rw',
  isa      => 'Bool',
  required => 1,
  default  => 1,
);

sub setup_aliases_at {
  my($self, $config) = @_;
  my $name = $self->listname;
  my @current_contents = read_file $config->{aliases};
  my @aliases = ($name, "${name}-request");
  for my $alias (@aliases) {
    if(grep { $_ =~ /^${alias}:/ } @current_contents) {
      croak "${alias} already in $config->{aliases}";
    }
    push @current_contents, qq(${alias}: "|$config->{bin_root}/pmg msg"\n);
  }
  write_file $config->{aliases}, @current_contents;
}

1;
