package Netscape::Bookmarks::Separator;
# $Revision: 1.2 $
# $Id: Separator.pm,v 1.2 2001/04/05 05:42:43 brian Exp $

use strict;

use subs qw();
use vars qw($VERSION $ERROR @EXPORT @EXPORT_OK @ISA);

use Exporter;

use URI::URL;

($VERSION) = q$Revision: 1.2 $ =~ m/(\d+\.\d+)\s*$/;

@EXPORT    = qw();
@EXPORT_OK = qw();
@ISA       = qw();

sub new
	{
	my $class  = shift;
	my $param  = shift;
	
	my $n = '';
	my $self = \$n;
	
	bless $self, $class;
				
	$self;
	}
	
sub as_string
	{
	return "<HR>";
	}

"if you want to believe everything you read, so be it."

__END__

=head1 NAME

Netscape::Bookmarks::Separator	- manipulate, or create Netscape Bookmarks files

=head1 SYNOPSIS

	use Netscape::Bookmarks::Category;
	use Netscape::Bookmarks::Separator;
  
	#add a separator to a category listing
	my $category  = new Netscape::Bookmarks::Category { ... };
	my $separator = new Netscape::Bookmarks::Separator;
	my $category->add($separator);
  
	#print the separator
	#note that Netscape::Category::as_string does this for you
	print $separator->as_string;
  
=head1 DESCRIPTION

Store a Netscape bookmark separator object.

=head1 METHODS

=head2 $obj->as_string

Prints the separator object in the Netscape bookmark format.  One should
not have to do this as Netscape::Bookmarks::Category will take care of it.

=head1 AUTHOR

brian d foy <comdog@panix.com>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

HTML::Parser, Netscape::Bookmarks::Category, Netscape::Bookmarks::Link, 
Netscape::Bookmarks::Alias, Netscape::Bookmarks::Separator.

=cut
