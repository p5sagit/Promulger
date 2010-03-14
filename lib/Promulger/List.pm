package Promulger::List;
use Moose;
use MooseX::Storage;

use autodie ':all';
use Carp;
use Path::Class;
use Fcntl ':flock';

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

with Storage (
  format => 'JSON',
  io     => 'File',
);

sub resolve {}

sub subscribe {}

sub unsubscribe {}

sub accept_posts_from {}

sub setup {
  my($self, $config) = @_;
  my $name = $self->listname;
  my $path = file($config->{list_home}, $name . ".list");
  eval {
    __PACKAGE__->load($path->stringify);
  };
  croak "${name} already a known list" unless $@;

  open my $fh, '+<', $config->{aliases};
  flock $fh, LOCK_EX;
  my @current_contents = <$fh>;
  my @aliases = ($name, "${name}-request");
  for my $alias (@aliases) {
    if(grep { /^${alias}:/ } @current_contents) {
      croak "${alias} already in $config->{aliases}";
    }
    push @current_contents, 
      qq(${alias}: "|$config->{bin_root}/pmg msg -c $config->{config_file}"\n);
  }
  $self->store($path->stringify);
  print $fh @current_contents;
  flock $fh, LOCK_UN;
}

1;
