#! /usr/bin/perl -w
my $input = $ARGV[0];
my $outfile = $input.".csv";

open(INPUT, "<$input") or die "Can't open the inut file:$!\n";

unless (-e $outfile)
{
    print "File not found.then create it\n";
    #创建文件并写入
    open(OUTFILE,">$outfile") or die "Couldn't open $outfile:$!";
}
else
{
    open(OUTFILE,">$outfile") or die "Couldn't open $outfile:$!";
    print "File found.\n";
}

my $class_line;
$class_line = "class";
my $ii;
for($ii = 1; $ii <= 4461; $ii++)
{
    $class_line = "$class_line,v$ii";
}
#$class_line = $class_line."\n";

print OUTFILE "$class_line\n";



my $temp_line;
while($temp_line = <INPUT>)
{
    $temp_line =~ s/\s{1,4}\d{1,5}\:/,/g;
	$temp_line =~ s/\s//g;
	print ".";
    print OUTFILE "$temp_line\n";
}


close INPUT;
close OUTFILE;
