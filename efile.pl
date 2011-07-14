#!/usr/bin/env perl
# Author: Tasos Latsas

# efile: extended file utility
# prints filename, filetype, size
# accepts multiple filename arguments

# requires perl-file-which

use strict;
use warnings;
use File::Which;

our ($_file, $_du);
$_file=which('file');
$_du=which('du');

sub fileinfo {
    # set name
    my $name = shift;
    $name =~ s/\R//g;
    my $info = $name . " : ";

    # get file type    
    my $type = `$_file -b $name`;
    if ($? ne "0") { 
        $info .= "Not Found";
        return $info;
    }
    $type = (split /,/, $type)[0];
    $type =~ s/\R//g;
    $info .= $type . " : ";

    # get size
    my $size = `$_du -sh $name`;
    $size = (split /\t/, $size)[0];
    $size =~ s/\R//g;
    $info .= $size;

    return $info;
}


foreach (@ARGV) { print fileinfo("$_") . "\n"; }
