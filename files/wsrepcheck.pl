#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $dsn = "DBI:mysql:mysql:database=curso;host=$ENV{HAPROXY_SERVER_ADDR};port=3306";
my $dbh = DBI->connect($dsn, "hector", "4linux");

my $sth = $dbh->prepare("SHOW STATUS LIKE 'wsrep_ready'");
$sth->execute() or die $dbh->errstr();
my $ref = $sth->fetchrow_hashref();

exit($ref->{'Value'} eq 'ON' ? 0 : 1);
