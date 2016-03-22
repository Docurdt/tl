#! /usr/bin/perl -w

####################################################################
#功能描述：
# 将序列信息及生成的特征信息整合到一个文件中，形成整齐的输入数据格式。
#   指令执行格式：
#       ./featureadd.pl Axxxxx-Homoxxxx.final
#   指令执行完毕后，其会在输入文件所在目录下生成*.add的文件。
#
#
####################################################################
use strict;

#$ARGV[0];#命令行参数
#my $samplesfile = "/Users/Docurdt/Desktop/Workspace/output/Samples/sample_01.txt";
my $samplesfile = $ARGV[0]."feature.add";
my $disopreddir = "/prosper/yanan/wangyanan/diso/";
my $psipreddir = "/prosper/yanan/wangyanan/psipred/";
my $accprodir = "/prosper/yanan/wangyanan/accpro/";
open( FILE, $ARGV[0]) or die "Can't open the file:$!/n";

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

my $seqname;
my $seqID;
my @site = ();
my $seqstr;
my $line;
my $seqpsipred = "";
my $seqaccpro = "";
my $seqdisopred = "";

while($line = <FILE>)
{
  if($line =~ m/^>(.*)\|(.*)$/)
  {
    $seqname = $1;
    $seqID = $line;
    #print "$1\n";
  }
  elsif($line =~ m/^site:(.*)$/)
  {
    push(@site, $line);

    #print "$1\n";
  }
  else
  {
    $seqstr = $line;

    print SMPFILE "$seqID";
    foreach(@site)
    {
      print SMPFILE "$_";
    }
    @site = ();
    print SMPFILE "$seqstr";
    #open the feature files
    &openFfile("$seqname");
  }
}

sub openFfile()
{
  my $accprofile = $accprodir.$_[0].".acc";
  my $disopredfile = $disopreddir.$_[0].".diso";
  my $psipredfile = $psipreddir.$_[0].".ss2";

  open( PSIFILE, $psipredfile) or die "Can't open the file:$!/n";
  open( ACCFILE, $accprofile) or die "Can't open the file:$!/n";
  open( DISOFILE, $disopredfile) or die "Can't open the file:$!/n";
  my $line = "";
  $line = <PSIFILE>;
  $line = <PSIFILE>;
  while($line = <PSIFILE>)
  {
    if($line =~ m/^\s*\d*\s*[A-Z]{1}\s*([CHE]{1}).*$/)
    {
      $seqpsipred = $seqpsipred.$1;
    }

  }
  chomp($seqpsipred);
  print SMPFILE "$seqpsipred\n";
  $seqpsipred = "";
  close PSIFILE;

  $line = <ACCFILE>;
  while($line = <ACCFILE>)
  {
   # if($line =~ m/^[e-]*$/)
   # {
   #   #print "$line";
   #   $line =~ s/-/b/g;
   #   print SMPFILE "$line";
   # }
   
   if($line =~ m/^([EB]{1})\s[A-Z]{1}\s*.*/)
   {	
		$seqaccpro = $seqaccpro.$1;
   		$seqaccpro =~ s/E/e/;
		$seqaccpro =~ s/B/b/;
		
   }
    
  }
  chomp($seqaccpro);
  print SMPFILE "$seqaccpro\n";
  $seqaccpro = "";
  close ACCFILE;

  $line = <DISOFILE>;
  $line = <DISOFILE>;
  $line = <DISOFILE>;
  while($line = <DISOFILE>)
  {
    if($line =~ m/^\s*\d*\s*\w{1}\s*([\*\.]{1})\s*.*$/)
    {
      $seqdisopred = $seqdisopred.$1;
    }

  }
  chomp($seqdisopred);
  print SMPFILE "$seqdisopred\n";
  $seqdisopred = "";
  close DISOFILE;

  #print "$accprofile\n";
}

close FILE;
close SMPFILE;
