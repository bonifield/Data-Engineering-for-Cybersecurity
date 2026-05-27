# Data Engineering for Cybersecurity
Official repository for code snippets from [Data Engineering for Cybersecurity, available from No Starch Press as of July 2025](https://nostarch.com/data-engineering-cybersecurity).

## All passwords and passphrases in this book are `abcd1234` unless otherwise specified!

# Errata

## Chapter 6

- As of Elastic 9.x, when installing Elastic Agent the first time as a Fleet Server, add the `--install-servers` parameter [ref 1](https://www.elastic.co/docs/reference/fleet/install-standalone-elastic-agent) [ref 2](https://www.elastic.co/docs/reference/fleet/install-elastic-agents#elastic-agent-installation-flavors) (relevant to book page 113)

- As of Elastic 9.x, when adding the Elasticsearch output for your Fleet Server, there are now sections to paste in your signed certificate, private key, and certificate authorities. You may just paste the certificate authorities in the appropriate section, instead of pasting in Advanced YAML configuration. (relevant to book page 111)
