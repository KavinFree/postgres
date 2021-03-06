#! /usr/bin/perl
#
# Copyright (c) 2007-2016, PostgreSQL Global Development Group
#
# src/backend/utils/mb/Unicode/UCS_to_SHIFT_JIS_2004.pl
#
# Generate UTF-8 <--> SHIFT_JIS_2004 code conversion tables from
# "sjis-0213-2004-std.txt" (http://x0213.org)

use strict;
require convutils;

# first generate UTF-8 --> SHIFT_JIS_2004 table

my $in_file = "sjis-0213-2004-std.txt";

open(my $in, '<', $in_file) || die("cannot open $in_file");

my @mapping;

while (my $line = <$in>)
{
	if ($line =~ /^0x(.*)[ \t]*U\+(.*)\+(.*)[ \t]*#(.*)$/)
	{
		# combined characters
		my ($c, $u1, $u2) = ($1, $2, $3);
		my $rest = "U+" . $u1 . "+" . $u2 . $4;
		my $code = hex($c);
		my $ucs1 = hex($u1);
		my $ucs2 = hex($u2);

		push @mapping, {
			code => $code,
			ucs => $ucs1,
			ucs_second => $ucs2,
			comment => $rest,
			direction => 'both'
		};
		next;
	}
	elsif ($line =~ /^0x(.*)[ \t]*U\+(.*)[ \t]*#(.*)$/)
	{
		# non-combined characters
		my ($c, $u, $rest) = ($1, $2, "U+" . $2 . $3);
		my $ucs  = hex($u);
		my $code = hex($c);
		my $direction;

		if ($code < 0x80 && $ucs < 0x80)
		{
			next;
		}
		elsif ($code < 0x80)
		{
			$direction = 'from_unicode';
		}
		elsif ($ucs < 0x80)
		{
			$direction = 'to_unicode';
		}
		else
		{
			$direction = 'both';
		}

		push @mapping, {
			code => $code,
			ucs => $ucs,
			comment => $rest,
			direction => $direction
		};
	}
}
close($in);

print_tables("SHIFT_JIS_2004", \@mapping, 1);
