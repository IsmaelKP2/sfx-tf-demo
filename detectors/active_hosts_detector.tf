resource "signalfx_detector" "active_host__detector" {
    name = "Active Host Detector"
    description = "Alert when the number of active hosts drops below a static threshold - deployed via Terraform"
    max_delay = 1
    program_text = <<-EOF
        A = data('memory.used', filter=filter('plugin', 'memory') and (not filter('agent', '*')), extrapolation='last_value', maxExtrapolations=5).count().publish(label='A', enable=False)
        detect(when(A < 8)).publish('Active Hosts Detector')
    EOF
    rule {
        description = "Active Hosts < 8"
        severity = "Warning"
        detect_label = "Active Hosts Detector"
        notifications = ["Email,ghigginbottom@signalfx.com"]
    }

}