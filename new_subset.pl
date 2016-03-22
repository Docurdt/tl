#! /usr/bin/perl -w
########################################
# Script function
# generate train and test data set
#
# call the scripts to files combination
# and Sample
#
# for keeping the parameter between the scripts, 
# rename the file name.
########################################
use strict;

my $path = $ARGV[0];

my $seqpath = $path;
$seqpath =~ s/feature.addseq//;
my $temp_train = $seqpath.".train";
my $temp_test = $seqpath.".test";

my $pathtest;
my $pathtrain;	
$pathtest = $path.".test";
$pathtrain = $path.".train";

my $count = 0;
my $testnumber = 0;

my @myrand = ();


$count = `cat $seqpath | grep "^>" -c`;
$testnumber =int($count / 6);
# print "The Number of Samples: $count \t $testnumber\n";

&myrand("$count", "$testnumber");

open(FINAL_FILE, $seqpath) or die "Can't open the *.final file:$!\n";

unless (-e $temp_train)
{
	open(TRAIN_FILE,">$temp_train") or die "Couldn't open $temp_train:$!";
}
else
{
    open(TRAIN_FILE,">$temp_train") or die "Couldn't open $temp_train:$!";
}


unless (-e $temp_test)
{
	open(TEST_FILE,">$temp_test") or die "Couldn't open $temp_test:$!";
}
else
{
    open(TEST_FILE,">$temp_test") or die "Couldn't open $temp_test:$!";
}

my $temp_line;
my $seq_index = 0;
my $flag = 0;
while($temp_line = <FINAL_FILE>)
{
	foreach(@myrand)
	{
		if($_ == $seq_index)
		{
			$flag = 1;
			last;
		}
		else
		{
			$flag =0;
		}
	}

	if($flag == 1)
	{
		if($temp_line =~ m/^>.*/)
		{
			print TEST_FILE $temp_line;
		}
		elsif($temp_line =~ m/^site.*/)
		{
			print TEST_FILE $temp_line;
		}
		elsif($temp_line =~ m/[A-Z]*/)
		{
			print TEST_FILE $temp_line;
			$seq_index += 1;
		}
	}
	elsif($flag == 0)
	{
		
		if($temp_line =~ m/^>.*/)
		{
			print TRAIN_FILE $temp_line;
		}
		elsif($temp_line =~ m/^site.*/)
		{
			print TRAIN_FILE $temp_line;
		}
		elsif($temp_line =~ m/[A-Z]*/)
		{
			print TRAIN_FILE $temp_line;
			$seq_index += 1;
		}
	}

}
close FINAL_FILE;
close TEST_FILE;
close TRAIN_FILE;

my $args = join ' ', "Sample/featureadd.pl $temp_test \n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "Sample/featureadd.pl $temp_train \n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "Sample/sample_test.pl", $temp_test."feature.add", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "Sample/sample.pl", $temp_train."feature.add", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";


$args = join ' ', "mv", $temp_test."feature.addseq", $path.".test","\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "mv", $temp_train."feature.addseq", $path.".train", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

$args = join ' ', "cat",  $path.".train", $path.".test", ">$path", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

$args = join ' ', "cat",  $seqpath.".trainfeature.add", $seqpath.".testfeature.add", ">", $seqpath."feature.add", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "cat",  $seqpath.".trainfeature.addaccpro", $seqpath.".testfeature.addaccpro", ">", $seqpath."feature.addaccpro", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "cat",  $seqpath.".trainfeature.adddisopred", $seqpath.".testfeature.adddisopred", ">", $seqpath."feature.adddisopred", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
$args = join ' ', "cat",  $seqpath.".trainfeature.addpsipred", $seqpath.".testfeature.addpsipred", ">", $seqpath."feature.addpsipred", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
sub myrand()
{
	my %sns = ();
	my $no = 0;
	my $range = int($_[0]);
	my $num = $_[1];
	
	for(my $ii = 0; $ii < $range; $ii++)
	{
		$sns{"$ii"} = 0;
	}

	for(my $i = 0; $i < $num; $i++)
	{
		do
		{
			$no = rand($range);
			$no = int($no);
		}while($sns{"$no"} == 1);

		$sns{"$no"} = 1;
		push(@myrand, $no);
	}

}
