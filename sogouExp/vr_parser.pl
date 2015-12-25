#!/usr/bin/perl

$query = $ARGV[0];
$query =~ s/%(..)/pack("c", hex($1))/eg; # decoder
print STDERR "$query\n";

$curr_pos = -1;
$enter = 0;
#$limit = 5;
while (<STDIN>)
{
	chop;
	$line = $_;
	if(!$enter)
	{
		if($line =~ /\<h3 class=\"vr.*\"\>/){ $enter = 1;}
	}
	next if(!$enter);

	if ($line =~ /id=\"sogou_vr_(.*?)_(\d+?)\"/)
	{
		$vrid = $1;
		$pos = $2;
		#last if($pos > $limit);
		#print "$pos\t$vrid\t".$line."\n";
		if ($pos > $curr_pos)
		{
			if ($line =~/href=\"http(.+?)\"/)
			{
				$url = "http".$1;
				$url =~ s/amp;//g;
				#if ($vrid ne "" && substr($vrid, 0, 1) < 3 ) # initial with 1 (internal vr), 2 (external vr), besides 3 means structure summary
				if($vrid =~ /^1/ or $vrid =~ /^2/)
				{
					print STDOUT "$query\t$pos\t$url\n";
					$enter = 0;
				}
			}
		}
		$curr_pos = $pos;
	}
}
