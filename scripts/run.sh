# Cluster Setup
# Server: 
consul agent -ui -server -bootstrap-expect=1 \
-data-dir=/tmp/consul -node=agent-one -bind=172.20.20.10 \
-config-dir=/etc/consul.d -client 0.0.0.0 >& /dev/null &

# Client:
consul agent -data-dir=/tmp/consul -node=agent-two \
-bind=172.20.20.11 -config-dir=/etc/consul.d >& /dev/null &

# Manual Join:
consul join 172.20.20.11

# Auto Join: 
consul agent -atlas-join \
-atlas=<ATLAS_USERNAME>/infrastructure \
-atlas-token="YOUR_ATLAS_TOKEN"

#Health Checks:
# Add a Ping Health Check
echo '{"check": {"name": "ping", "script": "ping -c1 google.com >/dev/null", "interval": "30s"}}' \
>/etc/consul.d/ping.json

# Sevices:
# Add a Web Service
echo '{"service": {"name": "web", "tags": ["rails"], "port": 80, "check": {"script": "curl localhost >/dev/null 2>&1", "interval": "10s"}}}' \
>/etc/consul.d/web.json

# Checks
# Check Critical State
curl http://127.0.0.1:8500/v1/health/state/critical


# K/V Store:
# Check all Keys:
curl -v http://localhost:8500/v1/kv/?recurse
# Put a Key:
curl -X PUT -d 'test' http://localhost:8500/v1/kv/web/key1
# Check a Single Key:
curl http://localhost:8500/v1/kv/web/key1
# Delete all Keys:
curl -X DELETE http://localhost:8500/v1/kv/web/sub?recurse
# Delete a Single Key:
curl -X DELETE http://localhost:8500/v1/kv/web/key1
