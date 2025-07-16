# Chapter 12

# ALL PASSWORDS ARE `abcd1234`

be sure to download the `Linux 64-bit` version of Elastic Agent from [the official website](https://www.elastic.co/downloads/elastic-agent)

## Setup

1. Install Ansible and OpenJDK (for Keytool), clone the repo, and acquire Elastic Agent
```
sudo apt install default-jdk -y
mkdir ~/projects && cd ~/projects
git clone <repo>
cd <repo>
wget https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-<VERSION>-linux-x86_64.tar.gz
tar xzf elastic-agent-<VERSION>-linux-x86_64.tar.gz
cd elastic-agent-<VERSION>-linux-x86_64
```

2. Create Ansible vault file, optionally use `nano` instead of `vi`
```
export EDITOR=/usr/bin/nano
ansible-vault create vars/vault.yml
```

3. Add passwords to vault
- If you closed the value after running the create step, run `ansible-vault edit vars/vault.yml`.
```
ssl_key_password: abcd1234
keystore_password: abcd1234
truststore_password: abcd1234
elastic_user_password: abcd1234
kibana_system_user_password: abcd1234
# save and exit
```

4. Update IP addresses, hostnames as necessary in `inventory-elastic.yml`
	- `hostname` and `basename` variables are hand-populated, for the sake of demonstration and TLS files

5. Run Playbook - Generate TLS Files
	- creates a root CA, intermediate/signing CA, and many "flex" (clientAuth and serverAuth) signed certificates
	- you may generate subsequent flex certs using `playbook_tls_issue_flex_cert.yml` and `inventory-oneshot.yml`
```
ansible-playbook --ask-vault-pass -i inventory-elastic.yml playbook_tls.yml
# abcd1234
```

6. Run Playbook - Elastic Prep
	- sets firewall rules, adds inventory hosts to `/etc/hosts`, adds Elastic GPG key
	- `--ask-vault-pass` = `-J`
	- `--ask-become-pass` = `-K`
```
ansible-playbook -JKi inventory-elastic.yml playbook_elastic_prep.yml
```

## Consider Taking a VM Snapshot Now

7. Run Playbook - Elasticsearch Install
```
ansible-playbook -JKi inventory-elastic.yml playbook_elasticsearch.yml
```

8. Check Cluster via API
```
# health
curl https://elasticsearch01.local:9200/_cluster/health \
-u elastic:abcd1234 \
--capath tls/certs/ca-chain.cert.pem \
--cert tls/certs/wildcard.local.flex.cert.pem \
--key tls/keys/wildcard.local.flex.key.pem \
--key-type pem

# ensure they all have the same master node, and are in the same cluster
# if you get TLS errors, make sure the Elasticsearch host knows the machine you're using in DNS
for i in {1..3}; do curl "https://elasticsearch0$i.local:9200/_cat/master?v=true" -u elastic:abcd1234 --capath tls/certs/ca-chain.cert.pem --cert tls/certs/wildcard.local.flex.cert.pem --key tls/keys/wildcard.local.flex.key.pem --key-type pem; done
```

## Consider Taking a VM Snapshot Now

9. Run Playbook - Kibana Install
```
ansible-playbook -JKi inventory-elastic.yml playbook_kibana.yml
```

10. Access Kibana
	- In a browser, navigate to `https://<KIBANA-IP-OR-HOSTNAME>:5601`
	- user `elastic`
	- password `abcd1234`
	- Hamburger menu --> Stack Management --> Advanced Settings
		- Space Settings tab: Search for `Dark mode` and choose `Enable`, then `Save` and reload the page
			- May give a "this setting is deprecated / use system settings" warning, just click Dark mode anyway
		- Global Settings tab: SCROLL to the bottom for `Share usage with Elastic` and toggle it `Off`

## Consider Taking a VM Snapshot Now

11. Run Playbook - Fleet Setup
- Might take up to a minute for Kibana to say "Fleet Server connected"
```
ansible-playbook -JKi inventory-elastic.yml playbook_fleet_server.yml
```

## Consider Taking a VM Snapshot Now

12. Run Playbook - Create Elastic Agent Policy, Deploy Elastic Agent
- Generates an enrollment token on each run; you may instead copy the `--enrollment-token=<token>` value from the Kibana "Add an Agent" menu into `vars.yml` as `enrollment_token` (and modify the playbook)
- Modify or make a copy that deploys agents without creating the policy
```
ansible-playbook -JKi inventory-elastic.yml playbook_deploy_elasticagent.yml
```

## Consider Taking a VM Snapshot Now
