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


