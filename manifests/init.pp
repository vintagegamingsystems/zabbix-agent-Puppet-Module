$zabbix_user_parameters = []

    define confDir($ensure) {
        case $ensure {
            absent: {
                file {'/etc/zabbix/zabbix_agentd.d/$name':
                    ensure => absent,
                    notify  =>  Service[zabbix-agent],
                }
            }
            present: {
                file {
                   '/etc/zabbix/zabbix_agentd.d/$name':
                        source  =>	"puppet:///modules/zabbixagent/files/zabbix_agentd.d/$hostname/$name",
                        notify  =>	[Service[zabbix-agent],File["/etc/zabbix/zabbix_agentd.d"]],
                }
            }
	}
    }


class zabbixagent {
	# Our zabbix server has the ip of 128.223.214.111 just in case.
    	$zabbixRPMPubkey = "/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX"
	$zabbix_config_dir = "/etc/zabbix" # True in our environment
	$zabbix_agentd_conf = "$zabbix_config_dir/zabbix_agentd.conf" # True in our environment
    	$zabbix_log_dir = "/var/log/zabbix/" # <- Location in our environment
    	$zabbix_pid_dir = "/var/run/zabbix/" #<- Location in our environment
 
#Conditional statement to designate the $zabbix_server variable 
	
	if $hostname == "zabbix-test" {
		$zabbix_server = "127.0.0.1"
	}
	else {
		$zabbix_server = "128.223.142.111"
	}
	

   # Retrieves and imports Zabbix Public key
   exec { 
	"getPublicKey":
	 	command		=>	"wget http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX ",
		cwd		=>	"/etc/pki/rpm-gpg/",
		creates		=>	"/etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX",
		path		=>	"/usr/bin/:/bin/"
}

    file {
	
	"/etc/zabbix/zabbix_agentd.d":
		ensure	=> 	directory,
		purge	=>	true,
		recurse	=>	true,
		force	=>	true,
		links	=>	follow,
		mode	=>	'0644',
		source 	=>	"puppet:///modules/zabbixagent/zabbix_agentd.d/$hostname/",
		notify	=>	Service[zabbix-agent];
	
	$zabbixRPMPubkey:
	    ensure	=>	present,
	    owner	=>	'root',
	    group	=>	'root',
	    mode	=>	'0644',
	    require	=>	Exec['getPublicKey'];
	

	$zabbix_config_dir:
            ensure 	=> 	directory,
            owner 	=> 	'root',
            group 	=> 	'root',
            mode 	=> 	'0755',
            require 	=> 	Package["zabbix-agent"];

        $zabbix_agentd_conf:
            owner	=> 	'root',
            group	=> 	'root',
            mode 	=> 	'0644',
            source	=>	"puppet:///modules/zabbixagent/zabbix_agentd.conf",
            require 	=> 	Package["zabbix-agent"];

        $zabbix_log_dir:
            ensure 	=> 	directory,
            owner 	=> 	'zabbix',
            group 	=> 	'zabbix',
            mode 	=> 	'0755',
            require 	=> 	Package["zabbix-agent"];

        $zabbix_pid_dir:
            ensure 	=> 	directory,
            owner 	=> 	'zabbix',
            group 	=> 	'zabbix',
            mode 	=> 	'0755',
            require 	=> 	Package["zabbix-agent"];
}

 service {
        "zabbix-agent":
            enable	=>	true,
            ensure	=>	running,
            hasstatus   =>	true,
            hasrestart  =>	true,
            subscribe     =>	[Package["zabbix-agent"],File["/etc/zabbix/zabbix_agentd.d","/etc/zabbix/zabbix_agentd.conf"]];
    }

     package {
        "zabbix-agent":
            ensure	=>	installed,
            require     =>	Exec["getPublicKey"]
	}

}

class zabbixagent::usergroup {
   
    group {
        "zabbix":
                ensure          =>	present;
	}

    user {
	"zabbix":
                ensure          =>	present,
                gid             =>	zabbix,
                membership	=>	minimum,
                shell           =>	"/sbin/nologin",
                home            =>	"/var/lib/zabbix",
                require         =>	Group["zabbix"]
	}

}
