use inc::Module::Install;
use strict;
use warnings;

name 'Promulger';
all_from 'lib/Promulger.pm';

requires 'App::Cmd';
requires 'Carp';
requires 'Config::General';
requires 'IPC::System::Simple';
requires 'Email::Simple';
requires 'Email::Address';
requires 'Email::Sender';
requires 'Fcntl';
requires 'IPC::Run3';
# requires 'Mail::Verp'; # not yet
requires 'Moo';
requires 'Path::Class';
requires 'Tie::File';
requires 'autodie';
requires 'parent';

install_script (qw|
  script/pmg
  script/mm2pmg
|);

resources 'IRC'         => 'irc://irc.perl.org/#promulger';
resources 'license'     => 'http://dev.perl.org/licenses/';
resources 'repository'  => 'git://git.shadowcat.co.uk/p5sagit/Promulger.git';

auto_install();

WriteAll();

