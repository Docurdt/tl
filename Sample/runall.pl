#! /usr/bin/perl -w

use strict;
my $new_dir = $ARGV[0];
my $path = $new_dir."*.final";
#my $path = "/home/wangyanan/datainput/*.final";
my @dir = glob($path);

foreach(@dir)
{
 $_ =~ s/\s/\\ /;
 my $args = join ' ', "./featureadd.pl", $_, "\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

}

my $path2 = $new_dir."*feature.add";
#my $path2 = "/home/wangyanan/datainput/*feature.add";
my @dir2 = glob($path2);

foreach(@dir2)
{
 $_ =~ s/\s/\\ /;
 my $args = join ' ', "./sample.pl", $_, "\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

}
