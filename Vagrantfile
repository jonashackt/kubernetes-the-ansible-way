Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"

    machines = {
        # master nodes
        'master-0' => '172.16.2.10',
        'master-1' => '172.16.2.11',
        'master-2' => '172.16.2.12',
        # worker nodes
        'worker-0' => '172.16.2.100',
        'worker-1' => '172.16.2.101',
        'worker-2' => '172.16.2.102',
        # init node to create certificates, configurationfiles, encryption and host inital LB
        'init' => '172.16.2.200',
    }

    machines.each do |name, ip|
        config.vm.define name do |machine|
            machine.vm.network "private_network", ip: ip
            machine.dns.tld = 'k8s'
            machine.vm.hostname = name

            machine.vm.provider :virtualbox do |vb|
                vb.name = name
                vb.memory = 768
                vb.cpus = 1
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                if Vagrant::Util::Platform.linux?
                  machine.hostsupdater.aliases = [ "#{name}.k8s" ]
                end
            end
        end
    end
end