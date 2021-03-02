resource "aws_lambda_layer_version" "request-opentracing_2_0" {
  filename   = "${path.module}/request-opentracing_2_0.zip"
  layer_name = "request-opentracing_2_0"

  compatible_runtimes = ["python3.6", "python3.7", "python3.8"]
}
