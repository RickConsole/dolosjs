var config = module.exports = {}

config.network_interface1 = 'GHOST_PORT1_PLACEHOLDER'
config.network_interface2 = 'GHOST_PORT2_PLACEHOLDER'
config.management_interface = 'MGMT_PORT_PLACEHOLDER'
config.management_subnet = '192.168.100.0/24'
config.replace_default_route = false
config.run_command_on_success = false
config.autorun_command = 'date > /root/tools/dolosjs/cmd_test.txt'
