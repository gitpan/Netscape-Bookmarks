package Netscape::Bookmarks::Link;
use strict;

use subs qw();
use vars qw($VERSION $ERROR @EXPORT @EXPORT_OK @ISA);

use Exporter;

use URI::URL;

$VERSION = 0.91;

@EXPORT    = qw();
@EXPORT_OK = qw();
@ISA       = qw();

sub new
	{
	my $class  = shift;
	my $param  = shift;
	
	my $self = {};
	bless $self, $class;

	my $url = new URI::URL $param->{HREF};
	unless( ref $url )
		{
		$ERROR = "[$$param{HREF}] is not a valid URL";
		return -1;	
		}
	$self->{HREF} = $url;
	
	foreach my $k ( qw(ADD_DATE LAST_MODIFIED LAST_VISIT ALIASID ALIASOF) )
		{
		if( $param->{$k} =~ /\D/ )
			{
			$ERROR = "[$$param{$k}] is not a valid $k";
			return -2;	
			}
		$self->{$k} = $param->{$k};
		}
	
	unless( $param->{'TITLE'} )
		{
		$ERROR = "The TITLE cannot be null.";
		return -3;	
		}

	$self->{'TITLE'} = $param->{'TITLE'};
	
	$self->{'DESCRIPTION'} = $param->{'DESCRIPTION'};
				
	$self;
	}
	

sub href
	{
	my $self = shift;
	
	($self->{'HREF'})->as_string
	}

sub add_date
	{
	my $self = shift;
	
	$self->{'ADD_DATE'}
	}
	
sub last_modified
	{
	my $self = shift;
	
	$self->{'LAST_MODIFIED'}
	}
	
sub last_visit
	{
	my $self = shift;
	
	$self->{'LAST_VISIT'}
	}
	
sub title
	{
	my $self = shift;
	
	$self->{'TITLE'}
	}

sub description
	{
	my $self = shift;
	
	$self->{'DESCRIPTION'}
	}
	
sub aliasid
	{
	my $self = shift;
	my $data = shift;
	
	$self->{'ALIASID'} = $data if defined $data;

	$self->{'ALIASID'}
	}

sub aliasof
	{
	my $self = shift;
	
	$self->{'ALIASOF'}
	}
	
sub append_title
	{
	my $self = shift;
	my $text = shift;
	
	$self->{'TITLE'} .= $text;
	}

sub append_description
	{
	my $self = shift;
	my $text = shift;
	
	$self->{'DESCRIPTION'} .= $text;
	}
	

sub print_dump
	{
	my $self = shift;
	
	print <<"HERE";
$$self{TITLE}
@{[($$self{HREF})->as_string]}
	$$self{ADD_DATE}
	$$self{LAST_MODIFIED}
	$$self{LAST_VISIT}
	$$self{ALIASID}
	
HERE

	}
	
sub as_string
	{
	my $self = shift;
	
	my $link  = $self->href;
	my $title = $self->title;
	
	my $add_date      = $self->add_date;
	my $last_visit    = $self->last_visit;
	my $last_modified = $self->last_modified;
	my $aliasid       = $self->aliasid;
	my $aliasof       = $self->aliasof;
	
	$aliasid = defined $aliasid ? qq|ALIASID="$aliasid" | : '';
	$aliasof = defined $aliasof ? qq|ALIASOF="$aliasof" | : '';
	$add_date = $add_date ? qq|ADD_DATE="$add_date" | : qq|ADD_DATE="0" |;
	$last_visit = $last_visit ? qq|LAST_VISIT="$last_visit" | : qq|LAST_VISIT="0" |;
	$last_modified = $last_modified ? qq|LAST_MODIFIED="$last_modified"| : qq|LAST_MODIFIED="0"|;

	my $desc = "\n<DD>" . $self->description if $self->description;
	return qq|<A HREF="$link" $aliasof$aliasid$add_date$last_visit$last_modified>$title</A>$desc|;
	}

"if you want to believe everything you read, so be it."

__END__

=head1 NAME

Netscape::Bookmarks::Link	- manipulate, or create Netscape Bookmarks links

=head1 SYNOPSIS

  use Netscape::Bookmarks::Bookmarks;
  
  my $category = new Netscape::Bookmarks::Category { ... };
  my $link = new Netscape::Bookmarks::Link {
  		TITLE         => 'this is the title',
  		DESCRIPTION   => 'this is the description',
  		HREF          => 'http://www.perl.org',
  		ADD_DATE      => 937862073,
  		LAST_VISIT    => 937862073,
  		LAST_MODIFIED => 937862073,
  		ALIAS_ID      => 4,
  		}
  		
  $category->add($link);
  
  
  #print a Netscape compatible file
  print $link->as_string;
  
=head1 DESCRIPTION

The Netscape bookmarks file has several basic components:

	title
	folders (henceforth called categories)
	links
	aliases
	separators
	
On disk, Netscape browsers store this information in HTML. In the browser,
it is displayed under the "Bookmarks" menu.  The data can be manipulated
through the browser interface.

This module allows one to manipulate the links in for a Netscape bookmarks
file.  A link has these attributes, only some of which may be present:

	title
	description
	HREF (i.e. URL)
	ADD_DATE
	LAST_MODIFIED
	LAST_VISIT
	ALIAS_OF
	ALIAS_ID

These are explained below.	

=head1 METHODS

=head2 $obj->href

Returns the URL of the link.  The URL appears in the HREF attribute of
the anchor tag.

=head2 $obj->title

Returns the link title.

=head2 $obj->append_title

Adds to the title - used mostly for the HTML parser, although it can
be used to add a title if none exists (which is an error, though).

=head2 $obj->description

Returns the link description.

=head2 $obj->append_description

Adds to the description - used mostly for the HTML parser, although
it can be used to add a description if none exists.

=head2 $obj->add_date

Returns the date when the link was added, in Unix epoch time.

=head2 $obj->last_visit

Returns the date when the link was last vistied, in Unix epoch time. Returns
zero if no information is available.

=head2 $obj->last_modified

Returns the date when the link was last modified, in Unix epoch time.  Returns
zero if no information is available.

=head2 $obj->alias_id

Returns the alias id of a link. Links with aliases are assigned an ALIAS_ID which
associates them with the alias.  The alias contains the same value in it's ALIAS_OF
field.  The Netscape::Bookmarks::Alias module handles aliases as references to
Netscape::Bookmarks::Link objects.

=head2 $obj->as_string

Returns a Netscape compatible bookmarks file based on the Bookmarks object.

=head1 TO DO

	Add methods for manipulating attributes
	
=head1 AUTHOR

brian d foy <comdog@panix.com>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

HTML::Parser, Netscape::Bookmarks::Category, Netscape::Bookmarks::Link, 
Netscape::Bookmarks::Alias, Netscape::Bookmarks::Separator.

=cut
