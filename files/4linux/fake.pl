#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use Data::Faker;
use Text::Lorem;

my $text = Text::Lorem->new();

my $dbh = DBI->connect("DBI:mysql:database=4linux;host=localhost", "root", "4linux", {'RaiseError' => 1, 'mysql_enable_utf8mb4' => 1});

foreach('estados', 'cidades', 'alunos', 'alunos_extras', 'professores', 'turmas') {
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

my $sql_alunos = 'INSERT INTO alunos (cpf, nome, email, telefone, nascimento) VALUES ';
my $sql_ae = 'INSERT INTO alunos_extras (cpf, endereco, cidade_id, cep, site, cv) VALUES ';
for(my $i = 0; $i < 10000; $i++) {
	my ($name, $cpf, $endereco) = ($faker->name, $faker->cpf, $faker->street_address);
	$name =~ s/'/\\'/g;
	$endereco =~ s/'/\\'/g;
	$sql_alunos .= "('$cpf', '$name', '${\$faker->email}', '${\$faker->telefone}', '${\$faker->sqldate}'), ";
	$sql_ae .= "('$cpf', '$endereco', '${\$faker->cidade}', '${\$faker->cep}', '${\$faker->domain_name}', '${\$faker->cv}'), ";
	if ($i % 50000 == 0) {
		$dbh->do(substr($sql_alunos, 0, -2));
		$dbh->do(substr($sql_ae, 0, -2));
		$sql_alunos = 'INSERT IGNORE INTO alunos (cpf, nome, email, telefone, nascimento) VALUES ';
		$sql_ae = 'INSERT IGNORE INTO alunos_extras (cpf, endereco, cidade_id, cep, site, cv) VALUES ';
	}
}
$dbh->prepare(substr($sql_alunos, 0, -2))->execute();

my $sql = 'INSERT INTO professores (cpf, nome, email, nascimento) VALUES ';
my @cpfs;
for(my $i = 0; $i < 100; $i++) {
	my ($name, $cpf) = ($faker->name, $faker->cpf);
	$name =~ s/'/\\'/g;
	$sql .= "('$cpf', '$name', '${\$faker->email}', '${\$faker->sqldate}'), ";
	push @cpfs, $cpf;
}
$dbh->do(substr($sql, 0, -2));

my @horarios = ('08:30', '18:30');
$sql = "INSERT INTO turmas (professor_cpf, inicio, fim) VALUES ";
for(my $i = 0; $i < 10000; $i++) {
	my $ano = '20' . sprintf('%02d', (int(rand(20)) + 1));
	my $mes = sprintf('%02d', int(rand(12)) + 1);
	my $dia = sprintf('%02d', int(rand(28)) + 1);
	my $horario = $horarios[rand @horarios];
	my $inicio = "$ano-$mes-$dia $horario:00";
	if(++$mes > 12) {
		$mes = 1;	
	}
	my $fim = "$ano-$mes-$dia $horario:00";
	my $cpf = $cpfs[rand @cpfs];
	$sql .= "('$cpf', '$inicio', '$fim'), ";	
}
$dbh->do(substr($sql, 0, -2));
