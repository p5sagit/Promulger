package Promulger::Schema;
use strict;
use warnings;

use KiokuDB;

my $kdb;
my $scope;

sub connect {
  my($self, $dsn) = @_;
  $kdb = KiokuDB->connect(
    $dsn,
    create => 1,
  );
  $scope = $kdb->new_scope;
}

sub store {
  my($self, $obj) = @_;
  $kdb->store($obj);
}

1;
