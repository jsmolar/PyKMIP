FROM python:3.9-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir . psycopg2-binary

# Create directories
RUN mkdir -p /etc/encrypt_conf /etc/pykmip /var/pykmip/logs

# Add server.conf
RUN cat > /etc/pykmip/server.conf <<'EOF'
[server]
hostname=0.0.0.0
port=5696
certificate_path=/etc/encrypt_conf/scylla_node.pem
key_path=/etc/encrypt_conf/scylla_node.key
ca_path=/etc/encrypt_conf/trust.pem
enable_tls_client_auth=True
auth_suite=TLS1.2
tls_cipher_suites=
    TLS_RSA_WITH_AES_128_CBC_SHA256
    TLS_RSA_WITH_AES_256_CBC_SHA256
    TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
#database_path=/var/pykmip/db/pykmip.db
database_path=postgresql+psycopg2://pykmip_user:pykmip_pass@postgres:5432/pykmip
logging_level=DEBUG
EOF

EXPOSE 5696

CMD ["pykmip-server","-f","/etc/pykmip/server.conf","-l","/var/pykmip/logs/server.log"]
