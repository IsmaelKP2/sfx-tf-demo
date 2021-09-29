#! /bin/bash

# Download and Install the Latest Updates for the OS
sudo apt-get update
sudo apt-get upgrade -y

# Add haproxy Repo
sudo add-apt-repository ppa:vbernat/haproxy-2.0 -y

# Install haproxy
sudo apt-get update
sudo apt-get install haproxy -y

# Update haproxy configuration
sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.bak

sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null <<EOT
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket localhost:9000
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend stats_frontend
    bind *:9001
    stats uri /stats
    stats refresh 10s
    stats admin if LOCALHOST

frontend Local_Server
    bind 0.0.0.0:80
    mode http
    default_backend My_Stats_Server

backend My_Stats_Server
    mode http
    balance roundrobin
    option forwardfor
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
    option httpchk HEAD / HTTP/1.1rnHost:localhost
    server localhost 0.0.0.0:9001/stats
EOT

# restart haproxy Service
sudo service haproxy restart