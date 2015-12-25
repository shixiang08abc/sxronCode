#!/usr/bin/perl

use strict;
use LWP::UserAgent;
use URI::Escape;
use Encode;

my $queryFile;

if(@ARGV!=2)
{
        die "request.pl [query file]\n";
}
else
{
        $queryFile = $ARGV[0];
}

my $sleep_sec = 0;

open FIN, $queryFile or die "Can't open $queryFile!\n";
my $count = 0;
my $lineNum = 0;
while (<FIN>)
{
        $lineNum ++;
        chop;
        $count ++;

        my $query = $_;
        my $ori_query = $_;
        $query =~ s/(\W)/'%'.unpack("H2", $1)/ego;

#	my $url = 'http://10.12.15.182:8081/websearch/sogou.jsp?forceQuery=on&meta=off&query='.$query; 
	my $url = 'http://'.$ARGV[1].'/web?forceQuery=on&dump=1&meta=off&query='.$query; 
#	my $url = 'http://10.12.15.182:8081/websearch/sogou.jsp?forceQuery=on&magic=exp_id:90&dump=1&meta=off&query='.$query; 
#	my $url = 'http://10.12.15.182:8081/websearch/sogou.jsp?forceQuery=on&dump=1&meta=off&forceQuery=on&d1e2b3u4g1=magic=rankMask:0x1&query='.$query;
        for (my $i = 0; $i<1; $i++)
        {
                my $ua = LWP::UserAgent->new;
                $ua->agent("Explorer");
                my $response = $ua->get( $url );
                if ( not $response->is_success )
                {
                        print STDERR "$lineNum\t"."F\t$ori_query\n";
                }
                else
                {
                        print STDOUT "$lineNum\t"."S\t$ori_query\n";
                }
                sleep($sleep_sec);
        }
}
close FIN;
