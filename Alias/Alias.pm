package Netscape::Bookmarks::Alias;
# $Revision: 1.2 $
# $Id: Alias.pm,v 1.2 2001/04/05 06:00:23 brian Exp $

use strict;

use subs qw();
use vars qw($VERSION $ERROR @EXPORT @EXPORT_OK @ISA %aliases);

use Exporter;

use Netscape::Bookmarks::Link;

($VERSION) = q$Revision: 1.2 $ =~ m/(\d+\.\d+)\s*$/;

@EXPORT    = qw();
@EXPORT_OK = qw();
@ISA       = qw();

sub new
	{
	my $class  = shift;
	my $param  = shift;
	
	my $self = {};
			
	bless $self, $class;
	
	$self->{'alias_of'} = $param;
			
	$self;
	}

sub alias_of
	{
	my $self = shift;
	
	return $self->{'alias_of'};
	}

sub target
	{
	my $self     = shift;
	
	return $aliases{$self->{'alias_of'}};
	}
	
sub add_target
	{
	my $target   = shift; #link reference
	my $alias_id = shift;
	
	($$target)->aliasid($alias_id);
	$aliases{$alias_id} = $$target;
	}

sub target_exists
	{
	my $target = shift;
	
	exists $aliases{$target} ? 1 : 0;
	}	
	
"if you want to believe everything you read, so be it."

__END__
