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
        parameterized_subject = "{{ruleSeverity}} Alert: {{{ruleName}}} ({{{detectorName}}})"
        parameterized_body = <<EOF
{{#if anomalous}}
	Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" triggered at {{timestamp}}.
{{else}}
	Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" cleared at {{timestamp}}.
{{/if}}

{{#if anomalous}}
Triggering condition: {{{readableRule}}}
{{/if}}

Minimum value of signal in the last {{event_annotations.current_window}}: {{inputs.recent_min.value}}
{{#if anomalous}}Trigger threshold: {{inputs.f_top.value}}
{{else}}Clear threshold: {{inputs.c_top.value}}
{{/if}}

{{#notEmpty dimensions}}
Signal details:
{{{dimensions}}}
{{/notEmpty}}

{{#if anomalous}}
{{#if runbookUrl}}Runbook: {{{runbookUrl}}}{{/if}}
{{#if tip}}Tip: {{{tip}}}{{/if}}
{{/if}}
EOF
    }

}