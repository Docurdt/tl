#! /usr/bin/perl -w

my $mypath = $ARGV[0];

my $testpath = $mypath.".test";
my $trainpath = $mypath.".train";
my $outname3 = $mypath.".train.acc.code";
my $outname4 = $mypath.".train.psi.code";

my $outname1 = $mypath.".test.acc.code";
my $outname2 = $mypath.".test.psi.code";


#open(FILE, $mypath) or die "Can't open the file:$mypath $!\n";
open(TESTFILE, $testpath) or die "Can't open the file:$testpath $!\n";
open(TRAINFILE, $trainpath) or die "Can't open the file:$trainpath $!\n";

unless (-e $outname1)
{
    #print "File not found.then create it\n";
    #创建文件并写入
    open(OUTFILE1,">$outname1") or die "Couldn't open $outname1:$!";
}
else
{
    open(OUTFILE1,">$outname1") or die "Couldn't open $outname1:$!";
    #print "File found.\n";
}

unless (-e $outname2)
{
    #print "File not found.then create it\n";
    #创建文件并写入
    open(OUTFILE2,">$outname2") or die "Couldn't open $outname2:$!";
}
else
{
    open(OUTFILE2,">$outname2") or die "Couldn't open $outname2:$!";
    #print "File found.\n";
}

unless (-e $outname3)
{
    #print "File not found.then create it\n";
    #创建文件并写入
    open(OUTFILE3,">$outname3") or die "Couldn't open $outname3:$!";
}
else
{
    open(OUTFILE3,">$outname3") or die "Couldn't open $outname3:$!";
    #print "File found.\n";
}

unless (-e $outname4)
{
    #print "File not found.then create it\n";
    #创建文件并写入
    open(OUTFILE4,">$outname4") or die "Couldn't open $outname4:$!";
}
else
{
    open(OUTFILE4,">$outname4") or die "Couldn't open $outname4:$!";
    #print "File found.\n";
}


my $tmpline;

