package Netscape::Bookmarks::Category;
use strict;

use subs qw();
use vars qw($VERSION $ERROR @EXPORT @EXPORT_OK @ISA	$LAST_ID %IDS);

use Exporter;

use URI::URL;

use constant START_LIST      => '<DL><p>';
use constant END_LIST        => '</DL><p>';
use constant START_LIST_ITEM => '<DT>';
use constant TAB             => '    ';
use constant FOLDED_TRUE     => 1;
use constant FOLDED_FALSE    => 0;
	
$VERSION = 0.91;
%IDS     = ();
$LAST_ID = -1;

@EXPORT    = qw();
@EXPORT_OK = qw();
@ISA       = qw();


sub new
	{
	my $class  = shift;
	my $param  = shift;
	
	my $self = {};
	bless $self, $class;
	
	$param->{'folded'} = FOLDED_TRUE unless $param->{'folded'} == FOLDED_FALSE;

	unless( exists $IDS{$param->{'id'}} or $param->{'id'} =~ /\D/)
		{
		$param->{'id'} = ++$LAST_ID;
		$IDS{$LAST_ID}++;
		}

	if( $param->{'add_date'} =~ /\D/ or not $param->{'add_date'} =~ /^\d+$/ )
		{
		$param->{'add_date'} = 0;
		}
	
	$self->{'title'}       = $param->{'title'};
	$self->{'folded'}      = $param->{'folded'};
	$self->{'add_date'}    = $param->{'add_date'};
	$self->{'id'}          = $param->{'id'};
	$self->{'description'} = $param->{'description'};
	$self->{'thingys'}     = [];
	
	$self;
	}
	
sub add
	{
	my $self = shift;
	my $thingy = shift;
	
	return undef unless 
		ref $$thingy eq 'Netscape::Bookmarks::Link' or 
		ref $$thingy eq 'Netscape::Bookmarks::Category' or
		ref $$thingy eq 'Netscape::Bookmarks::Separator' or
		ref $$thingy eq 'Netscape::Bookmarks::Alias';
		
	push @{ $self->{'thingys'} }, $$thingy;
	}

sub append_title
	{
	my $self = shift;
	my $text = shift;
	
	$self->{'title'} .= $text;
	}

sub append_description
	{
	my $self = shift;
	my $text = shift;
	
	$self->{'description'} .= $text;
	}
	
sub add_desc
	{
	my $self = shift;
	my $text = shift;
			
	$self->{'description'} = $text;
	}

sub title
	{
	my $self = shift;
	
	$self->{'title'};
	}

sub id
	{
	my $self = shift;
	
	$self->{'id'};
	}

sub folded
	{
	my $self = shift;
	
	return $self->{'folded'} ? 1 : 0;
	}

sub add_date
	{
	my $self = shift;
	
	return $self->{'add_date'};
	}
	
sub elements
	{
	my $self = shift;
	
	return \@{ $self->{'thingys'} };
	}
	
sub categories
	{
	my $self = shift;
	
	my @list = grep ref $_ eq 'Netscape::Bookmarks::Category', @{$self->elements};
	
	return @list;
	}

sub links
	{
	my $self = shift;
	
	my @list = grep ref $_ eq 'Netscape::Bookmarks::Link', @{$self->elements};
	
	return @list;
	}

sub as_headline
	{
	my $self = shift;
	
	my $folded = $self->folded ? "FOLDED" : "";
	my $add_date = $self->add_date;
	my $title = $self->title;
	
	$add_date = $add_date ? qq|ADD_DATE="$add_date"| : '';
	
	my $sp = ($folded and $add_date) ? ' ' : '';
	
	return qq|<H3 $folded$sp$add_date>$title</H3>|
	}

sub as_string
	{
	my $self = shift;
	
	my $title = $self->title;
	
	my $str = <<"HTML";
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
It will be read and overwritten.
Do Not Edit! -->
<TITLE>$title</TITLE>
<H1>$title</H1>\x0A
HTML
	
	$str .= START_LIST . "\n";
	
	foreach my $ref ( @{$self->elements} )
		{
		$str .= $self->_as_string(\$ref, 1);
		}

	$str .= END_LIST . "\n";
	
	return $str;
	}

sub _as_string
	{
	my $self  = shift;
	my $obj   = shift;
	my $level = shift;
		
	my $str; 
	if( ref $$obj eq 'Netscape::Bookmarks::Category' )
		{
		++$level;
		$str .= TAB x ($level - 1) . START_LIST_ITEM . ($$obj)->as_headline . "\n";
		$str .= TAB x ($level - 1) . START_LIST . "\n";
		
		foreach my $ref ( @{($$obj)->elements} )
			{
			$str .= $self->_as_string(\$ref, $level);
			}
		
		$str .= TAB x ($level - 1) . END_LIST . "\n";
		--$level;
		}
	elsif( ref $$obj eq 'Netscape::Bookmarks::Link' )
		{
		my $title = ($$obj)->title;
		my $url   = ($$obj)->href;
		$str .= TAB x ($level) . START_LIST_ITEM . ($$obj)->as_string . "\n"
		}
	elsif( ref $$obj eq 'Netscape::Bookmarks::Alias' )
		{
		my $title = ($$obj)->target->title;
		my $url   = ($$obj)->target->href;
		my $s = ($$obj)->target->as_string;
		$s =~ s/ALIASID/ALIASOF/;
		$str .= TAB x ($level) . START_LIST_ITEM . $s . "\n"
		}
	elsif( ref $$obj eq 'Netscape::Bookmarks::Separator' )
		{
		$str .= TAB x ($level) . ($$obj)->as_string . "\n"
		}
		
	return $str;
		
	}	
	
"if you want to beleive everything you read, so be it."

__END__

=head1 NAME

Netscape::Bookmarks::Category	- manipulate, or create Netscape Bookmarks files

=head1 SYNOPSIS

  use Netscape::Bookmarks;
  
  #parse an existing file
  my $bookmarks = new Netscape::Bookmarks $bookmarks_file;
  
  #print a Netscape compatible file
  print $bookmarks->as_string;
  
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

This module allows one to manipulate the bookmarks file programmatically.  One
can parse an existing bookmarks file, manipulate the information, and write it
as a bookmarks file again.  Furthermore, one can skip the parsing step to create
a new bookmarks file and write it in the proper format to be used by a Netscape
browser.

The Bookmarks.pm module simply parses the bookmarks file passed to it as the
only argument to the constructor:

	my $bookmarks = new Netscape::Bookmarks $bookmarks_file;

The returned object is a Netscape::Bookmarks::Category object, since the bookmark file is
simply a collection of categories that contain any of the components listed 
above.  The top level (i.e. root) category is treated specially and defines the
title of the bookmarks file.

=head1 METHODS

=head2 $obj->add

=head2 $obj->append_title

=head2 $obj->append_description

=head2 $obj->add_desc

=head2 $obj->title

=head2 $obj->description

=head2 $obj->add_date

=head2 $obj->id

=head2 $obj->folded

=head2 $obj->elements

=head2 $obj->categories

=head2 $obj->links

=head2 $obj->as_string


=head1 AUTHOR

brian d foy <brian@smithrenaud.com>

Copyright (c) 1999 Smith Renaud, Inc. All rights reserved.
This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

HTML::Parser, Netscape::Bookmarks::Category, Netscape::Bookmarks::Link, 
Netscape::Bookmarks::Separator.

=cut
