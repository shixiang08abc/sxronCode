#!/usr/bin/perl

while (<STDIN>)
{
	chop;
	@tmp = split /\t/;
	if ($tmp[3] eq "test")
	{
		$query_res_map{$tmp[0]}[0][$tmp[1]] = $tmp[2];
	}
	else
	{
		$query_res_map{$tmp[0]}[1][$tmp[1]] = $tmp[2];
	}
}

foreach $query (keys %query_res_map)
{
	$cnt++;
	@test_res = @{$query_res_map{$query}[0]};
	@online_res = @{$query_res_map{$query}[1]};
	$res_num = @test_res;
	$diff = 0;
	for ($i = 0; $i < $res_num; $i++)
	{
		if ($test_res[$i] ne $online_res[$i])
		{
			$diff = 1;
			last;
		}
	}
	if ($diff == 1)
	{
		$change++;
		if ($test_res[0] ne $online_res[0])
		{
			$first_change++;
		}
		for ($i = 0; $i < $res_num; $i++)
		{
			$j = $i + 1;
			print STDOUT "$query\t$test_res[$i]\t$j\ttest\n";
		}
		for ($i = 0; $i < $res_num; $i++)
		{
			$j = $i + 1;
			print STDOUT "$query\t$online_res[$i]\t$j\tonline\n";
		}

	}
}
print STDERR "query: $cnt\n1st change: $first_change\nchange: $change\n";
