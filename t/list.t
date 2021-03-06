#!/usr/bin/perl
use strictures 1;
use autodie;
use Test::Most;

use File::Temp ();
use Path::Class;

use aliased 'Promulger::List';
# no alias here so we don't risk colliding with perl's own Config.pm -- apeiron,
# 2011-09-04 
use Promulger::Config;

{
  my $raw_pmg_home = File::Temp->newdir;
  my $pmg_home = dir($raw_pmg_home);

  my $aliases = $pmg_home->file('aliases');
  my $aliases_fh = $aliases->openw;
  close $aliases_fh;

  my $list_home = $pmg_home->subdir('lists');
  $list_home->mkpath;

  my $config_file = $pmg_home->file('pmg.conf');
  my $config_fh = $config_file->openw;
  print $config_fh <<"CONFIG";
mailer    = Test
aliases   = $aliases
list_home = $list_home
CONFIG

  close $config_fh;
  my $config = Promulger::Config->load_config($config_file);
  my $list;
  lives_ok { $list = List->new(
    listname  => 'foo',
    active => 1,
    subscribers => {},
  ) } "can create a list";
  lives_ok { $list->setup } "can setup a list";

  cmp_ok(
    $list->listname, 
    'eq', 
    'foo', 
    "list has same listname as one we specified",
  );
  cmp_ok(
    $list->active,
    '==',
    1,
    "list is active, like the one we specified",
  );
  cmp_deeply(
    $list->subscribers,
    {},
    "list has no subscribers for now, like the one we specified",
  );

  my $resolved_list = List->resolve('foo');
  cmp_ok(
    $resolved_list->listname, 
    'eq', 
    'foo', 
    "resolved list has same listname as one we created",
  );
  cmp_ok(
    $resolved_list->active,
    '==',
    1,
    "resolved list is active, like the one we created",
  );
  cmp_deeply(
    $resolved_list->subscribers,
    {},
    "resolved list has no subscribers for now, like the one we created",
  );

  lives_ok { $list->subscribe('foo@example.com') } "can subscribe someone";
  $list = List->resolve('foo');
  cmp_deeply(
    $list->subscribers,
    {
      'foo@example.com' => 1,
    },
    "subscribing a user adds them to the serialized data",
  );
  lives_ok { $list->unsubscribe('foo@example.com') } "can unsubscribe someone";
  $list = List->resolve('foo');
  cmp_deeply(
    $list->subscribers,
    { },
    "unsubscribing a user removes them from the serialized data",
  );
}

done_testing;
