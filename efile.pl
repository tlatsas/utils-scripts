#!/usr/bin/env perl
# Author: Tasos Latsas

# efile: extended file utility
# prints filename, filetype, size
# accepts multiple filename arguments

use strict;
use warnings;

our ($_file, $_du);
$_file="/usr/bin/file";
$_du="/bin/du";

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
