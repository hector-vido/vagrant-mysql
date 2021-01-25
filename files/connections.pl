#!/usr/bin/perl

# Simula muitas conexões ao servidor
# apt-get install libparallel-forkmanager-perl libdbd-mysql-perl

use strict;
use warnings;
use DBI;
use Parallel::ForkManager;

if(!$ARGV[0] || !$ARGV[1]) {
        print "Especifique o número de conexões paralelas e o número de execuções. Ex: perl $0 32 1000\n";
        exit(1);
}

my ($nconn, $nexec) = @ARGV;

sub conn() {
        my $dsn = "DBI:mysql:mysql:database=curso;host=172.27.11.40;port=3306";
        my $dbh = DBI->connect($dsn, "hector", "4linux");
        return $dbh;
}

my $dbh = conn();
$dbh->do('CREATE TABLE IF NOT EXISTS seeds (id BIGINT AUTO_INCREMENT PRIMARY KEY, seed VARCHAR(50))');
$dbh->disconnect();

my $pm = Parallel::ForkManager->new($nconn);

LOOP:
for(my $n = 0; $n < $nconn; $n++) {
        my $pid = $pm->start and next LOOP;
        for(my $i = 0; $i < $nexec; $i++) {
                my $dbh = conn();
                my $done = $dbh->do('INSERT INTO seeds (seed) VALUES (' . int(rand(1000000)) . ')');
                if (!$done) {
                        $dbh->disconnect();
                        sleep 5;
                        $i--;
                }
        }
        $pm->finish;
}

$pm->wait_all_children;
