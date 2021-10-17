#!/usr/bin/perl
use strict;
use warnings;
use DBI;
my $dsn = "DBI:mysql:mysql:host=localhost;port=3306";
my $dbh = DBI->connect($dsn);
my $ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'innodb_os_log_written'");
my $first = $ref->{'Value'};
sleep(60);
$ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'innodb_os_log_written'");
my $second = $ref->{'Value'};
my $total = $second - $first;
my $total_hour = $total * 60;
print "$total bytes, ou ", int($total / 1024 / 1024), ' mb em 60 segundos', "\n";
print "$total_hour bytes, ou ", int($total_hour / 1024 / 1024), ' mb em 1 hora', "\n";
