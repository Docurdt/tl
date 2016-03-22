#! /usr/bin/perl -w

##############################################################
#功能描述：
# 用于提取测试序列中的正负样本，采用滑动窗口滑动遍历整个序列；
# 正负样本的提取窗口为16；
#
# 输入文件为*.add文件，输出为4个文件，分别对应序列、psipred、accpro、disopred。
##############################################################

use strict;

#$ARGV[0];#命令行参数
open( FILE, $ARGV[0]) or die "Can't open the file:$!/n";
my $slidingWinNumber = 16;
my $samplesfile = $ARGV[0]."seq";
my $samplesfile01 = $ARGV[0]."psipred";
my $samplesfile02 = $ARGV[0]."accpro";
my $samplesfile03 = $ARGV[0]."disopred";

my $negativeNum = 0;
my $positiveNum = 0;


my @myrand = ();
my @positiveSample = ();
my @negativeSample = ();
my $flag = 0;

unless (-e $samplesfile)
{
    print "File not found.then create it\n";
    #创建文件并写入
    open(SMPFILE,">$samplesfile") or die "Couldn't open $samplesfile:$!";
}
else
{
    open(SMPFILE,">$samplesfile") or die "Couldn't open $samplesfile:$!";
    print "File found.\n";
}

unless (-e $samplesfile01)
{
    print "File not found.then create it\n";
    #创建文件并写入
    open(SMPFILE01,">$samplesfile01") or die "Couldn't open $samplesfile01:$!";
}
else
{
    open(SMPFILE01,">$samplesfile01") or die "Couldn't open $samplesfile01:$!";
    print "File found.\n";
}

unless (-e $samplesfile02)
{
    print "File not found.then create it\n";
    #创建文件并写入
    open(SMPFILE02,">$samplesfile02") or die "Couldn't open $samplesfile02:$!";
}
else
{
    open(SMPFILE02,">$samplesfile02") or die "Couldn't open $samplesfile02:$!";
    print "File found.\n";
}

unless (-e $samplesfile03)
{
    print "File not found.then create it\n";
    #创建文件并写入
    open(SMPFILE03,">$samplesfile03") or die "Couldn't open $samplesfile03:$!";
}
else
{
    open(SMPFILE03,">$samplesfile03") or die "Couldn't open $samplesfile03:$!";
    print "File found.\n";
}

my $seqname;
my @site = ();
my $seqstr;
my $seqpsipred;
my $seqaccpro;
my $seqdisopred;
my $line;

while($line = <FILE>)
{
  if($line =~ m/^>(.*)\|(.*)$/)
  {
    $seqname = $1;
    #print "$1\n";
  }
  elsif($line =~ m/^site:(.*\|.*)$/)
  {
    push(@site, $1);
    #print "$1\n";
  }
  else
  {
    $seqstr = $line;
    chomp($seqstr);
    $seqpsipred = <FILE>;
    $seqaccpro = <FILE>;
    $seqdisopred = <FILE>;
#    print "this is a test\n$seqstr\n$seqpsipred\n$seqaccpro\n$seqdisopred\n";


    $negativeNum = 0;
    $positiveNum = 0;
    @myrand = ();
    @positiveSample = ();
    @negativeSample = ();
    $flag = 0;

    #提取正负样本
    &exSample();
    #清除序列相关数据
    $seqname = "";
    $seqstr = "";
    @site = ();
  }
}



