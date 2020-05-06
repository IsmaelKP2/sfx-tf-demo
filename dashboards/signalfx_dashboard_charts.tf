# Create Memory Used Chart Graph
resource "signalfx_time_chart" "mem_used_chart_graph0" {
  name = "Memory Used %"

    program_text = <<-EOF
        A = data('memory.utilization', filter=filter('plugin', 'signalfx-metadata') and (not filter('agent', '*'))).publish(label='A', enable=False)
        B = (A).min().publish(label='B')
        C = (A).percentile(pct=10).publish(label='C')
        D = (A).percentile(pct=50).publish(label='D')
        E = (A).percentile(pct=90).publish(label='E')
        F = (A).max().publish(label='F')
        EOF
        
    plot_type = "LineChart"
    show_data_markers = true

    description = "percentile distribution"
}

# Create CPU Used Chart Graph
resource "signalfx_time_chart" "cpu_used_chart_graph0" {
  name = "CPU Used %"

    program_text = <<-EOF
        A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).publish(label='A')
        EOF
        
    plot_type = "LineChart"
    show_data_markers = true

    description = "CPU utilisation as a Percentage"
}



######################## Host Count Charts ########################

# Create Active Hosts Chart
resource "signalfx_single_value_chart" "active_hosts0" {
  name = "Active Hosts"

    program_text = <<-EOF
        A = data('memory.utilization', extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of active Hosts"
}

# Create MySQL Servers Chart
resource "signalfx_single_value_chart" "mysql_servers0" {
  name = "MySQL Servers"

    program_text = <<-EOF
        A = data('mysql_octets.rx', filter=filter('plugin', 'mysql'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running MySQL Servers"
}

# Create Apache Servers Chart
resource "signalfx_single_value_chart" "apache_servers0" {
  name = "Apache Servers"

    program_text = <<-EOF
        A = data('apache_requests', filter=filter('plugin', 'apache'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running Apache Servers"
}

# Create Nginx Servers Chart
resource "signalfx_single_value_chart" "nginx_servers0" {
  name = "Nginx Servers"

    program_text = <<-EOF
        A = data('nginx_requests', filter=filter('plugin', 'nginx'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running Nginx Servers"
}

# Create HAProxy Servers Chart
resource "signalfx_single_value_chart" "haproxy_servers0" {
  name = "HAProxy Servers"

    program_text = <<-EOF
        A = data('gauge.request_rate', filter=filter('plugin', 'haproxy'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running HAProxy Servers"
}

# Create Active SmartGateway Chart
resource "signalfx_single_value_chart" "active_smartgateways0" {
  name = "Active SmartGateways"

    program_text = <<-EOF
        A = data('memory.used', filter=filter('plugin', 'memory') and (filter('host', 'Smart*')), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of active SmartGateways"
}


######################## Disk Space Charts ########################

# Create Disk Space XVDA1 Chart
resource "signalfx_time_chart" "disk_space_xvda10" {
  name = "Disk Space XVDA1"

    program_text = <<-EOF
        A = data('df_complex.free', filter=filter('plugin', 'df') and filter('plugin_instance', 'xvda1')).publish(label='A')
        EOF

    description = "Disk space of XVDA1"
}

# Create Disk Space XVDG1 Chart
resource "signalfx_time_chart" "disk_space_xvdg10" {
  name = "Disk Space XVDG1"

    program_text = <<-EOF
        A = data('df_complex.free', filter=filter('plugin', 'df') and filter('plugin_instance', 'xvdg1')).publish(label='A')
        EOF

    description = "Disk space of XVDG1"
}


# Create Write IO XVDA1 Chart
resource "signalfx_time_chart" "write_io_xvda10" {
  name = "Write IO XVDA1"

    program_text = <<-EOF
        A = data('disk_ops.write', filter=filter('plugin_instance', 'xvda1')).publish(label='A')
        EOF

    description = "Write IO for XVDA1"
}

# Create Write IO XVDG1 Chart
resource "signalfx_time_chart" "write_io_xvdg10" {
  name = "Write IO XVDG1"

    program_text = <<-EOF
        A = data('disk_ops.write', filter=filter('plugin_instance', 'xvdg1')).publish(label='A')
        EOF

    description = "Write IO for XVDG1"
}

########################################################################
# # Create xxxxx Chart
# resource "xxxxxx" "xxxxxx" {
#   name = "xxxxxx"

#     program_text = <<-EOF
#         A = xxxxxx
#         EOF

#     description = "xxxxxx"
# }

# # Create xxxxx Chart
# resource "xxxxxx" "xxxxxx" {
#   name = "xxxxxx"

#     program_text = <<-EOF
#         A = xxxxxx
#         EOF

#     description = "xxxxxx"
# }

