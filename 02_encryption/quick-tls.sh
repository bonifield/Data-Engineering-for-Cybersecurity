#!/bin/bash


ssl_key_password="abcd1234"


#===========================
# prep and root CA
#===========================

# makes a directory structure under the present working directory
echo "Creating the directory structure"
mkdir -p tls/{configs,keys,csr,caroot,caintermediate,certs}
# if running the following commands manually, don't enter the tls directory


#===========================
# root CA
#===========================

echo "Creating the root CA"
openssl req -x509 -config tls/configs/openssl-rootca.cnf -days 3650 -new -extensions ca_root -keyout tls/caroot/ca.key.pem -out tls/caroot/ca.cert.pem -passout pass:$ssl_key_password

# view root CA cert
#openssl x509 -text -noout -in tls/caroot/ca.cert.pem

# create root CA index and serial trackers
touch tls/caroot/index-root.txt
echo "00" > tls/caroot/serial-root.txt


#===========================
# intermediate CA
#===========================

# create intermediate CA's private key and Certificate Signing Request (CSR)
echo "Creating the intermediate CA"
openssl req -config tls/configs/openssl-intermediateca.cnf -new -keyout tls/caintermediate/ca-int.key.pem -out tls/caintermediate/ca-int.csr -outform PEM -passout pass:$ssl_key_password

# sign the CSR using the root CA
openssl ca -batch -notext -config tls/configs/openssl-rootca.cnf -passin pass:$ssl_key_password -policy signing_policy -days 3650 -extensions ca_intermediate -out tls/caintermediate/ca-int.cert.pem -infiles tls/caintermediate/ca-int.csr

# view the intermediate CA cert
#openssl x509 -text -noout -in tls/caintermediate/ca-int.cert.pem

# verify the intermediate CA cert
openssl verify -CAfile tls/caroot/ca.cert.pem tls/caintermediate/ca-int.cert.pem

# create intermediate CA index and serial trackers
touch tls/caintermediate/index-intermediate.txt
echo "00" > tls/caintermediate/serial-intermediate.txt


#===========================
# chain file
#===========================

echo "Creating the chain file"
cat tls/caroot/ca.cert.pem tls/caintermediate/ca-int.cert.pem >> tls/certs/ca-chain.cert.pem


#===========================
# Flex Certificates
#===========================

for tool in {wildcard,elasticagent,elasticsearch01,elasticsearch02,elasticsearch03,elasticsearch,filebeat,fleet,kafka01,kafka02,kafka03,kafka,kibana,logstash,redisfollower01,redisfollower02,redisfollower03,redisleader,rsyslog,threatintel,winlogbeat}; do

	cert_type="flex"
	extension="flex_cert"
	domain="local"

	if [ $tool == "winlogbeat" ]; then
		cert_type="client"
		extension="client_cert"
	fi


	echo "Creating flex certificate for: $tool"

	# create the private key and CSR
	echo -e "Creating private key and certificate signing request for: $tool"
	openssl req -config tls/configs/openssl-$cert_type-$tool.$domain.cnf -new -out tls/csr/$tool.$domain.$cert_type.csr -outform PEM -passout pass:$ssl_key_password

	# sign the CSR using the intermediate CA
	echo -e "Signing the CSR for: $tool"
	openssl ca -batch -notext -config tls/configs/openssl-intermediateca.cnf -passin pass:$ssl_key_password -policy signing_policy -extensions $extension -out tls/certs/$tool.$domain.$cert_type.cert.pem -infiles tls/csr/$tool.$domain.$cert_type.csr

	# view the signed cert
	#echo -e "Signed certificate for: $tool"
	#openssl x509 -text -noout -in tls/certs/$tool.$domain.$cert_type.cert.pem

	# create a password-less private key (DON'T DO THIS IN PRODUCTION)
	echo -e "Creating password-less private key (.nopass.pem) for: $tool"
	openssl rsa -in tls/keys/$tool.$domain.$cert_type.key.pem -passin pass:$ssl_key_password -out tls/keys/$tool.$domain.$cert_type.key.nopass.pem

	# create pkcs12/pfx container with both private key and signed certificate
	echo -e "Creating PKCS12 for: $tool"
	openssl pkcs12 -export -inkey tls/keys/$tool.$domain.$cert_type.key.pem -in tls/certs/$tool.$domain.$cert_type.cert.pem -passin pass:$ssl_key_password -out tls/certs/$tool.$domain.$cert_type.pkcs12 -passout pass:$ssl_key_password

	# verify the signed cert
	echo -e "Verifying signed certificate for: $tool"
	openssl verify -CAfile tls/certs/ca-chain.cert.pem tls/certs/$tool.$domain.$cert_type.cert.pem

done
