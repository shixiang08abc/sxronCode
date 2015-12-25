#!/usr/bin/perl

$display_num = 5; # 显示几位5
$top_num = 3; # 分析前几位3
$top_change_num = 3;#$top_num; # 前几位，只要有变化就输出3
$new_num = 2; # 若首位无变化，则前几位引入多少新结果，输出

$display_num = $top_num if ($display_num < $top_num);
@sample = ($ARGV[0], $ARGV[1]);

for ($no=0; $no<2; $no++)
{
	open FILE, $sample[$no] or die "open $sample[$no] failed\n";
	while (<FILE>)
	{
		chop;
		@tmp = split /\t/;
		$size = @tmp;
		$tmp[1] =~ s/（|）//g;
		$content = join("\t", @tmp[2..$size]);
		$map{$tmp[1]}[$tmp[0]][$no] = $content; #"$tmp[2]\t$tmp[3]";
	}
	close FILE;
}

$query_num = 0;
$first_change_num = 0;
$new_in_num = 0;
foreach $query (keys %map)
{
	@res = @{$map{$query}};
	$url0 = ""; $url1 = "";
	undef %url_map0; undef %url_map1;
	$no_url = 0;
	for ($i=0; $i<$top_num; $i++)
	{
		@info0 = split(/\t/, $res[$i][0]);
		$url0 .= $info0[0] if ($i < $top_change_num);
		$url_map0{$info0[0]} = 1;
		@info1 = split(/\t/, $res[$i][1]);
		$url1 .= $info1[0] if ($i < $top_change_num);
		$url_map1{$info1[0]} = 1;
		$no_url = 1 if ($info0[0] !~ /^http/ || $info1[0] !~ /^http/);
		#$no_url = 1 if ($info0[0] !~ /^tp/ || $info1[0] !~ /^tp/);
		$no_url = 1 if ($info0[0] =~ /ERROR_SUMMARY_PROCESS/ || $info1[0] =~ /ERROR_SUMMARY_PROCESS/);
	}
	next if ($url0 eq "" && $url1 eq "");
	$query_num++;
	next if ($no_url == 1);
	$is_new_in = 0;
	foreach $url (keys %url_map0)
	{
		if (!exists $url_map1{$url})
		{
			$is_new_in++;
		}
	}
	$is_show = 0;
	if ($url0 ne $url1 && ($url0 ne "" || $url1 ne ""))
	{
		$first_change_num++;
		$is_show = 1;
	}
	elsif ($is_new_in >= $new_num)
	{
		$new_in_num ++;
		$is_show = 1;
	}
	#if (($url0 ne $url1 && $url0 ne "" && $url1 ne "") ||
	#	($is_new_in >= $new_num))
	if ($is_show == 1)
	{
		for ($i=0; $i<$display_num; $i++)
		{
			print STDOUT "$query\t$i\t$res[$i][0]\n";
		}
		print STDOUT "\n" if ($display_num > 1);
		for ($i=0; $i<$display_num; $i++)
		{
			print STDOUT "$query\t$i\t$res[$i][1]\n";
		}
		for ($i=0; $i<$display_num && $i<2; $i++)
		{
			print STDOUT "\n";
		}
	}
}
print STDERR "query: $query_num\n";
print STDERR "1st change: $first_change_num\n";
print STDERR "new in: $new_in_num\n";
