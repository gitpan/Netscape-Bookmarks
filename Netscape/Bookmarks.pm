package Netscape::Bookmarks;
use strict;

use subs qw();
use vars qw(@ISA
			$VERSION
			@category_stack
			$flag
			%link_data
			%category_data
			$netscape
			$state
			$current_link
			$ID
			$text_flag
			);

use HTML::Entities;
use HTML::Parser;

use Netscape::Bookmarks::Alias;
use Netscape::Bookmarks::Category;
use Netscape::Bookmarks::Link;
use Netscape::Bookmarks::Separator;

$VERSION = 0.92;
@ISA=qw(HTML::Parser);

$ID = 0;

sub new
	{
	my($class, $file) = @_;
	
	unless( $file )
		{
		my $cat = new Netscape::Bookmarks::Category;
		return $cat;
		}
		
	return undef unless (-e $file or ref $file);
	
	my $self = new HTML::Parser;
	
	bless $self, $class;
	
	$self->parse_file($file);
	
	return $netscape;
	}

sub parse_string
	{
	my $ref = shift;
	
	my $self = new HTML::Parser;
	bless $self, "Netscape::Bookmarks";
	
	my $length = length $$ref;
	my $pos    = 0;
	
	while( $pos < $length )
		{
		$self->parse( substr( $$ref, $pos, 512 ) );
		$pos += 512;
		}
		
	$self->eof;
			
	return $netscape;
	}
	
sub start
	{
    my($self, $tag, $attr) = @_;
    
    $text_flag = 0;
    
    if( $tag eq 'a' )
    	{
   		$state = 'anchor';
    	%link_data = %$attr;	
     	}
    elsif( $tag eq 'h3' or $tag eq 'h1' )
    	{
    	$state = 'category';
    	%category_data = %$attr;
    	}
    elsif( $tag eq 'hr' )
    	{
    	my $item = new Netscape::Bookmarks::Separator;
    	print "Found Separator: $item\n" if $DEBUG;
    	${$category_stack[-1]}->add(\$item);
    	}
    	
    $flag = $tag
	}

sub text
	{
	my($self, $text) = @_;	
	
	if($text_flag)
		{
		if( $flag eq 'h1' or $flag eq 'h3' )
			{
			${$category_stack[-1]}->append_title($text);
			}
		elsif( $flag eq 'a' and not exists $link_data{'aliasof'} )
			{
			${$current_link}->append_title($text);
			}
		elsif( $flag eq 'dd' )
			{
			${$category_stack[-1]}->append_description($text);
			}

		}
	else
		{
		if( $flag eq 'h1' )
			{
			$netscape = new Netscape::Bookmarks::Category
				{
				title    => $text,
				folded   => 0,
				add_date => $category_data{'add_date'},
				id       => $ID++,
				};
						
			push @category_stack, \$netscape;
			}
		elsif( $flag eq 'h3' )
			{
			my $cat = new Netscape::Bookmarks::Category
				{
				title    => $text,
				folded   => exists $category_data{'folded'},
				add_date => $category_data{'add_date'},
				id       => $ID++,
				};
			
			${$category_stack[-1]}->add(\$cat);
			push @category_stack, \$cat;	
			}
		elsif( $flag eq 'a' and not exists $link_data{'aliasof'} )
			{    	
			my $item = new Netscape::Bookmarks::Link {
	    		HREF			=> $link_data{'href'},
	    		ADD_DATE 		=> $link_data{'add_date'},
	    		LAST_MODIFIED 	=> $link_data{'last_modified'},
	    		LAST_VISIT    	=> $link_data{'last_visit'},
	    		ALIASID         => $link_data{'aliasid'},
	    		TITLE           => $text,
	    		};
	    	unless( ref $item )
	    		{
	    		print "ERROR: $Netscape::Bookmarks::Link::ERROR\n" if $DEBUG;
	    		return;
	    		}
	
			if( defined $link_data{'aliasid'} )
				{
				&Netscape::Bookmarks::Alias::add_target(\$item, $link_data{'aliasid'})
				}
				
			print "Link title is ", $item->title, "\n" if $DEBUG;
			
			${$category_stack[-1]}->add(\$item);
			$current_link = \$item;
			}
		elsif( $flag eq 'a' and defined $link_data{'aliasof'} )
			{    	
			my $item = new Netscape::Bookmarks::Alias $link_data{'aliasof'};
			print "Bookmarks[", __LINE__, "]: [$item]\n" if $DEBUG;
	    	unless( ref $item )
	    		{
	    		print "ERROR: $Netscape::Bookmarks::Alias::ERROR\n" if $DEBUG;
	    		return;
	    		}
				
			${$category_stack[-1]}->add(\$item);
			$current_link = \$item;
			}
		elsif( $flag eq 'dd' )
			{
			if( $state eq 'category' )
				{
				${$category_stack[-1]}->add_desc($text);
				}
			elsif( $state eq 'anchor' )
				{
	     		${$$current_link}{'DESCRIPTION'} = $text;
				}
			}
		}
		
	$text_flag = 1;
	}

sub end
	{
    my($self, $tag, $attr) = @_;
    
    $text_flag = 0;
    pop @category_stack   if $tag eq 'dl';
    $current_link = undef if $tag eq 'a';	
    $flag = undef;
    }
    
sub my_init {}

"Seeing is believing";

=head1 NAME

Netscape::Bookmarks	- parse, manipulate, or create Netscape Bookmarks files

=head1 SYNOPSIS

  use Netscape::Bookmarks;
  
  # parse an existing file
  my $bookmarks = new Netscape::Bookmarks $bookmarks_file;
  
  # -- OR --
  # start a new Bookmarks structure
  my $bookmarks = new Netscape::Bookmarks::Category { ... }
  		
  # print a Netscape compatible file
  print $bookmarks->as_string;
  
=head1 DESCRIPTION

The Netscape bookmarks file has several basic components:

	title
	folders (henceforth called categories)
	links
	aliases
	separators
	
On disk, Netscape browsers store this information in HTML.
In the browser, it is displayed under the "Bookmarks" menu. 
The data can be manipulated through the browser interface.

This module allows one to manipulate the bookmarks file
programmatically.  One can parse an existing bookmarks file,
manipulate the information, and write it as a bookmarks file
again.  Furthermore, one can skip the parsing step to create
a new bookmarks file and write it in the proper format to be
used by a Netscape browser.

The Bookmarks module simply parses the bookmarks file passed
to it as the only argument to the constructor:

my $bookmarks = new Netscape::Bookmarks $bookmarks_file;

The returned object is a Netscape::Category object, since
the bookmark file is simply a collection of categories that
contain any of the components listed above.  The top level
(i.e. root) category is treated specially and defines the
title of the bookmarks file.

HTML::Parser is used behind the scenes to build the data
structure (a simple list of lists (of lists ...).  The
Netscape::Category object can contain either a
Netscape::Category, Netscape::Link, Netscape::Alias, or
Netscape::Separator object.  Aliases are treated as
references to links, so changes to an alias affect the
referenced link, and vice versa.

Methods for manipulating this object are in the
Netscape::Category module.  Methods for dealing with the
objects contained in a Netscape::Category object are in
their appropriate modules.

=head1 AUTHOR

brian d foy <comdog@panix.com>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

HTML::Parser, Netscape::Bookmarks::Category, Netscape::Bookmarks::Link, 
Netscape::Bookmarks::Alias, Netscape::Bookmarks::Separator.

=cut
