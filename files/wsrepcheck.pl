#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dsn = "DBI:mysql:mysql:database=curso;host=$ENV{HAPROXY_SERVER_ADDR};port=3306";
my $dbh = DBI->connect($dsn, "hector", "4linux");

my $ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'wsrep_ready'");

exit($ref->{'Value'} eq 'ON' ? 0 : 1);

