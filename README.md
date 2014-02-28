zabbix-agent-Puppet-Module
==========================

# authConf Directory
#
# location: /etc/puppet/modules/zabbixagent/files/zabbix_agentd.d/
#
# This directory is used to keep all of the authoratative configuration files.
# Read carefully.
# In the parent directory that houses the authConf directory, make a directory that is the name of the hostname of the
# client machines that you would like to push configuration files to.
#
# You will see an example directory named is-joshdev1. Within that directory you will want to place symlinks that point
# to files within the authConf directory. 
# Make sure you place your authoratative configuration files within the authConf directory only. That way there will not 
# be duplicate configuration files on your puppet master.
#
# This directory will allow you to configure your puppet agents with any type of custom configuration that you want.
# The granularity is nearly infinite.
