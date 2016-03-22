#! /usr/bin/perl -w
use 5.014;
use strict;

no if ($] >= 5.018), 'warnings' => 'experimental'; # hide the warnings of the experimental


my @feature_name = ();
my @temp = ();

push @feature_name, "cksaap.code";
push @feature_name, "binary.code";
push @feature_name, "pssm.code";
push @feature_name, "blosum.code";
#push @feature_name, "knn.code";
push @feature_name, "aaindex.code";

push @feature_name, "aac.code";
#push @feature_name, "aaindex.code";
push @feature_name, "diso.code";
push @feature_name, "chr.code";

#push @feature_name, "acc.code";
#push @feature_name, "psi.code";


#foreach (@feature_name)
#{
#  print "$_\n";
#}
my $i = 0;
my $j = 0;
my $k = 0;
my $l = 0;
my $m = 0;
my $n = 0;
my $p = 0;
my $q = 0;

my $name_protease = $ARGV[1];
my $number_feature = $ARGV[0];


#print "the input name is: $ARGV[1]\n";
#$name_protease =~ s/\s/\\ /g;

#if($ARGV[1] =~ m/.*\/([-0-9A-Za-z.]*)$/)
#{
#		print "$1\n";
#		$name_protease = $1;
#}

#my $name_protease_train = $name_protease.".train";
#my $name_protease_test = $name_protease.".test";

my $name_protease_train = $name_protease;
my $name_protease_test = $name_protease;

my $tempfile1;
my $tempfile2;
my $tempfile3;
my $tempfile4;
my $tempfile5;
my $tempfile6;
my $tempfile7;
my $tempfile8;
my $tempfile9;
my $tempfile10;
my $tempfile11;



my $outfile;
my $testfile;

