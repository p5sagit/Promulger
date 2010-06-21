package Promulger;
use strict;
use warnings;

our $VERSION = '0.000001'; # 0.0.1

=pod

=head1 NAME

Promulger -- Simple, Unixy mailing list manager

=head1 SYNOPSIS

  # In a config file somewhere:
  aliases = /path/to/etc/aliases
  list_home = /path/your/mta/can/write/to/lists
  bin_root = /path/to/pmg/bin # like /usr/local/bin

  # then
  /path/to/pmg/bin/pmg newlist -c /path/to/config/pmg.conf mylist

  # then
  mail -s subscribe mylist-request@yourhost < /dev/null
  mail -s post mylist@yourhost < first_post

  # cleanup
  /path/to/pmg/bin/pmg rmlist -c /path/to/config/pmg.conf rmlist

=head1 DESCRIPTION

Promulger is a simple, lightweight mailinglist manager (mlm) that subscribes to
the Unix philosophy and aims to be sysadmin-friendly. Plaintext configuration
and data files are favored over opaque binary files. The simplest possible thing
that can work is the preferred approach. Simple algorithms, simple tools that do
one thing well. An administrator should be able to read the config files and the
data files without reading these docs and understand what's going on.

=head1 LIMITATIONS

Consider this section a TODO list.

Presently, Promulger doesn't support VERP, and as a result doesn't support
bounce parsing. It's being released to be tested on small, closed networks with
clueful admins. If fishing messages out of your MTA's queue isn't something you
feel comfortable doing, Promulger isn't for you right now.

Another thing Promulger lacks is an archive. This is coming, but in the
meantime, you're on your own. 

There's no support for the standard mailing list headers. This means that
filtering will need to work on the mailing list sender address for now. 

It's not very customizable--in fact, it has no flexibility at all.

=head1 ENVIRONMENT

Promulger doesn't read any environment variables.

=head1 AUTHOR

Chris Nehren

=head1 CONTRIBUTORS

No one, yet. Patches welcome!

=head1 COPYRIGHT

Copyright (c) 2010 Chris Nehren and the CONTRIBUTORS above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.

=cut

1;
