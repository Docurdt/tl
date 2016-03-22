#! /usr/bin/perl -w

use strict;

#my $path = "../../input/A01.009-Homo sapiens.fasta.new.db70.finalfeature.addseq";
my $path = $ARGV[0];
my $pssmpath = "/prosper/yanan/wangyanan/pssm";
my $disopath = "/prosper/yanan/wangyanan/diso";
#my @dir = glob($path);


#foreach(@dir)
#{
 #$_ =~ s/\s/\\ /;
 $path =~ s/\s/\\ /;
 
 my $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.cksaap.code -m 0 -L 16 -W 16 -t cksaap -f N","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.binary.code -m 0 -L 16 -W 16 -t binary","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.pssm.code -m 0 -W 16 -t pssm -p $pssmpath","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.aac.code -m 0 -L 16 -W 16 -t AAC","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.diso.code -m 0 -W 16 -t disorder -d $disopath","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.blosum.code -m 0 -L 16 -W 16 -t blosum62","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.aaindex.code -m 0 -L 16 -W 16 -t aaindex -f N","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";

 $args = join ' ', "/prosper/yanan/wangyanan/upload_src/encode/encode/encode -i", $path, "-o $path.chr.code -m 0 -L 16 -W 16 -t charge-hyd","\n";
 system($args) == 0 or die "[$0] ERROR: $args failed: $?\n";


