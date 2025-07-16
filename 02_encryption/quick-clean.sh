#!/bin/bash

read -e -p "Delete all TLS files (except configs)? (y/n) " yesno
if [[ $yesno =~ [Yy] ]]; then
	echo "deleting files"
	rm -rf tls/{caroot,caintermediate,keys,certs,csr}/*
elif [[ $yesno =~ [Nn] ]]; then
	echo "exiting"
else
	echo "No answer provided, exiting"
fi
