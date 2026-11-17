AcmeFetch
=========

[![CI](https://github.com/oposs/AcmeFetch/actions/workflows/ci.yml/badge.svg)](https://github.com/oposs/AcmeFetch/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/oposs/AcmeFetch)](https://github.com/oposs/AcmeFetch/releases/latest)

acmefetch fetches and renews TLS certificates from Let's Encrypt. It reads a
list of certificates from its configuration, checks whether each certificate
covers all its names and stays valid for 30 more days, and renews the ones
that do not through the ACME `http-01` challenge, using the Perl library
Net::ACME2.

Install
-------

The packages install acmefetch under `/opt/acmefetch`, with the Perl modules
it needs bundled, and link `/usr/bin/acmefetch` to it. acmefetch reads
`/etc/acmefetch/acmefetch.cfg`; an example is in
`/usr/share/doc/acmefetch/examples/acmefetch.cfg.dist`.

Debian and Ubuntu:

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL -o /etc/apt/keyrings/gitea-oposs.asc https://gitea.oetiker.ch/api/packages/oposs/debian/repository.key
echo "deb [signed-by=/etc/apt/keyrings/gitea-oposs.asc] https://gitea.oetiker.ch/api/packages/oposs/debian $(. /etc/os-release && echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/oposs.list
sudo apt update && sudo apt install acmefetch
```

AlmaLinux and Fedora (`el9`, `el10` or `fc45`, after the release of the
system):

```sh
sudo curl -fsSL -o /etc/yum.repos.d/oposs.repo https://gitea.oetiker.ch/api/packages/oposs/rpm/el10.repo
sudo dnf install acmefetch
```

Alpine (`v3.23` or `v3.24`, after the release of the system):

```sh
cd /etc/apk/keys && sudo curl -fJO https://gitea.oetiker.ch/api/packages/oposs/alpine/key
echo "https://gitea.oetiker.ch/api/packages/oposs/alpine/v3.24/main" | sudo tee -a /etc/apk/repositories
sudo apk update && sudo apk add acmefetch
```

From source: download the tarball from
https://github.com/oposs/AcmeFetch/releases/latest, then

```sh
./configure
make
make check
sudo make install
```

Without `--prefix`, this installs to `/opt/acmefetch` and acmefetch reads
`/etc/acmefetch/acmefetch.cfg`; with `--prefix=DIR` it reads
`DIR/etc/acmefetch.cfg`. `make` downloads the Perl modules named in
`cpanfile` from CPAN into `thirdparty/` and builds them, so it needs perl,
curl or wget, unzip, make, a C compiler and the OpenSSL headers:

    apt-get install perl make gcc libssl-dev zlib1g-dev unzip curl openssl
    dnf install perl perl-devel make gcc openssl-devel zlib-devel unzip curl openssl

From a git checkout, run `./bootstrap` first, which needs autoconf and
automake.

Running
-------

```sh
acmefetch --checkonly --verbose
acmefetch
```

`--checkonly` reports the certificates that are missing, lack a configured
name or expire within 30 days, and changes nothing. Without it, acmefetch
renews those certificates and writes the new certificate and key to the
configured files; the old files are kept with a timestamp appended to their
name. Reload the web server afterwards so it uses the new files. `--force`
renews every certificate, `--staging` uses the Let's Encrypt staging
service, `--cfg=FILE` reads another configuration. `acmefetch --man` shows
the manual.

Configuration
-------------

The configuration is a JSON file. `GENERAL` names the ACME account key,
which acmefetch creates when it is missing. `CERTS` lists the certificates,
each with its output files, its common name and under `SITES` every name it
covers. For each name, `www_root` is the document root where the web server
serves `/.well-known/acme-challenge/` for the `http-01` challenge.

```json
{
    "GENERAL": {
        "accountKeyPath": "/etc/ssl/private/letsencryptAccountKey.key"
    },
    "CERTS": [
        {
            "certOutput": "/etc/ssl/certs/my.web.domain.pem",
            "keyOutput": "/etc/ssl/private/my.web.domain.key",
            "commonName": "my.web.domain",
            "SITES": {
                "my.web.domain": {
                    "challengeConfig": { "www_root": "/var/www/my.web.domain/" }
                }
            }
        }
    ]
}
```

The certificate file holds the certificate followed by the chain, as nginx
expects it. https://letsencrypt.org/how-it-works/ explains the challenge.

License
-------

GNU General Public License version 3 or later, see `LICENSE`.

Tobias Oetiker <tobi@oetiker.ch>
