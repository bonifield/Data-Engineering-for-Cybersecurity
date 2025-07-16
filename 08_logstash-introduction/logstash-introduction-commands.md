## Testing and Starting Logstash

### Using a single configuration
```
bin/logstash -f conf.d/your-config.conf --config.test_and_exit
bin/logstash -f conf.d/your-config.conf --config.reload.automatic
```

### Using `config/pipelines.yml`
```
bin/logstash --config.test_and_exit
bin/logstash --config.reload.automatic
```


## Nmap

Install the Nmap codec (from inside the Logstash directory)
```
bin/logstash-plugin install logstash-codec-nmap
```

Perform an Nmap scan
```
nmap -n --reason --open -sT -T4 -F 192.168.1.0/24 -oX nmap_results.xml
```

Use cURL to POST NMAP scan results to Logstash
```
curl --cacert "/home/j/tls/certs/ca-chain.cert.pem" -H "X-Nmap-Target: 192.168.8.0/24" https://logstash.local:8443 --data-binary @/home/j/nmap_results.xml
```


## Flask app for API tests

Install Virtualenv and Flask
```
sudo apt install python3-virtualenv
virtualenv myapp
myapp/bin/pip install flask pyopenssl
```

Refer to the contents of `testapi/app.py` then run the webserver
```
chmod +x app.py
./app.py
```

Use cURL to test the webserver's API endpoints using Logstash's `http_poller` input
```
curl -k https://localhost:5000/
curl -k https://localhost:5000/json/
```


## SSH tunnel from Logstash to Redis

```
ssh -N -L 6379:127.0.0.1:6379 -l j 192.168.8.138
# options
-N = do not send commands (this is only a tunnel)
-L = forward the local port to the server
first 6379 = the local port on the Logstash host
127.0.0.1 = access localhost on the remote system, in this case the Redis service's IP
second 6379 = port on the remote system, in this case the Redis service's port
-l = user account to access remote system
192.168.8.138 = remote system running Redis
```

## Append timestamps to a test log every second
```
while true; do date +'%Y-%m-%d %H:%M:%S.%N' >> ~/example-logs/timestamp.log && sleep 1; done
```
