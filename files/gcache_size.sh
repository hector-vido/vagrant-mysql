#!/usr/bin/perl
useuseusestrict;
warnings;
DBI;
my $dsn = "DBI:mysql:mysql:host=localhost;port=3306";
my $dbh = DBI->connect($dsn);
my $ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'wsrep_received_bytes'");
my $received1 = $ref->{'Value'};
$ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'wsrep_replicated_bytes'");
my $replicated1 = $ref->{'Value'};
sleep(60);
$ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'wsrep_received_bytes'");
my $received2 = $ref->{'Value'};
$ref = $dbh->selectrow_hashref("SHOW STATUS LIKE 'wsrep_replicated_bytes'");
my $replicated2 = $ref->{'Value'};
my $total = ($received2 - $received1) + ($replicated2 - $replicated1);
my $total_hour = $total * 60;
print "$total bytes, ou ", int($total / 1024 / 1024), ' mb em 60 segundos', "\n";
print "$total_hour bytes, ou ", int($total_hour / 1024 / 1024), ' mb em 1 hora', "\n";
