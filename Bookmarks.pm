#!/usr/bin/perl -w

#
# Netscape::Bookmarks -- process and manipulate Netscape bookmark files
# Kirrily 'Skud' Robert <skud@netizen.com.au>
#
# Version 0.01 1999-09-12
#
# Changelog
#
# 1999-09-12	Initial versoin
# 
# Licensing
# This module may be modified and redistributed under the same terms as
# Perl itself.
#

package Netscape::Bookmarks;

use strict;
use Carp;
use HTML::TokeParser;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter);

@EXPORT = qw(
	bookmarks_array
	bookmarks_lol
);

$VERSION = $VERSION = '0.01';

sub bookmarks_array {
	my $filename = shift;
	my $p = HTML::TokeParser->new($filename) || die "Can't open: $!";
	my @bookmarks;
	TOKEN: while (my $t = $p->get_token) {
		if ($t->[0] eq 'S' && $t->[1] eq 'A') {
			push (@bookmarks, $t->[2]->{href});
		} else {
			next TOKEN;
		}
	}
	return @bookmarks;
}

sub bookmarks_lol {
	my $filename = shift;
	my $p = HTML::TokeParser->new($filename) || die "Can't open: $!";
	my @bookmarks;
	TOKEN: while (my $t = $p->get_token) {
		if ($t->[0] eq 'S' && $t->[1] eq 'a') {
			push (@bookmarks, [
				$t->[2]->{href},
				$p->get_text,
				$t->[2]->{add_date},
				$t->[2]->{last_modified},
				$t->[2]->{last_visit}
			]);
		}
	}
	return @bookmarks;
}

1;
__END__


=head1 NAME

Netscape::Bookmarks - Process and manipulate Netscape bookmarks files

=head1 SYNOPSIS

  use Netscape::Bookmarks;
  @bookmarks = bookmarks_array($filename);
  @bookmarks = bookmarks_lol($filename);

=head1 DESCRIPTION

This module helps you process and manipulate Netscape bookmarks files.

=head2 bookmarks_array()

Returns a flat array of bookmark URLs.

=head2 bookmarks_lol()

Returns a list of lists of bookmarks, with the following elements in
each of the arrayrefs:

  0	URL
  1	Name (the text name of the bookmark)
  2	Added date
  3	Last modified date
  4	Last visited date

=head1 BUGS

This module isn't very fast, but then I do have ~1300 bookmarks, which
is probably excessive.  Nevertheless, it's still easier to use this
module and the C<bmgrep> script to find bookmarks than to use Netscape's
bookmarks interface.

I don't have any other versions of Netscape available to play with, so
I only know that this works with my own copy which is v4.51 on Linux.
Please let me know if you have any problems with other versions.

=head1 FUTURE DIRECTIONS

I intend to add a feature to get a decent tree-like representation of
your folders.  I also intend to provide ways to add, delete and 
otherwise manipulate bookmarks.  This will probably be non-trivial,
but that's life I guess.

=head1 AUTHOR

Kirrily 'Skud' Robert

Netizen Pty Ltd

skud@netizen.com.au

=head1 SEE ALSO

perl(1).

=cut
