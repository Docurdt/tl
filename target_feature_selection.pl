#! /usr/bin/perl -w

my $path = "/prosper/yanan/transfer-learning/db70/target/*.addseq";
my @dir = glob($path);

foreach(@dir)
{
    my $feature_list = $_.".train.FC11.ranked.top150";
    my $train_file = $_.".train.FC11";
    my $test_file = $_.".test.FC11";

    open(LIST, $feature_list) or die "Can't open the file\n";
        
    my @feature;
    my $line;
    while($line = <LIST>)
    {
        chomp($line);
        print "$line\n";
        push(@feature, $line);
    }

    my $auc_file = $test_file.".auc";
    open(AUC, ">$auc_file") or die "Can't create the file\n";

    foreach my $i (0 .. $#feature)
    {
        my $ii;
        
        my $train_file_new = $train_file.".".$i;
        my $test_file_new = $test_file.".".$i;

        open(TRAIN, $train_file) or die "Can't open the file\n";
        open(TEST, $test_file) or die "Can't open the file\n";
        open(TRAIN_NEW, ">$train_file_new") or die "Can't open the file\n";
        open(TEST_NEW, ">$test_file_new") or die "Can't open the file\n";

        #extraction for train file                
        while($line = <TRAIN>)
        { 
            my $tmp_str; 
            chomp($line);

            if($line =~ m/^([-+1]{2}).*/)
            {
                $tmp_str = $1;
            }

            for($ii=0; $ii <= $i; $ii++)
            {
                if($line =~ m/.*\s*$feature[$ii]:([-.0-9]{1,10})\s*.*/)
                {
                    $tmp_str .= "\t".($ii+1).":".$1;
                }
            }

            $tmp_str .= "\n";
            print TRAIN_NEW "$tmp_str";
            #print "index is: $i\t$ii\n";
        }


        #extraction for test file                
        while($line = <TEST>)
        { 
            my $tmp_str; 
            chomp($line);

            if($line =~ m/^([-+1]{2}).*/)
            {
                $tmp_str = $1;
            }

            for($ii=0; $ii <= $i; $ii++)
            {
                if($line =~ m/.*\s*$feature[$ii]:([-.0-9]{1,10})\s*.*/)
                {
                    $tmp_str .= "\t".($ii+1).":".$1;
                }
            }

            $tmp_str .= "\n";
            print TEST_NEW "$tmp_str";
            #print "index is: $i\t$ii\n";
        }
        



        close TRAIN;
        close TRAIN_NEW;
        close TEST;
        close TEST_NEW;
    }




}
