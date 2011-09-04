package Promulger::List;
use Moo;
use autodie;

use autodie ':all';
use Carp;
use Path::Class;
use Fcntl ':flock';
use Tie::File;
use File::Slurp qw/read_file write_file/;
use Data::Dumper;
use Try::Tiny;
use FindBin qw($Bin);
$Data::Dumper::Purity = 1;

use Promulger::Config;

has listname => (
  is       => 'ro',
  isa      => sub { $_[0] =~ /^\w+$/ or die "listname must be a string" },
  required => 1,
);

has active => (
  is       => 'rw',
  isa      => sub { ($_[0] == 0 || $_[0] == 1) or die "active must be 0 or 1" },
  required => 1,
  default  => sub { 1 },
);

has subscribers => (
  is       => 'rw',
  isa      => sub { ref $_[0] eq 'HASH' or die "subscribers must be a hashref" },
  required => 1,
  default  => sub { {} },
);

sub resolve {
  my ($self, $proto) = @_;
  $proto =~ s/-request$//;
  my $path = find_path_for($proto);
  my $maybe_list;
  try {
    $maybe_list = __PACKAGE__->load($path->stringify);
  } catch {
    die "oh noes: $_";
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

  my $tie = tie my @aliases, 'Tie::File', $config->{aliases} 
    or die "cannot tie " . $config->{aliases} . ": $!";
  $tie->flock;
  my @list_aliases = ($name, "${name}-request");

  for my $list_alias (@list_aliases) {
    if(grep { /^${list_alias}:/ } @aliases) {
      croak "${list_alias} already in $config->{aliases}";
    }
    push @aliases, 
      qq(${list_alias}: "|$Bin msg -c $config->{config_file}"\n);
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

sub store {
  my ($self, $path) = @_;
  my $dumped = 'do { my '. Dumper($self) . '; $VAR1; }';
  write_file($path, $dumped);
}

sub load {
  my ($class, $path) = @_;
  return do $path;
}

sub get_lists {
  my ($self) = @_;
  my $config = Promulger::Config->config;
  my @lists = map { $_->basename}
              grep { -f } dir($config->{list_home})->children;
  s/\.list//g for @lists;
  return @lists;
}

'http://mitpress.mit.edu/sicp/';
