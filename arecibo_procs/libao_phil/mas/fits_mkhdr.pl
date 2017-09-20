#!/usr/bin/perl -w
#
# fits_mkhdr.pl :
# filter to generate an idl fits header from the  fits_header.h.
#
#typedef struct {
#  void *next;     //ptr offset bytes from start of struct. Computed from
#//                  (0)->elmname. includes datapointer
#//                 after init. pnts to data in fits_header struct
#  char *name;
#  int offset;     // offset bytes start of hdr. excludes dataptr. from table
#  int type;       // datatype
#  int len;        // length of single data element */
#  int alen;       // number of elements. 1 if not array
#  char *form;     // for fits header D13.5 ..
#  char *unit;     // hz, etc
#  char *comment;  //  for header
# FITSKEY};
#
# there is 1 FITSKEY entry for each element of FITS_HEADER (except for the
# ARRAY_DES at the beginning).
#
# The parsing starts at:
#struct FITS_HEADER {
#
# and finishes with the line:
#
#	The datatype and name are used to generate the name,offset,type,len,alen.
# The comment for each entry in FITS_HEADER is also parsed. It should
# include:
# token 1 - units for entry x is none
# token 2 - format to use for printing (loaded in fits header)
# token 3 to */ comment to add to fits file entry
# 
#};
#
# To create the file: fits_chkhdr.c..
#
# cat fits_chkhdr_start.c fits_chkhdr.c
# fits_chkhdr.pl < ../../include/fits_header.h >> fits_chkhdr.c
# cat fits_chkhdr_end.c >> fits_chkhdr.c
#
# warning...
# on 64 bit machines
#  long int, long long are 8 bytes.. 
#   
use strict;
use warnings;
#
	my  $type;			# c type
	my  $typeLen;		# bytes for basic length
	my  $typeL;			# label for this type (for fits file)
	my  $name;			# element name
	my  $units;		    # for fits file
	my  $com;			# for fits fiel
	my  $arrayDim;      # non zero if array
	my  $arrayDimL;      # non zero if array
	my  $printM;		# print Mode for fits file
	my  $cumOffset=0;	# from start of struct (but skip ptr at start)
	my	$started=-2;
	my  $rbrace="}";
	my  $lbrace="}";
#

	while (<>) {
#########		print STDERR "st:$started:$_\n";
		if  ($started lt  0) {
		    $started+=1  if ( /^\s*FITS_ARRAY_DES/ );
			printf "a={masfhdrb ,\$\n" if $started eq 0;
			next;
		}         
	 	last if /^}\s+FITS_HEADER;\s*/;
		chomp;
	    next if /^[ \t]*(\/\*)?$/ ;# skip blank lines and  comments
        next if /^\s*\/\// ;# skip blank lines and  comments

#
#  	parse the structure element line
#
#     skip          1:type   2:name              3:units 4:print 5:comment     
#	print "$_\n";
/^\s*(?:unsigned)?\s+(\w+)\s+([^ ;]+)\s*;\s*\/\*\s*(\S+)\s+(\S+)\s+(.*)\s*\*\/\s*$/;
#
#	need to process long long separately
#
		if ( ( $1 =~ /long/) && ( $2 =~ /long/ ) ) {
#     skip          1:type   2:type 3:name                 4:units 5:print 6:comment     
/^\s*(?:unsigned)?\s+(long)\s+(\w+)\s+([^ ;]+)\s*;\s*\/\*\s*(\S+)\s+(\S+)\s+(.*)\s*\*\/\s*$/;
			$type="longlong";
			$name=$3;
			$units=$4;
			$printM=$5;
			$com  =$6;
		} else {
			$type=$1;
			$name=$2;
			$units=$3;
			$printM=$4;
			$com  =$5;
		}
#
#	see if we have an array declaration
#
		my $arrayDim=1;
		if ( $name =~ /([a-z][a-zA-Z0-9_]+)\[(\d+)\]/) {
			$arrayDim=$2;
	    	$name=$1;
			$arrayDimL=sprintf "%d",$arrayDim
		}
#
#	now select on the datatype
#
		if     ($type =~ /double/) {
			$typeLen=8;
			$typeL  =($arrayDim gt 1)?"dblarr(" . $arrayDimL . ")":"0D";
		}
		elsif ($type =~ /longlong/) {
			$typeLen=8;
			$typeL  =($arrayDim gt 1)?"lon64arr(" . $arrayDimL . ")":"0LL";
		}
		elsif ($type =~ /long/) {
			$typeLen=4;
			$typeL  ="LONG";
			$typeL  =($arrayDim gt 1)?"lonarr(" . $arrayDimL . ")":"0L";
		}
		elsif ($type =~ /int/) {
			$typeLen=4;
			$typeL  =($arrayDim gt 1)?"lonarr(" . $arrayDimL . ")":"0L";
		}
		elsif ($type =~ /float/) {
			$typeLen=4;
			$typeL  =($arrayDim gt 1)?"fltarr(" . $arrayDimL . ")":"0.";
		}
		elsif ($type =~ /short/) {
			print STDERR "err:element:$name is type short.. not supported..";
			exit -1 ;
		}
		elsif ($type =~ /char/) {
			$typeLen=1;
			$typeL  =($arrayDim gt 1)?"bytarr(" . $arrayDimL . ")":"0B";
		}
		else {
			print STDERR "err:element:$name unknown type:$type";
			exit -1;
		}
#
#	output the formated line
#
		my 	$l;
#
#	name
#
		printf "%15.15s:",$name;
#
# datatype
#
		printf "%12.12s,\$;",$typeL;

#
#	bytes offset start then comments
#
		printf "(%4d)%s\n",$cumOffset,$com;
		$cumOffset+= $typeLen*$arrayDim;	
	}
	printf "}\n";