given($number_feature)
{
  when(1)
  {
    print "1 feature has been chosen\n";
	my $iitemp = 0;
    for($iitemp = 0; $iitemp < 6; $iitemp++)
    {
      print "$feature_name[$iitemp]\n";

      #open;
      $tempfile1 = $name_protease_train.".".$feature_name[$iitemp];
	  $tempfile2 = $name_protease_test.".".$feature_name[$iitemp];
      $outfile = $tempfile1;
	  $testfile = $tempfile2;
      #subset;
      $outfile =~ s/\s/\\ /g;
      #scale;
    my $args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-scale -y -1 1 -l -1 -u 1 -s $outfile.range $outfile > $outfile.scale", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    $args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-scale -y -1 1 -l -1 -u 1 -r $outfile.range $testfile > $testfile.scale", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    #optimize, train and test;
    $args = join ' ', "python /home/wangyanan/svm/libsvm-3.20/tools/gridregression.py -svmtrain /home/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 $outfile.scale>$outfile.parameter", "\n";
    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

	my $paraline;
	my $paraline2;
    open(PARAFILE, "$outfile.parameter") or die "Can't open the file:$!/n";
	while($paraline = <PARAFILE>)
	{
		$paraline2 = $paraline;
	}
	chomp($paraline2);
	print "$paraline2\n";
 	my $c = 0;
	my $g = 0;
	my $p = 0;
 	if($paraline2 =~ m/([-+.0-9]*)\s*([-+.0-9]*)\s*([-+.0-9]*)\s*.*/)
	{
			$c = sprintf("%f",$1);
			$g = sprintf("%f",$2);
			$p = sprintf("%f",$3);

			print "$c\t$g\t$p\n";
  			$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $outfile.scale", "\n";
  		    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
			$args = join ' ', "mv *.model /home/wangyanan/pop_proteases", "\n";
			system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
  			$args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-predict $testfile.scale $outfile.scale.model $testfile.predict", "\n";
 		 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
            $args = join ' ', "/home/wangyanan/svm/libsvm-3.20/svm-predict $outfile.scale $outfile.scale.model $outfile.predict", "\n";
 		 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
	}
	else
	{
			print "There is no parameters!\n";
	}

    }
  }

  when(11)
  {
    print "11 features have been chosen\n";
    print "@feature_name"."\n";
	my @temp1 = @feature_name;

    $tempfile1 = $name_protease_train.".".$temp1[0];
    $tempfile2 = $name_protease_train.".".$temp1[1];
    $tempfile3 = $name_protease_train.".".$temp1[2];
    $tempfile4 = $name_protease_train.".".$temp1[3];
    $tempfile5 = $name_protease_train.".".$temp1[4];
    $tempfile6 = $name_protease_train.".".$temp1[5];
    $tempfile7 = $name_protease_train.".".$temp1[6];
	$tempfile8 = $name_protease_train.".".$temp1[7];
    #$tempfile9 = $name_protease_train.".".$temp1[8];
    #$tempfile10 = $name_protease_train.".".$temp1[9];
    #$tempfile11 = $name_protease_train.".".$temp1[10];

    open( FILE1, $tempfile1) or die "Can't open the file:$!/n";
    open( FILE2, $tempfile2) or die "Can't open the file:$!/n";
    open( FILE3, $tempfile3) or die "Can't open the file:$!/n";
    open( FILE4, $tempfile4) or die "Can't open the file:$!/n";
    open( FILE5, $tempfile5) or die "Can't open the file:$!/n";
    open( FILE6, $tempfile6) or die "Can't open the file:$!/n";
    open( FILE7, $tempfile7) or die "Can't open the file:$!/n";
    open( FILE8, $tempfile8) or die "Can't open the file:$!/n";
    #open( FILE9, $tempfile9) or die "Can't open the file:$!/n";
    #open( FILE10, $tempfile10) or die "Can't open the file:$!/n";
    #open( FILE11, $tempfile11) or die "Can't open the file:$!/n";
      #create;.$i$j.FC2
    $outfile = $name_protease_train.".FC11";
    unless (-e $outfile)
    {
       # print "File not found.then create it\n";
        #创建文件并写入
        open(OUTFILE,">$outfile") or die "Couldn't open $outfile:$!";
    }
    else
    {
        open(OUTFILE,">$outfile") or die "Couldn't open $outfile:$!";
         # print "File found.\n";
    }


	$tempfile1 = $name_protease_test.".".$temp1[0];
    $tempfile2 = $name_protease_test.".".$temp1[1];
    $tempfile3 = $name_protease_test.".".$temp1[2];
    $tempfile4 = $name_protease_test.".".$temp1[3];
    $tempfile5 = $name_protease_test.".".$temp1[4];
    $tempfile6 = $name_protease_test.".".$temp1[5];
    $tempfile7 = $name_protease_test.".".$temp1[6];
	$tempfile8 = $name_protease_test.".".$temp1[7];
    #$tempfile9 = $name_protease_test.".".$temp1[8];
    #$tempfile10 = $name_protease_test.".".$temp1[9];
    #$tempfile11 = $name_protease_test.".".$temp1[10];

    open( FILE12, $tempfile1) or die "Can't open the file:$!/n";
    open( FILE13, $tempfile2) or die "Can't open the file:$!/n";
    open( FILE14, $tempfile3) or die "Can't open the file:$!/n";
    open( FILE15, $tempfile4) or die "Can't open the file:$!/n";
    open( FILE16, $tempfile5) or die "Can't open the file:$!/n";
    open( FILE17, $tempfile6) or die "Can't open the file:$!/n";
    open( FILE18, $tempfile7) or die "Can't open the file:$!/n";
    open( FILE19, $tempfile8) or die "Can't open the file:$!/n";
    #open( FILE20, $tempfile9) or die "Can't open the file:$!/n";
    #open( FILE21, $tempfile10) or die "Can't open the file:$!/n";
   # open( FILE22, $tempfile11) or die "Can't open the file:$!/n";
      #create;.$i$j.FC2
    $testfile = $name_protease_test.".FC11";
    unless (-e $testfile)
    {
       # print "File not found.then create it\n";
        #创建文件并写入
        open(TESTFILE,">$testfile") or die "Couldn't open $testfile:$!";
    }
    else
    {
        open(TESTFILE,">$testfile") or die "Couldn't open $testfile:$!";
         # print "File found.\n";
    }


      #read and write
      my $templine1;
      my $templine2;
      my $templine3;
      my $templine4;
      my $templine5;
      my $templine6;
      my $templine7;
      my $templine8;
    #  my $templine9;
    #  my $templine10;
    #  my $templine11;
	  my $finalline;

      my $label;
      my $index;

      while($templine1 = <FILE1>)
      {
          $templine2 = <FILE2>;
          $templine3 = <FILE3>;
          $templine4 = <FILE4>;
          $templine5 = <FILE5>;
          $templine6 = <FILE6>;
          $templine7 = <FILE7>;
          $templine8 = <FILE8>;
	#	  $templine9 = <FILE9>;
#		  $templine10 = <FILE10>;
#		  $templine11 = <FILE11>;
          chomp($templine1);
          chomp($templine2);
          chomp($templine3);
          chomp($templine4);
          chomp($templine5);
          chomp($templine6);
          chomp($templine7);
          chomp($templine8);
#		  chomp($templine9);
#		  chomp($templine10);
#		  chomp($templine11);
          $finalline = $templine1;

          if($finalline =~ m/\s*(\d*):[-+.\d ]*$/)
          {
              #$label = $1;
              $index = $1;
              #print "$index\n";
          }

          $templine2 =~ s/^[-+1 ]{4}//;
          $templine2 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine2;

          $templine3 =~ s/^[-+1 ]{4}//;
          $templine3 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine3;

          $templine4 =~ s/^[-+1 ]{4}//;
          $templine4 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine4;

          $templine5 =~ s/^[-+1 ]{4}//;
          $templine5 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine5;

          $templine6 =~ s/^[-+1 ]{4}//;
          $templine6 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine6;

          $templine7 =~ s/^[-+1 ]{4}//;
          $templine7 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine7;

          $templine8 =~ s/^[-+1 ]{4}//;
          $templine8 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine8;

#		  $templine9 =~ s/^[-+1 ]{4}//;
#          $templine9 =~ s/\d*:/int($index+=1).":"/eg;
#          $finalline = $finalline.$templine9;

 #         $templine10 =~ s/^[-+1 ]{4}//;
 #         $templine10 =~ s/\d*:/int($index+=1).":"/eg;
 #         $finalline = $finalline.$templine10;

  #        $templine11 =~ s/^[-+1 ]{4}//;
  #        $templine11 =~ s/\d*:/int($index+=1).":"/eg;
  #        $finalline = $finalline.$templine11;

          print OUTFILE "$finalline\n";
      }

      close FILE1;
      close FILE2;
      close FILE3;
      close FILE4;
      close FILE5;
      close FILE6;
      close FILE7;
      close FILE8;
#	  close FILE9;
#	  close FILE10;
#	  close FILE11;
      close OUTFILE;

	  while($templine1 = <FILE12>)
      {
          $templine2 = <FILE13>;
          $templine3 = <FILE14>;
          $templine4 = <FILE15>;
          $templine5 = <FILE16>;
          $templine6 = <FILE17>;
          $templine7 = <FILE18>;
          $templine8 = <FILE19>;
#		  $tempfile9 = <FILE20>;
#		  $tempfile10 = <FILE21>;
#		  $tempfile11 = <FILE22>;
          chomp($templine1);
          chomp($templine2);
          chomp($templine3);
          chomp($templine4);
          chomp($templine5);
          chomp($templine6);
          chomp($templine7);
          chomp($templine8);
#		  chomp($tempfile9);
#		  chomp($tempfile10);
#		  chomp($tempfile11);
          $finalline = $templine1;

          if($finalline =~ m/\s*(\d*):[-+.\d ]*$/)
          {
              #$label = $1;
              $index = $1;
              #print "$index\n";
          }

          $templine2 =~ s/^[-+1 ]{4}//;
          $templine2 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine2;

          $templine3 =~ s/^[-+1 ]{4}//;
          $templine3 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine3;

          $templine4 =~ s/^[-+1 ]{4}//;
          $templine4 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine4;

          $templine5 =~ s/^[-+1 ]{4}//;
          $templine5 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine5;

          $templine6 =~ s/^[-+1 ]{4}//;
          $templine6 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine6;

          $templine7 =~ s/^[-+1 ]{4}//;
          $templine7 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine7;

          $templine8 =~ s/^[-+1 ]{4}//;
          $templine8 =~ s/\d*:/int($index+=1).":"/eg;
          $finalline = $finalline.$templine8;

#		  $templine9 =~ s/^[-+1 ]{4}//;
#          $templine9 =~ s/\d*:/int($index+=1).":"/eg;
#          $finalline = $finalline.$templine9;

#          $templine10 =~ s/^[-+1 ]{4}//;
#          $templine10 =~ s/\d*:/int($index+=1).":"/eg;
#          $finalline = $finalline.$templine10;

#          $templine11 =~ s/^[-+1 ]{4}//;
#          $templine11 =~ s/\d*:/int($index+=1).":"/eg;
#          $finalline = $finalline.$templine11;

          print TESTFILE "$finalline\n";
      }

      close FILE19;
#      close FILE20;
#      close FILE21;
#      close FILE22;
      close FILE12;
      close FILE13;
      close FILE14;
      close FILE15;
      close FILE16;
      close FILE17;
	  close FILE18;
      close TESTFILE;

      #scale;
    #my $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -s $outfile.range $outfile > $outfile.scale", "\n";
    #system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    #$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-scale -y 0 1 -l 0 -u 1 -r $outfile.range $testfile > $testfile.scale", "\n";
    #system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

    #optimize, train and test;
    #$args = join ' ', "python /prosper/yanan/wangyanan/svm/libsvm-3.20/tools/gridregression.py -svmtrain /prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -gnuplot /usr/local/bin/gnuplot -log2c -10,10,1 -log2g -10,10,1 -log2p -10,10,1 -v 5 -s 3 -t 2 $outfile.scale>$outfile.parameter", "\n";
    #system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

#	my $paraline;
#	my $paraline2;
  #  open(PARAFILE, "$outfile.parameter") or die "Can't open the file:$!/n";
#	while($paraline = <PARAFILE>)
#	{
#		$paraline2 = $paraline;
#	}
 #   close PARAFILE;
#	chomp($paraline2);
#	print "$paraline2\n";
# 	my $c = 0;
#	my $g = 0;
#	my $p = 0;
 #	if($paraline2 =~ m/\s*([-+.0-9]*)\s*([-+.0-9]*)\s*([-+.0-9]*)\s*.*/)
#	{
#			$c = sprintf("%f",$1);
#			$g = sprintf("%f",$2);
#			$p = sprintf("%f",$3);

	#		print "$c\t$g\t$p\n";
  #			$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-train -s 3 -t 2 -c $c -g $g -p $p $outfile.scale", "\n";
  #		    system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
#			$args = join ' ', "mv *.model /home/wangyanan/pop_proteases", "\n";
#			system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
 # 			$args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-predict $testfile.scale $outfile.scale.model $testfile.predict", "\n";
 #		 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
  #          $args = join ' ', "/prosper/yanan/wangyanan/svm/libsvm-3.20/svm-predict $outfile.scale $outfile.scale.model $outfile.predict", "\n";
 #		 	system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";
#	}
#	else
#	{
#			print "There is no parameters!\n";
#	}


  }
  default
  {
    print "How many features would you like to choose? Please input it as the first argv!\n";
  }
}
