# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Netscape::Bookmarks;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

eval {
my $netscape = Netscape::Bookmarks->new( "bookmark_files/Bookmarks.html" );

open FILE, "> bookmark_files/Bookmarks_tmp.html" 
	or die "Could not open tmp file: $!";
print FILE $netscape->as_string;
close FILE;
};
print STDERR $@ if $@;

print $@ ? 'not ' : '', 'ok 2', "\n";

# this next one should not correctly create on object
eval {
my $netscape = Netscape::Bookmarks->new( "bookmark_files/bookmarks.curtis.html" );

die "$netscape" if defined $netscape;
};
print STDERR $@ if $@;

print $@ ? 'not ' : '', 'ok 3', "\n";


END { unlink "bookmark_files/Bookmarks_tmp.html" }
