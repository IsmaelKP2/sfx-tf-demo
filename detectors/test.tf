resource "signalfx_detector" "promote_tags_test" {
    name = "Testing Promoting Tags"
    description = "Testing Promoting Tags"
    max_delay = 1
    program_text = <<-EOF
        from signalfx.detectors.against_recent import against_recent
        A = data('cpu.utilization', filter=filter('plugin', 'signalfx-metadata')).promote(['aws_tag_environment','aws_tag_role']).publish(label='A', enable=False)
        against_recent.detector_mean_std(stream=A, current_window='10m', historical_window='24h', fire_num_stddev=3, clear_num_stddev=2.5, orientation='above', ignore_extremes=True, calculation_mode='vanilla').publish('Testing Promoting Tags')
    EOF
    rule {
        description = "Testing Promoting Tags"
        severity = "Critical"
        detect_label = "Testing Promoting Tags"
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

Environment: {{dimensions.aws_tag_environment}}
Role: {{dimensions.aws_tag_role}}
EOF
    }

}