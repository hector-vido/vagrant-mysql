#!/usr/bin/perl

#################################################################################################
# Este script popula a base de dados "4linux" com 2 milhões de registros                        #
# A intenção deste script é ser fácil de se alterar ao invés de performático.                   #
# Bulks inserts foram evitados para tornar a edição mais simples ao custo do tempo de inserção. #
#################################################################################################

use strict;
use warnings;

use DBI;
use Data::Faker;
use Text::Lorem;

my %estados;
my $sth;
my $sth1;
my $sth2;

my $text = Text::Lorem->new();

my $dbh = DBI->connect("DBI:mysql:database=4linux;host=localhost", "root", "4linux", {'RaiseError' => 1, 'mysql_enable_utf8mb4' => 1});
$dbh->{AutoCommit} = 0;
$dbh->do('SET sql_log_bin = OFF');

foreach('estados', 'cidades', 'alunos', 'alunos_extras', 'professores', 'turmas', 'cursos', 'turmas_alunos', 'alunos_compras') {
	$dbh->do("TRUNCATE TABLE $_");
}

$dbh->do("INSERT INTO cursos (id, nome, duracao, valor) VALUES (450, 'Linux Beginners', 40, 1000.00),(451, 'Linux Administrator', 40, 1200.00),(452, 'Linux Engineer', 40, 1500.00),(801, 'MySQL', 40, 1400.00),(802, 'PostgreSQL', 40, 1400.00),(803, 'MongoDB', 40, 1400.00),(500, 'PHP Básico', 40, 1200.00),(501, 'PHP Intermediário', 40, 1200.00),(502, 'PHP Avançado', 40, 1200.00),(520, 'Python Básico', 40, 1200.00),(521, 'Python para Administradores', 40, 1400.00),(522, 'Python para Cientistas de Dados', 40, 1500.00),(525, 'Infraestrutura Ágil', 40, 1600.00),(540, 'Docker', 40, 1500.00),(541, 'Kubernetes', 40, 1500.00),(542, 'Openshift', 20, 1000.00),(543, 'Rancher', 20, 1000.00),(600, 'pfSense', 20, 800.00),(700, 'OpenLDAP e Samba', 20, 800.00),(900, 'Segurança em Servidores Linux', 40, 1500.00)");

$sth = $dbh->prepare("INSERT INTO cidades (estado_uf, nome) VALUES (TRIM(?) , TRIM(?))");
open(FH, '<:encoding(UTF-8)', '/vagrant/files/cidades.csv') or die $!;
while(<FH>) {
	my ($estado, $uf, $cidade) = split(/\|/, $_);
	$estados{$uf} = $estado;
	$sth->execute($uf, $cidade);
}

$sth = $dbh->prepare("INSERT INTO estados (uf, nome) VALUES (?, ?)");
for my $key (sort keys %estados) {
	$sth->execute($key, $estados{$key});
}

$dbh->commit();

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

print "Inserindo alunos...\n";
$sth1 = $dbh->prepare('INSERT IGNORE INTO alunos (cpf, nome, email, telefone, nascimento) VALUES (?, ?, ?, ?, ?)');
$sth2 = $dbh->prepare('INSERT IGNORE INTO alunos_extras (cpf, endereco, cidade_id, cep, site, cv) VALUES  (?, ?, ?, ?, ?, ?)');
for(my $i = 1; $i <= 1000000; $i++) {
	my $cpf = $faker->cpf;
	$sth1->execute($cpf, $faker->name, $faker->email, $faker->telefone, $faker->sqldate);
	$sth2->execute($cpf, $faker->street_address, $faker->cidade, $faker->cep, $faker->domain_name, $faker->cv);
	if ($i % 10000 eq 0) {
        print "$i alunos inseridos...\n";
	}
}

$dbh->commit();

$sth = $dbh->prepare('INSERT INTO professores (cpf, nome, email, nascimento) VALUES (?, ?, ?, ?)');
my @cpfs;
for(my $i = 0; $i < 100; $i++) {
	my $cpf = $faker->cpf;
	$sth->execute($cpf, $faker->name, $faker->email, $faker->sqldate);
	push @cpfs, $cpf;
}
$dbh->commit();

$sth = $dbh->prepare("SELECT GROUP_CONCAT(id) FROM cursos GROUP BY ''");
$sth->execute();
my $cids = $sth->fetchrow_array;
my @cids = split(/,/, $cids);

my @horarios = ('08:30', '18:30');
$sth = $dbh->prepare('INSERT INTO turmas (curso_id, professor_cpf, inicio, fim) VALUES (?, ?, ?, ?)');
for(my $i = 0; $i < 10000; $i++) {
	my $curso = $cids[rand @cids];
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
	$sth->execute($curso, $cpf, $inicio, $fim);
}
$dbh->commit();

$sth = $dbh->prepare("SELECT cpf FROM alunos ORDER BY RAND() LIMIT 50000");
$sth->execute();
@cpfs = ();
while(my $cpf = $sth->fetchrow_hashref()) {
	push @cpfs, $cpf->{'cpf'}
}

$sth1 = $dbh->prepare('INSERT IGNORE INTO turmas_alunos (turma_id, aluno_cpf) VALUES (?, ?)');
$sth2 = $dbh->prepare('INSERT IGNORE INTO alunos_compras (aluno_cpf, turma_id, valor) VALUES (?, ?, ?)');
for(my $i = 1; $i <= 10000; $i++) {
	my $total = 10 + int(rand(10));
	for(my $x = 1; $x <= $total; $x++) {
		my $cpf = $cpfs[rand @cpfs];
		my $valor = 800 + int(rand(10)) * 100;
		$sth1->execute($i, $cpf);
		$sth2->execute($cpf, $i, $valor.00);
	}
}

$dbh->commit();