#acc test encodings
while($tmpline = <TESTFILE>)
{
    if($tmpline =~ m/^([0-9A-Z]{16})\s*([-0-9A-Z]*)\s*([-0-9]*)\s*(\d*)$/)
    {
        #print "$1 $2 $3 $4\n";
        my $encode_index = 1;

        my $seq = $1;
        my $subid = $2;
        my $index = $3;
        my $class = $4;

        if($class == 1)
        {
            print OUTFILE1 "+1  ";
        }
        elsif($class == 0)
        {
            print OUTFILE1 "-1  ";
        }

        my $myflag = 0;
        my $accfile = $mypath."accpro";
		$accfile =~ s/addseq/add/;
        open(ACCFILE, $accfile) or die "Can't open the file:$accfile $!\n";
        my $accline;
        while($accline = <ACCFILE>)
        {
            if($accline =~ m/^([0eb]{16})\s*([-A-Z0-9]*)\s*([-0-9]*)\s(\d*)$/)
            {
                #print "$1\n$2\n$3\n$4\n";
                my $acc_subid = $2;
                my $acc_index = $3;
                my $acc_class = $4;

                if(($acc_subid eq $subid) && ($acc_index == $index) && ($acc_class == $class))
                {
                    #print "$1 $acc_subid\n";

                    my @accchar = split(//, $1);
                    #print "$accchar[0]\n";
                    foreach(@accchar)
                    {
                        my $tempstr = $_;
					#	print $tempstr."\n";
						my $temp_index = $encode_index + 1;
                        $tempstr =~ s/0/$encode_index:0  $temp_index:0/;
						$tempstr =~ s/b/$encode_index:0  $temp_index:1/;
                        $tempstr =~ s/e/$encode_index:1  $temp_index:0/;

                        print OUTFILE1 "$tempstr  ";
                        $encode_index += 2;
                    }
                    print OUTFILE1 "\n";

                    $myflag = 1;
                    last;
                }


            }
            else
            {
                die "Can't match the regular expression.\n";
            }
        }
        close ACCFILE;

        if($myflag == 0)
        {
            die "Can't find it's acc file\n";
        }
        else
        {
            $myflag = 0;
        }

    }
    else
    {
        die "Can't match the regular expression\n";
    }

}
close OUTFILE1;
close TESTFILE;


#psi test encoding
open(TESTFILE, $testpath) or die "Can't open the file:$testpath $!\n";
while($tmpline = <TESTFILE>)
{
    if($tmpline =~ m/^([0-9A-Z]{16})\s*([-0-9A-Z]*)\s*([-0-9]*)\s*(\d*)$/)
    {
        #print "$1 $2 $3 $4\n";
        my $encode_index = 1;

        my $seq = $1;
        my $subid = $2;
        my $index = $3;
        my $class = $4;

        if($class == 1)
        {
            print OUTFILE2 "+1  ";
        }
        elsif($class == 0)
        {
            print OUTFILE2 "-1  ";
        }

        my $myflag = 0;
        my $psifile = $mypath."psipred";
		$psifile =~ s/addseq/add/;
        open(PSIFILE, $psifile) or die "Can't open the file:$psifile $!\n";
        my $psiline;
        while($psiline = <PSIFILE>)
        {
            if($psiline =~ m/^([0HCE]{16})\s*([-A-Z0-9]*)\s*([-0-9]*)\s(\d*)$/)
            {
                #print "$1\n$2\n$3\n$4\n";
                my $psi_subid = $2;
                my $psi_index = $3;
                my $psi_class = $4;

                if(($psi_subid eq $subid) && ($psi_index == $index) && ($psi_class == $class))
                {
                    #print "$1 $psi_subid\n";

                    my @accchar = split(//, $1);
                    #print "$psichar[0]\n";
                    foreach(@accchar)
                    {
                        my $tempstr = $_;
					#	print $tempstr."\n";
						my $temp_index = $encode_index + 1;
						my $temp_index1 = $encode_index + 2;
                        $tempstr =~ s/0/$encode_index:0  $temp_index:0  $temp_index1:0/;
						$tempstr =~ s/H/$encode_index:0  $temp_index:0  $temp_index1:1/;
                        $tempstr =~ s/C/$encode_index:0  $temp_index:1  $temp_index1:0/;
                        $tempstr =~ s/E/$encode_index:1  $temp_index:0  $temp_index1:0/;

                        print OUTFILE2 "$tempstr  ";
                        $encode_index += 3;
					   
                    }
                    print OUTFILE2 "\n";

                    $myflag = 1;
                    last;
                }


            }
            else
            {
                die "Can't match the regular expression.\n";
            }
        }

        close PSIFILE;
        if($myflag == 0)
        {
            die "Can't find it's acc file\n";
        }
        else
        {
            $myflag = 0;
        }

    }
    else
    {
        die "Can't match the regular expression\n";
    }

}
close OUTFILE2;
close TESTFILE;





#acc train encodings
while($tmpline = <TRAINFILE>)
{
    if($tmpline =~ m/^([0-9A-Z]{16})\s*([-0-9A-Z]*)\s*([-0-9]*)\s*(\d*)$/)
    {
        #print "$1 $2 $3 $4\n";
        my $encode_index = 1;

        my $seq = $1;
        my $subid = $2;
        my $index = $3;
        my $class = $4;

        if($class == 1)
        {
            print OUTFILE3 "+1  ";
        }
        elsif($class == 0)
        {
            print OUTFILE3 "-1  ";
        }

        my $myflag = 0;
        my $accfile = $mypath."accpro";
		$accfile =~ s/addseq/add/;
        open(ACCFILE, $accfile) or die "Can't open the file:$accfile $!\n";
        my $accline;
        while($accline = <ACCFILE>)
        {
            if($accline =~ m/^([0eb]{16})\s*([-A-Z0-9]*)\s*([-0-9]*)\s(\d*)$/)
            {
                #print "$1\n$2\n$3\n$4\n";
                my $acc_subid = $2;
                my $acc_index = $3;
                my $acc_class = $4;

                if(($acc_subid eq $subid) && ($acc_index == $index) && ($acc_class == $class))
                {
                    #print "$1 $acc_subid\n";

                    my @accchar = split(//, $1);
                    #print "$accchar[0]\n";
                    foreach(@accchar)
                    {
                        my $tempstr = $_;
					#	print $tempstr."\n";
						my $temp_index = $encode_index + 1;
                        $tempstr =~ s/0/$encode_index:0  $temp_index:0/;
						$tempstr =~ s/b/$encode_index:0  $temp_index:1/;
                        $tempstr =~ s/e/$encode_index:1  $temp_index:0/;

                        print OUTFILE3 "$tempstr  ";
                        $encode_index += 2;
                    }
                    print OUTFILE3 "\n";

                    $myflag = 1;
                    last;
                }


            }
            else
            {
                die "Can't match the regular expression.\n";
            }
        }
        close ACCFILE;

        if($myflag == 0)
        {
            die "Can't find it's acc file\n";
        }
        else
        {
            $myflag = 0;
        }

    }
    else
    {
        die "Can't match the regular expression\n";
    }

}
close OUTFILE3;
close TRAINFILE;

#psi train encoding
open(TRAINFILE, $trainpath) or die "Can't open the file:$trainpath $!\n";
while($tmpline = <TRAINFILE>)
{
    if($tmpline =~ m/^([0-9A-Z]{16})\s*([-0-9A-Z]*)\s*([-0-9]*)\s*(\d*)$/)
    {
        #print "$1 $2 $3 $4\n";
        my $encode_index = 1;

        my $seq = $1;
        my $subid = $2;
        my $index = $3;
        my $class = $4;

        if($class == 1)
        {
            print OUTFILE4 "+1  ";
        }
        elsif($class == 0)
        {
            print OUTFILE4 "-1  ";
        }

        my $myflag = 0;
        my $psifile = $mypath."psipred";
		$psifile =~ s/addseq/add/;
        open(PSIFILE, $psifile) or die "Can't open the file:$psifile $!\n";
        my $psiline;
        while($psiline = <PSIFILE>)
        {
            if($psiline =~ m/^([0HCE]{16})\s*([-A-Z0-9]*)\s*([-0-9]*)\s(\d*)$/)
            {
                #print "$1\n$2\n$3\n$4\n";
                my $psi_subid = $2;
                my $psi_index = $3;
                my $psi_class = $4;

                if(($psi_subid eq $subid) && ($psi_index == $index) && ($psi_class == $class))
                {
                    #print "$1 $psi_subid\n";

                    my @accchar = split(//, $1);
                    #print "$psichar[0]\n";
                    foreach(@accchar)
                    {
                        my $tempstr = $_;
					#	print $tempstr."\n";
						my $temp_index = $encode_index + 1;
						my $temp_index1 = $encode_index + 2;
                        $tempstr =~ s/0/$encode_index:0  $temp_index:0  $temp_index1:0/;
						$tempstr =~ s/H/$encode_index:0  $temp_index:0  $temp_index1:1/;
                        $tempstr =~ s/C/$encode_index:0  $temp_index:1  $temp_index1:0/;
                        $tempstr =~ s/E/$encode_index:1  $temp_index:0  $temp_index1:0/;

                        print OUTFILE4 "$tempstr  ";
                        $encode_index += 3;
                    }
                    print OUTFILE4 "\n";

                    $myflag = 1;
                    last;
                }


            }
            else
            {
                die "Can't match the regular expression.\n";
            }
        }

        close PSIFILE;
        if($myflag == 0)
        {
            die "Can't find it's acc file\n";
        }
        else
        {
            $myflag = 0;
        }

    }
    else
    {
        die "Can't match the regular expression\n";
    }

}
close OUTFILE4;
close TRAINFILE;
