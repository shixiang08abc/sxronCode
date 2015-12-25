#!/usr/bin/perl

$vr_file = $ARGV[0];
$insert_range = 3;

open FILE, $vr_file or die "open $vr_file failed\n";
while (<FILE>)
{
	chop;
	@tmp = split /\t/;
	$query = $tmp[0];
	$pos = $tmp[1];
	$url = $tmp[2];
	#if ($url =~ /v.sogou.com/ || $url =~ /mp3.sogou.com/ || $url =~ /pic.sogou.com/)
	{
		$vr_map{$query}{$url} = $pos;
	}
}
close FILE;

$cnt = 0;
$type = "test";
while (<STDIN>)
{
	chop;
	next if ($_ eq "");
	@tmp = split /\t/;
	$pos = $tmp[1];
	# output
	if ($cnt > 0 && $pos == 0)
	{
		# ≤Â»Îvr
		@mix_res = insert_vr($query, %res);
		for ($i = 0; $i < $insert_range; $i++)
		{
			print STDOUT "$query\t$i\t$mix_res[$i]\t$type\n";
		}
		if ($type eq "test")
		{
			$type = "online";
		}
		else
		{
			$type = "test";
		}
		undef %res;
	}
	$query = $tmp[0];
	$url = $tmp[2];
	if ($pos < $insert_range)
	{
		$res{$url} = $pos;
	}
	$cnt++;
}
@mix_res = insert_vr($query, %res);
for ($i = 0; $i < $insert_range; $i++)
{
	print STDOUT "$query\t$i\t$mix_res[$i]\t$type\n";
}

sub insert_vr
{
	my ($query, %web_res_map) = @_;
	my @mix_res;
	for ($i = 0; $i < $insert_range; $i++)
	{
		$mix_res[$i] = "";
	}
	my %vr_url_map;
	# vr first
	if (exists $vr_map{$query})
	{
		%vr_url_map = %{$vr_map{$query}};
		my $url;
		foreach $url (keys %vr_url_map)
		{
			$vrpos = $vr_url_map{$url};
			if ($vrpos < $insert_range)
			{
				$mix_res[$vrpos] = $url;
			}
		}
	}
	# then web results
	my $url;
	my $curr_pos = 0;
	foreach $url (sort {$web_res_map{$a} <=> $web_res_map{$b}} keys %web_res_map)
	{
		while ($mix_res[$curr_pos] ne "")
		{
			$curr_pos++;
		}
		last if ($curr_pos >= $insert_range);
		if (!exists $vr_url_map{$url})
		{
			$mix_res[$curr_pos] = $url;
		}
	}
	return @mix_res;
}
