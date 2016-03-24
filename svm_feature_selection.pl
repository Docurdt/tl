#! /usr/bin/perl -w
	

my $path = "/prosper/yanan/transfer-learning/db70/target/*.addseq";
my @dir = glob($path);

my $args;

foreach(@dir)
{
    my $orifile = $_;

    my $auc_file = $orifile.".test.FC11.auc";
    open(AUC, ">$auc_file") or die "Can't create\n";

    for(my $i = 4; $i < 150; $i+=5)
    {
        my $train_file = $orifile.".train.FC11.".$i;
        my $test_file = $orifile.".test.FC11.".$i;
        print "$train_file\n";
        $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -s $train_file.range $train_file > $train_file.scale", "\n";
        system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";


    	$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -r $train_file.range $test_file > $test_file.scale", "\n";
    	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	#optimize, train and test;
	    $args = join ' ', "python /prosper/yanan/wangyanan/svm/libsvm-3.20/tools/gridregression.py -svmtrain /prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 -h 0 $train_file.scale>$train_file.parameter", "\n";
	    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";



	    my $paraline;
	    my $paraline2;
	    open(PARAFILE, "$train_file.parameter") or die "Can't open the file:$!/n";
	    while($paraline = <PARAFILE>)
	    {
		    $paraline2 = $paraline;
	    }
	    close PARAFILE;
	    chomp($paraline2);
#	print "$paraline2\n";
	    my $c = 0;
	    my $g = 0;
	    my $p = 0;
	    if($paraline2 =~ m/\s*([-+.0-9]*)\s*([-+.0-9]*)\s*([-+.0-9]*)\s*.*/)
	    {
		    $c = sprintf("%f",$1);
		    $g = sprintf("%f",$2);
		    $p = sprintf("%f",$3);
		    print "$c\t$g\t$p\n";
		    $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $train_file.scale", "\n";
	        system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		    $args = join ' ', "mv *.model /prosper/yanan/transfer-learning/db70/target/", "\n";
		    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		    $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-predict $test_file.scale $train_file.scale.model $test_file.predict", "\n";
	 	    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		
		    my $temp_name = $test_file.".predict";
		    my $temp_model = $test_file.".scale.model";
		    my $auc_temp1 = `/prosper/yanan/wangyanan/upload_src/selection_feature/auc_roc.R $test_file $temp_name`; #调用rocr计算auc
		    print AUC "$auc_temp1\n";
        }
    }
    close AUC;
    last;
}


