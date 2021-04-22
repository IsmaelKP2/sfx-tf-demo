resource "signalfx_detector" "promote_tags" {
  name         = "${var.environment} Promoting Tags"
  description  = "Promoting Tags"
  max_delay    = 1
  program_text = <<-EOF
    from signalfx.detectors.against_recent import against_recent
    A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).promote(['aws_tag_environment','aws_tag_role']).publish(label='A', enable=False)
    against_recent.detector_mean_std(stream=A, current_window='10m', historical_window='24h', fire_num_stddev=3, clear_num_stddev=2.5, orientation='above', ignore_extremes=True, calculation_mode='vanilla').publish('Promoting Tags')
  EOF
  rule {
    description           = "Promoting Tags"
    severity              = "Critical"
    detect_label          = "Promoting Tags"
    notifications         = ["Email,${var.notification_email}"]
    parameterized_subject = "{{ruleSeverity}} Alert: {{{ruleName}}} ({{{detectorName}}})"
    parameterized_body    = var.message_body
  }
}