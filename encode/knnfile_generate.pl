#! /usr/bin/perl -w
use strict;
my $path = $ARGV[0];
my $kv = $ARGV[1];
my $knnfile = $path.".knnfile";
my $pathtrain = $path.".train";

unless (-e $knnfile)
{
	#print "File not found.then create it\n";
	#创建文件并写入
	open(KNNFILE,">$knnfile") or die "Couldn't open $knnfile:$!";
}
else
{
	open(KNNFILE,">$knnfile") or die "Couldn't open $knnfile:$!";
	#print "File found.\n";
}

my $count = 0;
my $knumber = 0;

my @kratio = ();
my @knnnumber = ();
$kratio[0] = 0.00125*$kv;
$kratio[1] = 0.0025*$kv;
$kratio[2] = 0.005*$kv;
$kratio[3] = 0.01*$kv;
$kratio[4] = 0.02*$kv;

$count = `cat $pathtrain | grep "^.*" -c`;
my $multinum = 1;

while($kratio[0]*$count*$multinum <= 1)
{
		$multinum = 10*$multinum;
}

print KNNFILE int($multinum*$count*$kratio[0])."\n";
print KNNFILE int($multinum*$count*$kratio[1])."\n";
print KNNFILE int($multinum*$count*$kratio[2])."\n";
print KNNFILE int($multinum*$count*$kratio[3])."\n";
print KNNFILE int($multinum*$count*$kratio[4])."\n";

close KNNFILE;
