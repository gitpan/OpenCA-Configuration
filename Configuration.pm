## OpenCA::Configuration.pm 
##
## Copyright (C) 1998-1999 Massimiliano Pala (madwolf@openca.org)
## All rights reserved.
##
## This library is free for commercial and non-commercial use as long as
## the following conditions are aheared to.  The following conditions
## apply to all code found in this distribution, be it the RC4, RSA,
## lhash, DES, etc., code; not just the SSL code.  The documentation
## included with this distribution is covered by the same copyright terms
## 
## Copyright remains Massimiliano Pala's, and as such any Copyright notices
## in the code are not to be removed.
## If this package is used in a product, Massimiliano Pala should be given
## attribution as the author of the parts of the library used.
## This can be in the form of a textual message at program startup or
## in documentation (online or textual) provided with the package.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
## 1. Redistributions of source code must retain the copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. All advertising materials mentioning features or use of this software
##    must display the following acknowledgement:
##    "This product includes OpenCA software written by Massimiliano Pala
##     (madwolf@openca.org) and the OpenCA Group (www.openca.org)"
## 4. If you include any Windows specific code (or a derivative thereof) from 
##    some directory (application code) you must include an acknowledgement:
##    "This product includes OpenCA software (www.openca.org)"
## 
## THIS SOFTWARE IS PROVIDED BY OPENCA DEVELOPERS ``AS IS'' AND
## ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
## FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
## OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
## HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
## LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
## OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.
## 
## The licence and distribution terms for any publically available version or
## derivative of this code cannot be changed.  i.e. this code cannot simply be
## copied and put under another distribution licence
## [including the GNU Public Licence.]
##
## Porpouse:
## =========
##
## Get easily configuration parameters passed into a config file
##
## Status:
## =======
##
##          Started: 10/11/1998
##    Last Modified: 28/04/1999
##

package OpenCA::Configuration;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '1.2';


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

OpenCA::Configuration - Perl extension for blah blah blah

=head1 SYNOPSIS

  use OpenCA::Configuration;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for OpenCA::Configuration was created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut

## Define Error Messages for the Configuration Manager Errors
my $cgiManager  = 'Massimiliano Pala <madwolf@comune.modena.it>';
my $configDim   = 0;

my @configLines = ();
my @configDB    = ();
my @errorCodes  = { '100', 'Configuration File Not Found',
		    '101', 'Keyword error.'}; 

## Create an instance of the Class
sub new {
	my $self = {};
	bless $self;

	$fileName = $keys[1];
	if( "$fileName" ne "" ) {
		my $ret = $self->loadCfg ( $fileName );
		return undef if ( not $ret );
	}

	return $self;
}

## Configuration Manager Functions
sub loadCfg {
	my $self = shift;
	my $ret = 0;
	my @keys; 
	@keys = @_;

	$fileName = $keys[0];

	open( FD, "$fileName" ) || return undef;
	while( $temp = <FD> ) {
		@configLines = ( @configLines, $temp );
	}
	close(FD);

	$ret = $self->parsecfg( @configLines );
	return $ret;
}

## Parsing Function
sub parsecfg {
	my $self = shift;
	my @keys;
	my $num = -1;
	@keys = @_;

	@configDB = ();
	
	foreach $line (@keys) {
		my $paramName;
		my %par;
		my @values;

		## Take count of Config Line Number
		$num++;

		## Trial line and discard Comments
		chop($line);
		next if ($line =~ /\#.*/)||($line eq "")||($line =~ /HASH.*/);
		$line =~ s/#.*//;
		$line =~ s/^[\s]*//;

		## Get the Parameter Name
		( $paramName ) = 
			( $line =~ /([\S]+).*/ );

		## Erase the parameter Name from the Line
		$line =~ s/$paramName// ;

		@values = ();

		## Start displacing command
		while ( length($line) > 0 ) {
			my ( $param, $match ); 

			## Delete remaining Spaces
			$line =~ s/^[\s]*//;

			if ( $line =~ /^\"/ ) {
				( $param ) = ( $line =~ /^\"([^\"]*)/ );
			} else {
				( $param ) = ( $line =~ /^([\S]+)/ );
			};

			@values = ( @values, $param );
			
			$param =~ s/\$/\\\$/g;
			$line =~ s/$param//;
			$line =~ s/""//;

		}

		## Get the parameter set up
		$par = { NAME=>$paramName,
		 	 LINE_NUMBER=>$num,
		 	 VALUES=>[ @values ] };

		push @configDB, $par;
	}

	return @configDB;
}

## Get Single Parameter
sub getParam {
	my $self = shift;
	my %ret = {};
	my @keys;
	my @par = ();
	@keys = @_;

	return $self->getNextParam( NAME=>$keys[0],
		LINE_NUMBER=>-1 );
};

## Get next Parameter	 
sub getNextParam {
	my $self = shift;
        my %k = @_;
	my %par = {};
	
	return undef unless ( $#_ > 0 );

	foreach $par ( @configDB ) {
		my $tmp = $par->{NAME};
		$tmp =~ s/^$k{NAME}//i;

		if ( ( "$tmp" eq ""  ) &&
				( $par->{LINE_NUMBER} > $k{LINE_NUMBER})  ) {
			return $par;
		};
	};

	return undef;
}

sub checkParam {
	my $self = shift;
	my %k = @_;
	my %par = {};
	my $pnum;

	return unless ( $#_ > 0 );

	$par = $self->getParam( $k->{NAME} );
	return unless ( not ( keys %$par ));

	## $pnum = $#($par->{VALUES});

	if( ($k->{MIN}) && ($pnum < $k->{MIN}) ) {
		return $par->{LINE_NUMBER};
	}

 	if( ($k->{MAX}) && ($pnum > $k->{MAX}) ) {
		return $par->{LINE_NUMBER};
	}

	return 0;
}

sub checkConfig {
	my $self = shift;
	my @parameters = @_;
	my $ret;

	foreach $par ( @parameters ) {
		$ret = $self->ceckParam( $par );
		return if ( $ret == -1 );
	}

	return 0;
}

sub getVersion {
	my $self = shift;

	return $VERSION;
}

___END___;
