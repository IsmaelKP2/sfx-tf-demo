resource "signalfx_detector" "active_host__detector" {
  name         = "Active Host Detector"
  description  = "Alert when the number of active hosts goes above a static threshold - deployed via Terraform"
  max_delay    = 1
  program_text = <<-EOF
    A = data('memory.utilization', extrapolation='last_value', maxExtrapolations=5).count().publish(label='A', enable=False)
    detect(when(A >0)).publish('Active Hosts')
  EOF
  rule {
    description           = "Active Hosts"
    severity              = "Minor"
    detect_label          = "Active Hosts"
    notifications         = ["Email,ghigginbottom@splunk.com", "VictorOps,ERI0R2GAIAA,GH_PRI"]
    parameterized_subject = "{{ruleSeverity}} Alert: {{{ruleName}}} ({{{detectorName}}})"
    parameterized_body    = var.message_body
  }
}