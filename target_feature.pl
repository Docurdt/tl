#! /usr/bin/perl -w

#my $inputfile = $ARGV[0];
#my $feature_num = $ARGV[1];

my $inputfile = "/prosper/yanan/transfer-learning/db70/target/*.FC11";
my $feature_num = 150;
my $args;
#my $trainfile = $inputfile.".FC11";
my @trainfile = glob($inputfile);


foreach(@trainfile)
{
    my $rankfile = $_.".ranked";

    print "$_\n";

    #进行格式转换
    $args = join ' ', "./format_convert2csv.pl $_", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    #由于C++中copen函数对输入的文件名长度有限制，所以需要重新命名
    $args = join ' ', "cp $_.csv temp_feature.csv", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    print "Feature Selecting...\n";
    #$args = join ' ', "/prosper/yanan/wangyanan/mrmr -i temp_feature.csv -n", "$feature_num >$rankfile", "\n";
    #system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    $args = join ' ', "rm temp_feature.csv", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

}



my $path = "/prosper/yanan/transfer-learning/db70/target/*.ranked";
my @dir = glob($path);

foreach(@dir)
{   
    my $feature_file = $_.".top150";
    open(TOP, ">$feature_file") or die "Can't create the file\n";
    #读取特征排序
    open(FEATURE_FILE, $_) or die "Can't open the file $_:$!\n";

    my $temp_feature;

    my $i = 0;
    while(1)
    {
        $temp_feature = <FEATURE_FILE>;
        chomp($temp_feature);
        if($temp_feature =~ m/.*mRMR\s*feature.*/)
        {last;}
    }
    while($temp_feature = <FEATURE_FILE>)
    {
        chomp($temp_feature);

        if($temp_feature =~ m/^[0-9]{1,3}\s*([0-9]{1,4})\s*[v0-9]{2,5}\s*([-.0-9]{5,7})/)
        {
            print TOP "$1\n";
        }
    }
    close TOP;
    close FEATURE_FILE;
}


