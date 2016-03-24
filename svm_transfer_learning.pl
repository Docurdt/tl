#! /usr/bin/perl -w
	

my $path = "/prosper/yanan/transfer-learning/db70/target/*.addseq";
my @dir = glob($path);

my $args;

foreach(@dir)
{
    my $orifile = $_;

    my $auc_file = $orifile.".test.FC11.transfer.auc";
    open(AUC, ">$auc_file") or die "Can't create\n";
    
    my $global_file = "/prosper/yanan/transfer-learning/db70/global.feature";
    my $individual_file = $orifile.".train.FC11.ranked.top150";

    my $line;
    undef @global_feature;
    undef @individual_feature;
    undef @unique_feature;
    
    open(GLOBAL, $global_file) or die "Can't open the file: $global_file\n";
    while($line = <GLOBAL>)
    {
        if($line =~ m/^\d*\s*(\d*):.*/)
        {
            push @global_feature, $1;
        }
    }
    close GLOBAL;
    
    open(INDIVI, $individual_file) or die "Can't open the file:$individual_file\n";
    while($line = <INDIVI>)
    {
        if($line =~ m/^(\d*).*/)
        {
            push @individual_feature, $1;
        }
    }
    close INDIVI;
#extract unique features;
    my $flag = 0;
    foreach(@individual_feature)
    {
        my $tmp_str = $_;
        foreach(@global_feature)
        {
            if ($tmp_str eq $_)
            {$flag = 1;}
        }
        if($flag == 0)
        {
            push @unique_feature, $tmp_str;
        }
        $flag = 0;
    }



    undef @final_feature;

    foreach(@unique_feature)
    {
       # print "$i\t$unique_feature[$i]\n";
        push @final_feature, $_;
    }
  
    foreach my $i (0 .. $#global_feature)
    {
      #  print "$i\t$global_feature[$i]\n";
    }
    
    my $file_train = $orifile.".train.FC11";
    my $file_test = $orifile.".test.FC11";
    
    my $train_input = $orifile.".train_input";
    my $test_input = $orifile.".test_input";


    foreach my $i (0 .. $#final_feature)
    {
        open(TRAIN, $file_train) or die "Can't open the train file\n";
        open(TEST, $file_test) or die "Can't open the test file\n";

        open(TRAIN_INPUT, ">$train_input") or die "Can't create the tmp_input file\n";
        open(TEST_INPUT, ">$test_input") or die "Can't create the tmp_input file\n";
        #test
        $i = 49;
        #test

        while($line = <TRAIN>)
        {
            my $tmp_input;
            if($line =~ m/^([-+1]{2}).*/)
            {
                $tmp_input = $1;
            }
            for(my $ii = 0; $ii <= $i; $ii ++)
            {
                if($line =~ m/.*$final_feature[$ii]:([-.0-9]{1,10})\s*.*/)
                {
                    # print "$1\n";
                    $tmp_input .= "\t".($ii+1).":".$1;
                }
            }
            $tmp_input .= "\n";
            print TRAIN_INPUT "$tmp_input";
        }        
        close TRAIN_INPUT;
        close TRAIN;

        while($line = <TEST>)
        {
            my $tmp_input;
            if($line =~ m/^([-+1]{2}).*/)
            {
                $tmp_input = $1;
            }
            for(my $ii = 0; $ii <= $i; $ii ++)
            {
                if($line =~ m/.*$final_feature[$ii]:([-.0-9]{1,10})\s*.*/)
                {
                    # print "$1\n";
                    $tmp_input .= "\t".($ii+1).":".$1;
                }
            }
            $tmp_input .= "\n";
            print TEST_INPUT "$tmp_input";
        }        
        close TEST_INPUT;
        close TEST;

        if(($i >= 49) && ($i % 5 == 4))        
        {
            $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -s $file_train.T.$i.range $train_input > $file_train.T.$i.scale", "\n";
            system($args) == 0 or die "[$0] ERROR: $args failed: $?\n"; 
 
            $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -r $file_train.T.$i.range $test_input > $file_test.T.$i.scale", "\n";
            system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
 
            #optimize, train and test;
            $args = join ' ', "python /prosper/yanan/wangyanan/svm/libsvm-3.20/tools/grid regression.py -svmtrain /prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 -h 0 $file_train.T.$i.scale>$file_train.T.$i.parameter", "\n";
            system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

            my $paraline;
            my $paraline2;
            open(PARAFILE, "$file_train.T.$i.parameter") or die "Can't open the file:$!/n";
            while($paraline = <PARAFILE>)
            {
                $paraline2 = $paraline;
            }
            close PARAFILE;
            chomp($paraline2);
    #   print "$paraline2\n";
            my $c = 0;
            my $g = 0;
            my $p = 0;

            if($paraline2 =~ m/\s*([-+.0-9]*)\s*([-+.0-9]*)\s*([-+.0-9]*)\s*.*/)
            {
                $c = sprintf("%f",$1);
                $g = sprintf("%f",$2);
                $p = sprintf("%f",$3);
                print "$c\t$g\t$p\n";
                $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $file_train.T.$i.scale", "\n";
                system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
                $args = join ' ', "mv *.model /prosper/yanan/transfer-learning/db70/target/", "\n";
                system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
                $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-predict $file_test.T.$i.scale $file_train.T.$i.scale.model $file_test.T.$i.predict", "\n";
                system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
   
                my $temp_name = $file_test.T.$i.".predict";
                my $auc_temp1 = `/prosper/yanan/wangyanan/upload_src/selection_feature/auc_roc.R $test_input $temp_name`; #>调用rocr计算auc
                print AUC "$auc_temp1\n";
            }
            $i += 5;

        }
 

    }

    close AUC;
   # last;
}


