use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
# $Revision: 1.4 $
# $Id: Makefile.PL,v 1.4 2001/04/05 05:48:15 brian Exp $

WriteMakefile(
    'NAME'	=> 'Netscape::Bookmarks',
    'VERSION_FROM' => 'Bookmarks.pm', # finds $VERSION
    'PREREQ_PM'    => { 	
	'HTML::Parser' => undef,
	'HTML::Entities' => undef,
	 }
);
