#! /usr/bin/perl -w
	

my $path = "/prosper/yanan/transfer-learning/db70/source/*.new";
my @dir = glob($path);

my $args;

foreach(@dir)
{
        
    my $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -s $_.range $_ > $_.scale", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";


#	$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -r $temp1_file.range $temp2_file > $temp2_file.scale", "\n";
#	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	#optimize, train and test;
	$args = join ' ', "python /prosper/yanan/wangyanan/svm/libsvm-3.20/tools/gridregression.py -svmtrain /prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 -h 0 $_.scale>$_.parameter", "\n";
	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";



	my $paraline;
	my $paraline2;
	open(PARAFILE, "$_.parameter") or die "Can't open the file:$!/n";
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
		$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $_.scale", "\n";
	    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		$args = join ' ', "mv *.model /prosper/yanan/transfer-learning/db70/source/", "\n";
		system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-predict $_.scale $_.scale.model $_.predict", "\n";
	 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		
		my $temp_name = $_.".predict";
		my $temp_model = $_.".scale.model";
		my $auc_temp1 = `/prosper/yanan/wangyanan/upload_src/selection_feature/auc_roc.R $_ $temp_name`; #调用rocr计算auc
		print "$auc_temp1\n";
    }
}



=pod

		if($auc_temp1 >= $auc_temp2)
		{
			$auc_temp2 = $auc_temp1;
			$optimal_predict = $temp_name;
			$optimal_feature = $temp2_file.".scale";
			$optimal_model = $temp_model;
			$optimal_trainset = $temp1_file.".predict";		


			$auc_temp2 = $auc_temp1;
		#	last;
		}

		push @auc, $auc_temp1;
	}
	else
	{
		print "There is no parameters!\n";
	}



}

my $optimal_predict1 = $testfile.".optimal.predict";
my $optimal_feature1 = $testfile.".optimal.label";
my $optimal_model1 = $trainfile.".optimal.model";
my $optimal_trainset1 = $trainfile.".optimal.train.predict";

`cp $optimal_predict $optimal_predict1`;
`cp $optimal_feature $optimal_feature1`;
`cp $optimal_model $optimal_model1`;
`cp $optimal_trainset $optimal_trainset1`;



$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-predict $optimal_feature $optimal_model $optimal_predict1", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";


foreach(@auc)
{
	print AUC_FILE $_;
}
close AUC_FILE;
=cut
