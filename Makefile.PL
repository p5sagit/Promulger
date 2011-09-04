use inc::Module::Install;
use strict;
use warnings;

name 'Promulger';
all_from 'lib/Promulger.pm';

requires 'App::Cmd';
requires 'Carp';
requires 'Config::General';
requires 'Email::Address';
requires 'Email::MIME';
requires 'Email::Sender';
requires 'Fcntl';
requires 'File::Slurp';
requires 'IPC::Run3';
requires 'Method::Signatures::Simple';
requires 'Moo';
requires 'Path::Class';
requires 'Tie::File';
requires 'Try::Tiny';
requires 'Web::Simple';
requires 'autodie';
requires 'parent';
requires 'strictures';

install_script (qw|
  script/pmg
  script/pmg-web
  script/mm2pmg
|);

resources 'IRC'         => 'irc://irc.perl.org/#promulger';
resources 'license'     => 'http://dev.perl.org/licenses/';
resources 'repository'  => 'git://git.shadowcat.co.uk/p5sagit/Promulger.git';

auto_install();

WriteAll();

