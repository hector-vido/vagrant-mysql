#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use Data::Faker;
use Text::Lorem;

my $text = Text::Lorem->new();

my $dbh = DBI->connect("DBI:mysql:database=4linux;host=localhost", "root", "4linux", {'RaiseError' => 1, 'mysql_enable_utf8mb4' => 1});

foreach('estados', 'cidades', 'alunos', 'alunos_extras', 'professores') {
	$dbh->do("TRUNCATE TABLE $_");
}

my $filename = '/vagrant/files/cidades.csv';
open(FH, '<:encoding(UTF-8)', $filename) or die $!;

my %estados;
my $total_cidades = 0;
my $sql_estados = 'INSERT INTO estados (uf, nome) VALUES ';
my $sql_cidades = 'INSERT INTO cidades (estado_uf, nome) VALUES ';

while(<FH>) {
	my ($estado, $uf, $cidade) = split(/\|/, $_);
	$estados{$uf} = $estado;
	$cidade =~ s/'/\\'/;
	$cidade =~ s/\s+$//;
	$sql_cidades .= "('$uf', '$cidade'), ";
	if (++$total_cidades % 1000 == 0) {
		$dbh->prepare(substr($sql_cidades, 0, -2))->execute();
		$sql_cidades = 'INSERT INTO cidades (estado_uf, nome) VALUES ';
	}
}

for my $key (sort keys %estados) {
	$sql_estados .= "('$key', '$estados{$key}'), ";
}
$dbh->prepare(substr($sql_estados, 0, -2))->execute();
$dbh->prepare(substr($sql_cidades, 0, -2))->execute();

package Data::Faker::Brazil;
use base 'Data::Faker';

__PACKAGE__->register_plugin(
  cpf              => ['###.###.###-##'],
  telefone         => ['+## ## #####-####'],
  cidade           => sub { int(rand(9714) + 1) },
  cep              => ['#####-###'],
  cv               => sub { $text->sentences(int(rand(10) + 1)) }
);

my $faker = Data::Faker->new();

foreach($faker->methods) {
	print "$_ -> " . $faker->$_ . "\n";
}

my $sql_alunos = 'INSERT INTO alunos (cpf, nome, email, telefone, nascimento) VALUES ';
my $sql_ae = 'INSERT INTO alunos_extras (cpf, endereco, cidade, cep, site, cv) VALUES ';
for(my $i = 0; $i < 1000000; $i++) {
	my ($name, $cpf, $endereco) = ($faker->name, $faker->cpf, $faker->street_address);
	$name =~ s/'/\\'/g;
	$endereco =~ s/'/\\'/g;
	$sql_alunos .= "('$cpf', '$name', '${\$faker->email}', '${\$faker->telefone}', '${\$faker->sqldate}'), ";
	$sql_ae .= "('$cpf', '$endereco', '${\$faker->cidade}', '${\$faker->cep}', '${\$faker->domain_name}', '${\$faker->cv}'), ";
	if ($i % 10000 == 0) {
		$dbh->do(substr($sql_alunos, 0, -2));
		$dbh->do(substr($sql_ae, 0, -2));
		$sql_alunos = 'INSERT IGNORE INTO alunos (cpf, nome, email, telefone, nascimento) VALUES ';
		$sql_ae = 'INSERT INTO alunos_extras (cpf, endereco, cidade, cep, site, cv) VALUES ';
	}
}
$dbh->prepare(substr($sql_alunos, 0, -2))->execute();

my $sql = 'INSERT INTO professores (cpf, nome, email, nascimento) VALUES ';
for(my $i = 0; $i < 100; $i++) {
	my $name = $faker->name;
	$name =~ s/'/\\'/g;
	$sql .= "('${\$faker->cpf}', '$name', '${\$faker->email}', '${\$faker->sqldate}'), ";
}
$dbh->do(substr($sql, 0, -2));


print "Name:    ".$faker->name."\n";
print "CPF:     ".$faker->cpf."\n";
print "         ".$faker->city.", ".$faker->us_state_abbr." ".$faker->us_zip_code."\n";
