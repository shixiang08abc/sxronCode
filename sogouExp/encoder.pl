#!/usr/bin/perl

while (<STDIN>)
{
	chop;
	$query = $_; 
	$query =~ s/(\W)/'%'.unpack("H2", $1)/ego;
	print STDOUT "$query\n";
}
