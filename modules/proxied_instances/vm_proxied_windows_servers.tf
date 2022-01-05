resource "aws_instance" "proxied_windows_server" {
  count                     = var.proxied_windows_server_count
  ami                       = var.windows_server_ami
  instance_type             = var.windows_server_instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.proxied_instances_sg.id]

  user_data = <<EOF
  <powershell>

    Get-LocalUser -Name "Administrator" | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText "${var.windows_server_administrator_pwd}" -Force)

    [Environment]::SetEnvironmentVariable("http_proxy","http://${aws_instance.proxy_server[0].private_ip}:8080","Machine")
    [Environment]::SetEnvironmentVariable("https_proxy","http://${aws_instance.proxy_server[0].private_ip}:8080","Machine")
    netsh winhttp set proxy "${aws_instance.proxy_server[0].private_ip}:8080"

    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "http://${aws_instance.proxy_server[0].private_ip}:8080"
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1

    $source = "https://github.com/signalfx/splunk-otel-collector/releases/download/v${var.collector_version}/splunk-otel-collector-${var.collector_version}-amd64.msi"
    $dest = "C:\Windows\Temp\splunk-otel-collector-${var.collector_version}-amd64.msi"
    $WebClient = New-Object System.Net.WebClient
    $WebProxy = New-Object System.Net.WebProxy("http://${aws_instance.proxy_server[0].private_ip}:8080",$true)
    $WebClient.Proxy = $WebProxy
    $WebClient.DownloadFile($source,$dest)
    Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Windows\Temp\splunk-otel-collector-${var.collector_version}-amd64.msi /quiet'

    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_ACCESS_TOKEN' -Value ${var.access_token}
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_API_URL' -Value "https://api.${var.realm}.signalfx.com"
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_BUNDLE_DIR' -Value "C:\Program Files\Splunk\OpenTelemetry Collector\agent-bundle"
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_INGEST_URL' -Value "https://ingest.${var.realm}.signalfx.com"
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_MEMORY_TOTAL_MIB' -Value "512"
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_REALM' -Value ${var.realm}
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' -Name 'SPLUNK_TRACE_URL' -Value "https://ingest.${var.realm}.signalfx.com/v2/trace"
    Start-Service -Name "splunk-otel-collector"

    Invoke-WebRequest -Uri ${var.windows_proxied_server_agent_url} -OutFile "C:\ProgramData\Splunk\OpenTelemetry Collector\agent_config.yaml"
    Start-Service splunk-otel-collector
  </powershell>
  
  EOF

  tags = {
    Name = lower(join("-",[var.environment,element(var.proxied_windows_server_ids, count.index)]))
  }
}

output "proxied_windows_server_details" {
  value =  formatlist(
    "%s, %s, %s", 
    aws_instance.proxied_windows_server.*.tags.Name,
    aws_instance.proxied_windows_server.*.public_ip,
    aws_instance.proxied_windows_server.*.public_dns, 
  )
}
