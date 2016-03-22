#!/usr/bin/perl

use warnings;
use strict;

my %hash=();
my %feature=();

my @List=();

my $tag=0;
open FILE, "feature.txt" or die "$!\n";
while(my $line=<FILE>){
	if($line=~/mRMR feature/){
		$tag=1;
	}
	
	if($tag==1 and $line=~/^\d/){
		my @tmp=split(/\s+/, $line);
		push(@List, $tmp[1]);
	}
}
close FILE or die "$!\n";

@List=sort{$a<=>$b}(@List);
open FILE, ">FeatureList.txt" or die "$!\n";
for(my $i=0; $i<@List; $i++){
	print FILE "$List[$i]\n";
}
close FILE or die "$!\n";

