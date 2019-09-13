# # Create CPU Used Chart
# resource "signalfx_single_value_chart" "cpu_used_chart" {
#   name = "CPU Used %"

#     program_text = <<-EOF
#         A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).publish(label='A')
#         EOF

#     description = "CPU Idle Time as a Percentage"
# }

# # Create Memory Used Chart
# resource "signalfx_single_value_chart" "memory_used_chart" {
#   name = "Memory Used %"

#     program_text = <<-EOF
#         A = data('memory.utilization', filter=filter('plugin', 'signalfx-metadata')).publish(label='A')
#         EOF

#     description = "CPU Idle Time as a Percentage"
# }

# Create Memory Used Chart Graph
resource "signalfx_time_chart" "mem_used_chart_graph" {
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
resource "signalfx_time_chart" "cpu_used_chart_graph" {
  name = "CPU Used %"

    program_text = <<-EOF
        A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).publish(label='A')
        EOF
        
    plot_type = "LineChart"
    show_data_markers = true

    description = "CPU Idle Time as a Percentage"
}



######################## Host Count Charts ########################

# Create Active Hosts Chart
resource "signalfx_single_value_chart" "active_hosts" {
  name = "Active Hosts"

    program_text = <<-EOF
        A = data('memory.used', filter=filter('plugin', 'memory') and (not filter('agent', '*')), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of active Hosts"
}

# Create MySQL Servers Chart
resource "signalfx_single_value_chart" "mysql_servers" {
  name = "MySQL Servers"

    program_text = <<-EOF
        A = data('mysql_octets.rx', filter=filter('plugin', 'mysql'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running MySQL Servers"
}

# Create Apache Servers Chart
resource "signalfx_single_value_chart" "apache_servers" {
  name = "Apache Servers"

    program_text = <<-EOF
        A = data('apache_requests', filter=filter('plugin', 'apache'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running Apache Servers"
}

# Create Nginx Servers Chart
resource "signalfx_single_value_chart" "nginx_servers" {
  name = "Nginx Servers"

    program_text = <<-EOF
        A = data('nginx_requests', filter=filter('plugin', 'nginx'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running Nginx Servers"
}

# Create HAProxy Servers Chart
resource "signalfx_single_value_chart" "haproxy_servers" {
  name = "HAProxy Servers"

    program_text = <<-EOF
        A = data('gauge.request_rate', filter=filter('plugin', 'haproxy'), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A')
        EOF

    description = "Number of running HAProxy Servers"
}




######################## Disk Space Charts ########################

# Create Disk Space XVDA1 Chart
resource "signalfx_time_chart" "disk_space_xvda1" {
  name = "Disk Space XVDA1"

    program_text = <<-EOF
        A = data('df_complex.free', filter=filter('plugin', 'df') and filter('plugin_instance', 'xvda1')).publish(label='A')
        EOF

    description = "Disk space of XVDA1"
}

# Create Disk Space XVDB1 Chart
resource "signalfx_time_chart" "disk_space_xvdb1" {
  name = "Disk Space XVDB1"

    program_text = <<-EOF
        A = data('df_complex.free', filter=filter('plugin', 'df') and filter('plugin_instance', 'xvdb1')).publish(label='A')
        EOF

    description = "Disk space of XVDB1"
}


# Create Write IO XVDA1 Chart
resource "signalfx_time_chart" "write_io_xvda1" {
  name = "Write IO XVDA1"

    program_text = <<-EOF
        A = data('disk_ops.write', filter=filter('plugin_instance', 'xvda1')).publish(label='A')
        EOF

    description = "Write IO for XVDA1"
}

# Create Write IO XVDB1 Chart
resource "signalfx_time_chart" "write_io_xvdb1" {
  name = "Write IO XVDB1"

    program_text = <<-EOF
        A = data('disk_ops.write', filter=filter('plugin_instance', 'xvdb1')).publish(label='A')
        EOF

    description = "Write IO for XVDB1"
}


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

