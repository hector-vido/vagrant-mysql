# MySQL

Este `Vagrantfile` provisiona três máquinas virtuais com Debian 10 com a versão 8.0 do MySQL.

## Provisionamento

Para provisionar as máquinas, instale o [vagrant](https://www.vagrantup.com/) em sua máquina e algum *hypervisor* como o [VirtualBox](https://www.virtualbox.org/) ou o [Libvirt](https://libvirt.org/). O Hyper-V não suporta definição de endereço fixo.

Clone o repositório:

```bash
git clone 'https://github.com/hector-vido/vagrant-mysql.git'
```

Entre no diretório e inicie o **vagrant**:

```bash
cd vagrant-mysql
vagrant up
```

Verifique quais máquinas estão rodando:

```bash
vagrant status
#Current machine states:
#
#db1                       running (virtualbox)
#db2                       running (virtualbox)
#db3                       running (virtualbox)
```

Entre em qualquer uma das máquinas através de seus nomes:

```bash
vagrant ssh db1
```

## Máquinas

| Nome    | Distro    | IP           |
|---------|-----------|--------------|
| db1     | Debian 10 | 172.27.11.10 |
| db2     | Debian 10 | 172.27.11.20 |
| db3     | Debian 10 | 172.27.11.30 |
