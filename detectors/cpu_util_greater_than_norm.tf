resource "signalfx_detector" "cpu_greater_than_norm_detector" {
    name = "CPU Utilization % Greater than Historical Norm"
    description = "Alerts when CPU usage for this host for the last 10 minutes was significantly higher than normal, as compared to the last 24 hours - deployed via Terraform"
    max_delay = 1
    program_text = <<-EOF
        from signalfx.detectors.against_recent import against_recent
        A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).publish(label='A', enable=False)
        against_recent.detector_mean_std(stream=A, current_window='10m', historical_window='24h', fire_num_stddev=3, clear_num_stddev=2.5, orientation='above', ignore_extremes=True, calculation_mode='vanilla').publish('CPU utilization is significantly greater than normal, and increasing')
    EOF
    rule {
        description = "All the values of cpu.utilization in the last 10m are more than 3 standard deviation(s) above the mean of its preceding 24h."
        severity = "Critical"
        detect_label = "CPU utilization is significantly greater than normal, and increasing"
        notifications = ["Email,ghigginbottom@splunkcom"]
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