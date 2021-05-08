# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# forks: mysql, mariadb ou percona
# memory, cpus, fork and sample are optional, defaults do:
#   1024,    2, mysql     and 0 respectively

vms = {
  'db1' => {'ip' => '10', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 1},
  'db2' => {'ip' => '20', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 0},
  'db3' => {'ip' => '30', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 0},
  'haproxy' => {'memory' => 256, 'cpus' => 1, 'ip' => '40', 'box' => 'debian', 'script' => 'haproxy.sh'},
  #'centos' => {'ip' => '50', 'box' => 'centos', 'script' => 'centos.sh', 'fork' => 'mysql', 'sample' => 1},
  #'opensuse' => {'ip' => '60', 'box' => 'opensuse', 'script' => 'opensuse.sh', 'fork' => 'mysql', 'sample' => 1},
}

resources = {
  'cpus' => 2,
  'memory' => 1024
}

boxes = {
  'debian'   => 'debian/buster64',
  'centos'   => 'centos/8',
  'opensuse' => 'opensuse/Leap-15.2.x86_64'
}

Vagrant.configure('2') do |config|

  config.vm.box_check_update = false

  vms.each do |name, conf|
    config.vm.define "#{name}" do |my|
      args = [conf['fork'] || 'mysql', conf['sample'] || 0]
      my.vm.box = boxes[conf['box']]
      my.vm.hostname = "#{name}.example.com"
      my.vm.network 'private_network', ip: "172.27.11.#{conf['ip']}"
      my.vm.provision 'shell', path: "provision/#{conf['script']}", args: args
      my.vm.provider 'virtualbox' do |vb|
        vb.memory = conf['memory'] || resources['memory']
        vb.cpus = conf['cpus'] || resources['cpus']
      end
      my.vm.provider 'libvirt' do |lv|
        lv.memory = conf['memory'] || resources['memory']
        lv.cpus = conf['cpus'] || resources['cpus']
        lv.cputopology :sockets => 1, :cores => conf['cpus'] || resources['cpus'], :threads => '1'
      end
    end
  end

end
