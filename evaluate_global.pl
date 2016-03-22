#! /usr/bin/perl -w

my $global_file = "/prosper/yanan/transfer-learning/db70/global.feature";
open(G_FEA, $global_file) or die "Can't open the file!\n";
my %global_feature;
my $line;
while($line = <G_FEA>)
{
    if($line =~ m/^(\d*)\s*(\d*)\s*\d/)
    {
#        print "$1\t$2\n";
        $global_feature{$1} = $2;
    }
}
close G_FEA;


my $path = "/prosper/yanan/transfer-learning/db70/source/*.FC11";
my @dir = glob($path);
my $new_file;
foreach(@dir)
{
    $new_file = $_.".new";
    open(NEW, ">$new_file") or die "Can't open/create new file\n";
    open(FILE, $_) or die "Can't open the file!\n";
    my $temp_str;    
    while($line = <FILE>)
    {
        if($line =~ m/^([-+1]{2}).*/)
        {
            $temp_str = $1;
#            print "$1\n";
        }
    
        for my $key (sort {$a <=> $b} keys %global_feature)
        {
            if($line =~ m/.*$global_feature{$key}:([-.0-9]{1,10})\s*.*/)
            {
               # print "$1\n";
                $temp_str .= "\t".$key.":".$1;
            }           
        }

        $temp_str .= "\n";

        print NEW "$temp_str";


    }
}

close FILE;
close NEW;
