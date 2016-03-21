#! /usr/bin/perl -w
# merge MMP substrates into one file;
my $path = "../original-data/*.fasta";
my @dir = glob($path);

my $MMP_family = "../2-step/MMP.fasta";
unless (-e $MMP_family)
{
    open(MMP,">$MMP_family") or die "Couldn't open $outname1:$!";
}
else
{
    open(MMP,">$MMP_family") or die "Couldn't open $outname1:$!";
}

foreach(@dir)
{
    open(FILE, $_) or die "Can't open the file:$!\n";
    my $line;
    #print "$_\n";
    if($_ =~ m/^.*\/.*\/(.{7}).*/)
    {
        my $protease_name = $1;
        my $new_file = "../2-step/".$1.".fasta";
        unless (-e $new_file)
        {
            open(OUTFILE1,">$new_file") or die "Couldn't open $outname1:$!";
        }
        else
        {
            open(OUTFILE1,">$new_file") or die "Couldn't open $outname1:$!";
        }
        print "$protease_name\n";
        while($line = <FILE>)
        {
            print OUTFILE1 $line;
            print MMP $line;
        }
        close OUTFILE1;
    }
    close FILE;
}
close MMP;


# cd-hit;
`~/tools/cd-hit/cd-hit -i ../2-step/MMP.fasta -o ../2-step/MMP-db70.fasta -c 0.7 -n 5`;
