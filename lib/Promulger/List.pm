package Promulger::List;
use Moose;
use MooseX::Storage;

use autodie ':all';
use Carp;
use Path::Class;
use Fcntl ':flock';
use Tie::File;

use Promulger::Config;

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

has subscribers => (
  is       => 'rw',
  isa      => 'HashRef',
  required => 1,
  default  => sub { {} },
);

with Storage (
  format => 'JSON',
  io     => 'File',
);

sub resolve {
  my ($self, $proto) = @_;
  $proto =~ s/-request$//;
  my $path = find_path_for($proto);
  my $maybe_list;
  eval {
    $maybe_list = __PACKAGE__->load($path->stringify);
  };
  return $maybe_list;
}

sub subscribe {
  my ($self, $new) = @_;
  return if $self->subscribers->{$new};
  $self->subscribers->{$new} = 1;
  $self->store(find_path_for($self->listname)->stringify);
  return 1;
}

sub unsubscribe {
  my ($self, $ex) = @_;
  return unless exists $self->subscribers->{$ex};
  delete $self->subscribers->{$ex};
  $self->store(find_path_for($self->listname)->stringify);
  return 1;
}

# XXX implement ACLs and other shinies -- apeiron, 2010-03-13 
sub accept_posts_from {
  my ($self, $sender) = @_;
  return grep { $sender eq $_ } keys %{$self->subscribers};
}

sub setup {
  my ($self) = @_;
  my $config = Promulger::Config->config;
  my $name = $self->listname;
  croak "${name} already a known list" if $self->resolve($name);
  my $path = find_path_for($name);

  my $tie = tie my @aliases, 'Tie::File', $config->{aliases};
  $tie->flock;
  my @list_aliases = ($name, "${name}-request");

  for my $list_alias (@list_aliases) {
    if(grep { /^${list_alias}:/ } @aliases) {
      croak "${list_alias} already in $config->{aliases}";
    }
    push @aliases, 
      qq(${list_alias}: "|$config->{bin_root}/pmg msg -c $config->{config_file}"\n);
  }

  $self->store($path->stringify);
}

sub delete {
  my ($self) = @_;
  my $config = Promulger::Config->config;
  my $name = $self->listname;

  my $tie = tie my @aliases, 'Tie::File', $config->{aliases};
  $tie->flock;

  my @list_aliases = ($name, "${name}-request");
  @aliases = grep {
    $_ !~ /^$list_aliases[0]:/ &&
    $_ !~ /^$list_aliases[1]:/
  } @aliases;

  unlink find_path_for($self->listname)->stringify;
}

sub find_path_for {
  my ($proto) = @_;
  my $path = file(Promulger::Config->config->{list_home}, $proto . ".list");
  return $path;
}

'http://mitpress.mit.edu/sicp/';
