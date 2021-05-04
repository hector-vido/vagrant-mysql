# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# forks: mysql, mariadb ou percona

vms = {
  'db1' => {'memory' => '1024', 'cpus' => 2, 'ip' => '10', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 1},
  'db2' => {'memory' => '1024', 'cpus' => 2, 'ip' => '20', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 0},
  'db3' => {'memory' => '1024', 'cpus' => 2, 'ip' => '30', 'box' => 'debian', 'script' => 'debian.sh', 'fork' => 'mysql', 'sample' => 0},
  #'centos' => {'memory' => '1024', 'cpus' => 2, 'ip' => '40', 'box' => 'centos', 'script' => 'centos.sh', 'fork' => 'mysql', 'sample' => 1},
  #'opensuse' => {'memory' => '1024', 'cpus' => 2, 'ip' => '50', 'box' => 'opensuse', 'script' => 'opensuse.sh', 'fork' => 'mysql', 'sample' => 1},
  #'haproxy' => {'memory' => '256', 'cpus' => 1, 'ip' => '40', 'box' => 'debian', 'script' => 'haproxy.sh'},
}

boxes = {
  'debian'   => 'debian/buster64',
  'centos'   => 'centos/8',
  'opensuse' => 'opensuse/Tumbleweed.x86_64'
}

Vagrant.configure('2') do |config|

  config.vm.box_check_update = false

  vms.each do |name, conf|
    config.vm.define "#{name}" do |my|
      my.vm.box = boxes[conf['box']]
      my.vm.hostname = "#{name}.example.com"
      my.vm.network 'private_network', ip: "172.27.11.#{conf['ip']}"
      my.vm.provision 'shell', path: "provision/#{conf['script']}", args: [conf['fork'], conf['sample']]
      my.vm.provider 'virtualbox' do |vb|
        vb.memory = conf['memory']
        vb.cpus = conf['cpus']
      end
      my.vm.provider 'libvirt' do |lv|
        lv.memory = conf['memory']
        lv.cpus = conf['cpus']
        lv.cputopology :sockets => 1, :cores => conf['cpus'], :threads => '1'
      end
    end
  end

end
