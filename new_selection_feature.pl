#! /usr/bin/perl -w
#input

my $inputfile = $ARGV[0];
my $feature_num = $ARGV[1];

my $trainfile = $inputfile.".train.FC11";
my $testfile = $inputfile.".test.FC11";
my $rankfile = $trainfile.".ranked";

my $workpath = "/home/wangyanan/pop_proteases/";

if($ARGV[0] =~ m/(^.*\/)([-0-9A-Za-z.]*)$/)
{
	$workpath = $1;
}








#进行格式转换
my $args = join ' ', "/home/wangyanan/upload_src/selection_feature/format_convert2csv.pl $trainfile", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
#mrmr/weka

#由于C++中copen函数对输入的文件名长度有限制，所以需要重新命名
$args = join ' ', "cp $trainfile.csv temp_feature.csv", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

print "Feature Selecting...\n";
$args = join ' ', "/home/wangyanan/mrmr -i temp_feature.csv -n $feature_num >$rankfile", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

$args = join ' ', "rm temp_feature.csv", "\n";
system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

#读取特征排序
open(FEATURE_FILE, $rankfile) or die "Can't open the file $rankfile:$!\n";
my @feature_name;
my @feature_score;
my $temp_feature;

my $i = 0;
for($i = 0; $i < 109; $i++)
{
    $temp_feature = <FEATURE_FILE>;
}
while($temp_feature = <FEATURE_FILE>)
{
    chomp($temp_feature);
#    print "$temp_feature\n";

    if($temp_feature =~ m/^[0-9]{1,3}\s*([0-9]{1,4})\s*[v0-9]{2,5}\s*([-.0-9]{5,7})/)
    {
	    push @feature_name, $1;
        push @feature_score, $2;
 #       print "$1\t$2\n";
    }
}
close FEATURE_FILE;

#对score排序 冒泡排序
my $ii = 1;
my $jj = 1;
my $temp_str;
my $temp_score;
for($ii = 0; $ii < $feature_num-1; $ii ++)
{
    for($jj = $ii + 1; $jj < $feature_num; $jj ++)
    {
        if($feature_score[$ii] < $feature_score[$jj])
        {
            $temp_str = $feature_name[$ii];
            $temp_score = $feature_score[$ii];

            $feature_name[$ii] = $feature_name[$jj];
            $feature_score[$ii] = $feature_score[$jj];

            $feature_name[$jj] = $temp_str;
            $feature_score[$jj] = $temp_score;
        }
    }
}

#按排序循环增加特征数量  需要同时处理训练数据和测试数据
my $auc_file = $inputfile.".auc";
unless (-e $auc_file)
{
	# print "File not found.then create it\n";
    #创建文件并写入
    open(AUC_FILE,">$auc_file") or die "Couldn't open $auc_file:$!";
}
else
{
    open(AUC_FILE,">$auc_file") or die "Couldn't open $auc_file:$!";
    # print "File found.\n";
}




my @auc = ();
my $auc_temp1 = 0;
my $auc_temp2 = 0;
my $temp2_file;
my $temp1_file;
my $temp_name;
my $temp_model;

my $optimal_predict;
my $optimal_feature;
my $optimal_model;
my $optimal_trainset;

for($ii = 5; $ii <= $feature_num; $ii = $ii + 5)
{
	open(TRAIN_FILE, $trainfile) or die "Can't open the train file:$!\n";
	open(TEST_FILE, $testfile) or die "Can't open the test file:$!\n";
 
    $temp1_file = $trainfile.".".$ii;
    unless (-e $temp1_file)
    {
       # print "File not found.then create it\n";
        #创建文件并写入
        open(TEMP1_FILE,">$temp1_file") or die "Couldn't open $temp1_file:$!";
    }
    else
    {
        open(TEMP1_FILE,">$temp1_file") or die "Couldn't open $temp1_file:$!";
         # print "File found.\n";
    }

    $temp2_file = $testfile.".".$ii;
    unless (-e $temp2_file)
    {
       # print "File not found.then create it\n";
        #创建文件并写入
        open(TEMP2_FILE,">$temp2_file") or die "Couldn't open $temp2_file:$!";
    }
    else
    {
        open(TEMP2_FILE,">$temp2_file") or die "Couldn't open $temp2_file:$!";
         # print "File found.\n";
    }


         #创建优化特征文件，从全特征文件中提取目标特征，并生成训练集和测试集
    my @temp_line;
	my $myindex;
	my $temp_line2;
    while(<TRAIN_FILE>)
    {
         chomp;
         @temp_line = split;
         print TEMP1_FILE $temp_line[0]."\t";
         for($jj = 0; $jj < $ii; $jj++)
         {
             $myindex = $feature_name[$jj];
			# print "$myindex\t";
             $temp_line2 = $temp_line[$myindex];
			 $temp_line2 =~ s/$myindex/$jj+1/e;
			 print TEMP1_FILE "$temp_line2\t";
         }
         print TEMP1_FILE "\n";

     }

     while(<TEST_FILE>)
     {
         chomp;
         @temp_line = split;
         print TEMP2_FILE $temp_line[0]."\t";
         for($jj = 0; $jj < $ii; $jj++)
         {
             $myindex = $feature_name[$jj];
			# print "$myindex\t";
             $temp_line2 = $temp_line[$myindex];
			 $temp_line2 =~ s/$myindex/$jj+1/e;
			 print TEMP2_FILE "$temp_line2\t";
         }
         print TEMP2_FILE "\n";
     }


    close TRAIN_FILE;
    close TEST_FILE;
	close TEMP1_FILE;
	close TEMP2_FILE;

    #调用svm优化参数；
    #训练模型；
    #预测独立测试集；

	my $args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -s $temp1_file.range $temp1_file > $temp1_file.scale", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -r $temp1_file.range $temp2_file > $temp2_file.scale", "\n";
	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	#optimize, train and test;
	$args = join ' ', "python /home/wangyanan/svm/libsvm-3.20/tools/gridregression.py -svmtrain /home/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 -h 0 $temp1_file.scale>$temp1_file.parameter", "\n";
	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	my $paraline;
	my $paraline2;
	open(PARAFILE, "$temp1_file.parameter") or die "Can't open the file:$!/n";
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
		$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $temp1_file.scale", "\n";
	    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		$args = join ' ', "mv *.model $workpath", "\n";
		system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-predict $temp1_file.scale $temp1_file.scale.model $temp1_file.predict", "\n";
	 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
		
		$temp_name = $temp1_file.".predict";
		$temp_model = $temp1_file.".scale.model";
		$auc_temp1 = `/home/wangyanan/upload_src/selection_feature/auc_roc.R $temp1_file $temp_name`; #调用rocr计算auc
		print "$auc_temp1\n";
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