sub exSample()
{
  #positive
  #print "This is the exSample!\n";
  my $len = rindex $seqstr."\$", "\$";
  #print "$len\n";

  foreach(@site)
  {
    $_ =~ m/^(.*)\|(.*)$/;
    print "$_\t $1 \t $2\n";

    my $p14 = $1;
    my $p41prime = $2;

    #print "before replace: $p14\t$p41prime\n";

    $p14 =~ s/\-/\[A-Z\]\{1\}/g;
    $p41prime =~ s/\-/\[A-Z\]\{1\}/g;

    #print "after replace: $p14\t$p41prime\n";

    #print "$p14 \t $p41prime\n";
    while($seqstr =~ m/$p14[A-Z]{0,2}$p41prime/g)
    {
      my $myseqfinal = $&;
      print "this is seq: $&\n";
      my $strpsipred;
      my $straccpro;
      my $strdisopred;
      my $mystrindex = index($seqstr, $&);
      if($mystrindex == 3)
      {
        $myseqfinal = substr($seqstr, 0, 15);
        chomp($myseqfinal);
        $myseqfinal = "0".$myseqfinal;
        $strpsipred = substr($seqpsipred, 0, 15);
        chomp($strpsipred);
        $strpsipred = "0".$strpsipred;
        $straccpro = substr($seqaccpro, 0, 15);
        chomp($straccpro);
        $straccpro = "0".$straccpro;
        $strdisopred = substr($seqdisopred, 0, 15);
        chomp($strdisopred);
        $strdisopred = "0".$strdisopred;
      }
      elsif($mystrindex == 2)
      {
        $myseqfinal = substr($seqstr, 0, 14);
        chomp($myseqfinal);
        $myseqfinal = "00".$myseqfinal;
        $strpsipred = substr($seqpsipred, 0, 14);
        chomp($strpsipred);
        $strpsipred = "00".$strpsipred;
        $straccpro = substr($seqaccpro, 0, 14);
        chomp($straccpro);
        $straccpro = "00".$straccpro;
        $strdisopred = substr($seqdisopred, 0, 14);
        chomp($strdisopred);
        $strdisopred = "00".$strdisopred;
      }
      elsif($mystrindex == 1)
      {
        $myseqfinal = substr($seqstr, 0, 13);
        chomp($myseqfinal);
        $myseqfinal = "000".$myseqfinal;
        $strpsipred = substr($seqpsipred, 0, 13);
        chomp($strpsipred);
        $strpsipred = "000".$strpsipred;
        $straccpro = substr($seqaccpro, 0, 13);
        chomp($straccpro);
        $straccpro = "000".$straccpro;
        $strdisopred = substr($seqdisopred, 0, 13);
        chomp($strdisopred);
        $strdisopred = "000".$strdisopred;
      }
      elsif($mystrindex == 0)
      {
        $myseqfinal = substr($seqstr, 0, 12);
        chomp($myseqfinal);
        $myseqfinal = "0000".$myseqfinal;
        $strpsipred = substr($seqpsipred, 0, 12);
        chomp($strpsipred);
        $strpsipred = "0000".$strpsipred;
        $straccpro = substr($seqaccpro, 0, 12);
        chomp($straccpro);
        $straccpro = "0000".$straccpro;
        $strdisopred = substr($seqdisopred, 0, 12);
        chomp($strdisopred);
        $strdisopred = "0000".$strdisopred;
      }
      elsif(($len - $mystrindex) == 8)
      {
        $myseqfinal = substr($seqstr, $mystrindex-4, 12);
        chomp($myseqfinal);
        $myseqfinal = $myseqfinal."0000";
        $strpsipred = substr($seqpsipred, $mystrindex-4, 12);
        chomp($strpsipred);
        $strpsipred = $strpsipred."0000";
        $straccpro = substr($seqaccpro, $mystrindex-4, 12);
        chomp($straccpro);
        $straccpro = $straccpro."0000";
        $strdisopred = substr($seqdisopred, $mystrindex-4, 12);
        chomp($strdisopred);
        $strdisopred = $strdisopred."0000";
      }
      elsif(($len - $mystrindex) == 9)
      {
        $myseqfinal = substr($seqstr, $mystrindex-4, 13);
        chomp($myseqfinal);
        $myseqfinal = $myseqfinal."000";
        $strpsipred = substr($seqpsipred, $mystrindex-4, 13);
        chomp($strpsipred);
        $strpsipred = $strpsipred."000";
        $straccpro = substr($seqaccpro, $mystrindex-4, 13);
        chomp($straccpro);
        $straccpro = $straccpro."000";
        $strdisopred = substr($seqdisopred, $mystrindex-4, 13);
        chomp($strdisopred);
        $strdisopred = $strdisopred."000";
      }
      elsif(($len - $mystrindex) == 10)
      {
        $myseqfinal = substr($seqstr, $mystrindex-4, 14);
        chomp($myseqfinal);
        $myseqfinal = $myseqfinal."00";
        $strpsipred = substr($seqpsipred, $mystrindex-4, 14);
        chomp($strpsipred);
        $strpsipred = $strpsipred."00";
        $straccpro = substr($seqaccpro, $mystrindex-4, 14);
        chomp($straccpro);
        $straccpro = $straccpro."00";
        $strdisopred = substr($seqdisopred, $mystrindex-4, 14);
        chomp($strdisopred);
        $strdisopred = $strdisopred."00";
      }
      elsif(($len - $mystrindex) == 11)
      {
        $myseqfinal = substr($seqstr, $mystrindex-4, 15);
        chomp($myseqfinal);
        $myseqfinal = $myseqfinal."0";
        $strpsipred = substr($seqpsipred, $mystrindex-4, 15);
        chomp($strpsipred);
        $strpsipred = $strpsipred."0";
        $straccpro = substr($seqaccpro, $mystrindex-4, 15);
        chomp($straccpro);
        $straccpro = $straccpro."0";
        $strdisopred = substr($seqdisopred, $mystrindex-4, 15);
        chomp($strdisopred);
        $strdisopred = $strdisopred."0";
      }
      else
      {
        $myseqfinal = substr($seqstr, $mystrindex-4, 16);
        print "$seqstr\n $mystrindex-4 \n $myseqfinal\n";
        chomp($myseqfinal);
        $strpsipred = substr($seqpsipred, $mystrindex-4, 16);
        chomp($strpsipred);
        $straccpro = substr($seqaccpro, $mystrindex-4, 16);
        chomp($straccpro);
        $strdisopred = substr($seqdisopred, $mystrindex-4, 16);
        chomp($strdisopred);
      }

      if($slidingWinNumber == 16)
      {
       # print  SMPFILE "$myseqfinal\t$seqname\t".int($mystrindex-4)."\t1\n";
       # print  SMPFILE01 "$strpsipred\t$seqname\t".int($mystrindex-4)."\t1\n";
       # print  SMPFILE02 "$straccpro\t$seqname\t".int($mystrindex-4)."\t1\n";
       # print  SMPFILE03 "$strdisopred\t$seqname\t".int($mystrindex-4)."\t1\n";
      }
      elsif($slidingWinNumber == 8)
      {
        print  SMPFILE substr($myseqfinal, 4, 8)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE01 substr($strpsipred, 4, 8)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE02 substr($straccpro, 4, 8)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE03 substr($strdisopred, 4, 8)."\t$seqname\t".int($mystrindex)."\t1\n";
      }
      elsif($slidingWinNumber == 6)
      {
        print  SMPFILE substr($myseqfinal, 4, 6)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE01 substr($strpsipred, 4, 6)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE02 substr($straccpro, 4, 6)."\t$seqname\t".int($mystrindex)."\t1\n";
        print  SMPFILE03 substr($strdisopred, 4, 6)."\t$seqname\t".int($mystrindex)."\t1\n";
      }
      else
      {
        print "Please input a proper sliding window size.\n";
      }


      push(@positiveSample, $&);
      $positiveNum ++;
    }

  }
  #print "The positive samples number is: $positiveNum\n";
  #negative random
  my $numcalc = 0;

 
      &myrand("$len", "$positiveNum");
      foreach(@myrand)
      {
        #print "$_\n";
        my $str;
        my $strpsipred;
        my $straccpro;
        my $strdisopred;

        if(int($_) == 3)
        {
            $str = "0".substr($seqstr, 0, 15);
            $strpsipred = "0".substr($seqpsipred, 0, 15);
            $straccpro = "0".substr($seqaccpro, 0, 15);
            $strdisopred = "0".substr($seqdisopred, 0, 15);
        }
        elsif(int($_) == 2)
        {
            $str = "00".substr($seqstr, 0, 14);
            $strpsipred = "00".substr($seqpsipred, 0, 14);
            $straccpro = "00".substr($seqaccpro, 0, 14);
            $strdisopred = "00".substr($seqdisopred, 0, 14);
        }
        elsif(int($_) == 1)
        {
            $str = "000".substr($seqstr, 0, 13);
            $strpsipred = "000".substr($seqpsipred, 0, 13);
            $straccpro = "000".substr($seqaccpro, 0, 13);
            $strdisopred = "000".substr($seqdisopred, 0, 13);
        }
        elsif(int($_) == 0)
        {
            $str = "0000".substr($seqstr, 0, 12);
            $strpsipred = "0000".substr($seqpsipred, 0, 12);
            $straccpro = "0000".substr($seqaccpro, 0, 12);
            $strdisopred = "0000".substr($seqdisopred, 0, 12);
        }
        elsif(($len-int($_)) == 15)
        {
            $str = substr($seqstr, int($_), 15)."0";
            $strpsipred = substr($seqpsipred, int($_), 15)."0";
            $straccpro = substr($seqaccpro, int($_), 15)."0";
            $strdisopred = substr($seqdisopred, int($_), 15)."0";
        }
        elsif(($len-int($_)) == 14)
        {
            $str = substr($seqstr, int($_), 14)."00";
            $strpsipred = substr($seqpsipred, int($_), 14)."00";
            $straccpro = substr($seqaccpro, int($_), 14)."00";
            $strdisopred = substr($seqdisopred, int($_), 14)."00";
        }
        elsif(($len-int($_)) == 13)
        {
            $str = substr($seqstr, int($_), 13)."000";
            $strpsipred = substr($seqpsipred, int($_), 13)."000";
            $straccpro = substr($seqaccpro, int($_), 13)."000";
            $strdisopred = substr($seqdisopred, int($_), 13)."000";
        }
        elsif(($len-int($_)) == 12)
        {
            $str = substr($seqstr, int($_), 12)."0000";
            $strpsipred = substr($seqpsipred, int($_), 12)."0000";
            $straccpro = substr($seqaccpro, int($_), 12)."0000";
            $strdisopred = substr($seqdisopred, int($_), 12)."0000";
        }
        else
        {
            $str = substr($seqstr, int($_), 16);
            $strpsipred = substr($seqpsipred, int($_), 16);
            $straccpro = substr($seqaccpro, int($_), 16);
            $strdisopred = substr($seqdisopred, int($_), 16);
        }

        chomp($str);
        chomp($strpsipred);
        chomp($straccpro);
        chomp($strdisopred);
        #print "$str xx \n";




        my $ps = "";
		my $tem_str = "";
        for $ps (@positiveSample)
        {
		  $tem_str = substr($str, 4, 8);
          if($ps eq $tem_str)
          {
            print "$ps\t$str\n";
            $flag = 1;
          }
        }

        if(1)
        {
          push(@negativeSample, $str);
          if($slidingWinNumber == 16)
          {
            print  SMPFILE "$str\t$seqname\t$_\t$flag\n";
            print  SMPFILE01 "$strpsipred\t$seqname\t$_\t$flag\n";
            print  SMPFILE02 "$straccpro\t$seqname\t$_\t$flag\n";
            print  SMPFILE03 "$strdisopred\t$seqname\t$_\t$flag\n";
          }
          elsif($slidingWinNumber == 8)
          {
            print  SMPFILE substr($str, 4, 8)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE01 substr($strpsipred, 4, 8)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE02 substr($straccpro, 4, 8)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE03 substr($strdisopred, 4, 8)."\t$seqname\t".int(4+$_)."\t0\n";
          }
          elsif($slidingWinNumber == 6)
          {
            print  SMPFILE substr($str, 4, 6)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE01 substr($strpsipred, 4, 6)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE02 substr($straccpro, 4, 6)."\t$seqname\t".int(4+$_)."\t0\n";
            print  SMPFILE03 substr($strdisopred, 4, 6)."\t$seqname\t".int(4+$_)."\t0\n";
          }
          else
          {
            print "Please input a proper sliding window size.\n";
          }

	      $flag = 0;
          $str = "";
        }
        else
        {
          $flag = 0;
        }
      }
      @myrand = ();


  print "Negative samples select over! $negativeNum \t $positiveNum\n";
  $negativeNum = 0;
  @positiveSample = ();
  @negativeSample = ();
  $positiveNum = 0;
}



sub myrand()
{
  my $no = 0;
  my $range = int($_[0]-12);
  my $num = $_[1];
  for(my $ii = 0; $ii <= $range; $ii++)
  {
      push(@myrand, $ii);
  }
}




close FILE;
close SMPFILE;
close SMPFILE01;
close SMPFILE02;
close SMPFILE03;
