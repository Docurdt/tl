#! /usr/bin/perl -w

my $path = "../original-data/*.fasta";
my @dir = glob($path);

foreach(@dir)
{
    open(FILE, $_) or die "Can't open the file:$!\n";
    my $line;
    #print "$_\n";
    if($_ =~ m/^.*\/.*\/(.{7}).*/)
    {
        my $protease_name = $1;
        print "$protease_name\n";
        while($line = <FILE>)
        {
            if($line =~ m/^>.*/)
            {
                
            }
        }
    }
    close FILE;
}
