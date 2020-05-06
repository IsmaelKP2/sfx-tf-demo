######################## Dashboard ########################

# Create a new dashboard
resource "signalfx_dashboard" "mydashboard0" {
    name = "My Dashboard"
    dashboard_group = "${signalfx_dashboard_group.tfg0.id}"
    time_range = "-1w"

# Row 0 ###
    chart {
        chart_id = "${signalfx_time_chart.mem_used_chart_graph0.id}"
        width = 6
        height = 1
        row = 0
        column = 0
    }

    chart {
        chart_id = "${signalfx_single_value_chart.active_hosts0.id}"
        width = 3
        height = 1
        row = 0
        column = 6
    }

    chart {
        chart_id = "${signalfx_single_value_chart.apache_servers0.id}"
        width = 3
        height = 1
        row = 0
        column = 9
    }

### Row 3 ###
    chart {
        chart_id = "${signalfx_time_chart.cpu_used_chart_graph0.id}"
        width = 6
        height = 1
        row = 3
        column = 0
    }

    chart {
        chart_id = "${signalfx_single_value_chart.mysql_servers0.id}"
        width = 3
        height = 1
        row = 3
        column = 6
    }

    chart {
        chart_id = "${signalfx_single_value_chart.nginx_servers0.id}"
        width = 3
        height = 1
        row = 3
        column = 9
    }

### Row 6 ###
    chart {
        chart_id = "${signalfx_time_chart.disk_space_xvda10.id}"
        width = 3
        height = 1
        row = 6
        column = 0
    }

    chart {
        chart_id = "${signalfx_time_chart.disk_space_xvdg10.id}"
        width = 3
        height = 1
        row = 6
        column = 3
    }

### Row 9 ###
    chart {
        chart_id = "${signalfx_time_chart.write_io_xvda10.id}"
        width = 3
        height = 1
        row = 9
        column = 0
    }

    chart {
        chart_id = "${signalfx_time_chart.write_io_xvdg10.id}"
        width = 3
        height = 1
        row = 9
        column = 3
    }

    chart {
        chart_id = "${signalfx_single_value_chart.haproxy_servers0.id}"
        width = 3
        height = 1
        row = 9
        column = 6
    }

    chart {
        chart_id = "${signalfx_single_value_chart.active_smartgateways0.id}"
        width = 3
        height = 1
        row = 9
        column = 9
    }
}