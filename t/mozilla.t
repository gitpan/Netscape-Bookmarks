# $Id$
use strict;

use Test::More tests => 2;
use Test::File;

use Netscape::Bookmarks;

my $File = 'bookmark_files/mozilla.html';

file_exists_ok( $File );
my $netscape = Netscape::Bookmarks->new( $File );
isa_ok( $netscape, 'Netscape::Bookmarks::Category' );
