# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
except that the first subsection is called `New` rather than `Added`. The release
workflow matches on `### New`; renaming it silently drops the section from the
release notes.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### New
- Each release ships `.deb` and `.rpm` packages for Debian 12 and 13, Ubuntu 22.04, 24.04 and 26.04, AlmaLinux 9 and 10 and Fedora (Alpine 3.23 and 3.24 in a later release), published to the package registry at gitea.oetiker.ch (owner `oposs`), and a source tarball. The package installs acmefetch with the Perl modules it needs under `/opt/acmefetch`, links `/usr/bin/acmefetch` to it, reads `/etc/acmefetch/acmefetch.cfg` and puts the example configuration under `/usr/share/doc/acmefetch/examples/`.
- `make check` runs a test of the command line, the configuration check and `--checkonly`.

### Changed
- `./configure` without `--prefix` installs to `/opt/acmefetch` instead of `/opt/AcmeFetch-<version>`, and acmefetch then reads `/etc/acmefetch/acmefetch.cfg` when `--cfg` is not given. With `--prefix` the configuration stays in `<prefix>/etc`.
- The build downloads cpanminus with curl without accepting an invalid certificate.
- This file replaces `CHANGES`, which listed the git log.

### Fixed
- `acmefetch --version` printed `0.dev` when built from a git checkout; it now prints the version it was built from.
- `make install` without `PERL5LIB` set no longer edits `bin/acmefetch` in the source tree.

## 0.8.1 - 2022-11-14
### Fixed
- `make install` works again.

## 0.8.0 - 2022-11-14
### New
- Builds and runs with OpenSSL 3.

### Changed
- The `chainOutput` and `chainFormat` keys are no longer supported; the chain is written after the certificate into the `certOutput` file.

## 0.7.5 - 2020-08-12
### Fixed
- Challenges are handled correctly again.

## 0.7.4 - 2020-08-03
### Changed
- Better logging.

## 0.7.3 - 2020-07-28
### Fixed
- The version number is shown correctly.

## 0.7.2 - 2020-07-28
### Changed
- Better error handling; leftovers of the ACME v1 protocol removed.

## 0.7.1 - 2020-06-10
### New
- Supports OpenSSL 1.1.

## 0.7.0 - 2020-06-10
### Changed
- Uses Net::ACME2 and the ACME v2 protocol.
- The build honours `--sysconfdir`.
- A note after each run reminds you to restart the web server.

## 0.6.2 - 2017-08-22
### Fixed
- Mozilla::CA is installed explicitly.

## 0.6.1 - 2017-05-22
### Fixed
- A bad certificate no longer stops acmefetch.

## 0.6.0 - 2017-04-06
### New
- Without the chain options, certificate and chain are written to the `certOutput` file.
- Names the file of a certificate that expires within 30 days.

## 0.5.1 - 2017-02-07
### Changed
- Updated dependencies, including a Crypt::OpenSSL::X509 that builds with gcc 5.

## 0.5.0 - 2016-05-09
### Changed
- Uses Protocol::ACME 0.12.
- Challenge tokens are removed from the web site after use.
- Old certificate files are renamed before new ones are installed.

## 0.4.2 - 2016-04-04
### Changed
- configure checks for unzip and no longer tests for Perl modules.

## 0.4.1 - 2016-02-23
### Fixed
- configure checks the environment before building Perl modules; configuration file fix.

## 0.4.0 - 2016-02-13
### New
- `--checkonly` option.
- The format of certificates and keys is configurable.

### Changed
- Uses Protocol::ACME 0.11.

## 0.3.4 - 2016-01-26
### Fixed
- Version string.

## 0.3.3 - 2016-01-26
### Changed
- More documentation.

## 0.3.2 - 2016-01-26
### New
- Progress reporting.

## 0.3.1 - 2016-01-25
### Fixed
- On-demand rebuild of dependencies; SSL dependency added.

## 0.3.0 - 2016-01-25
### Changed
- Only certificates that expire or lack a configured name are renewed.

## 0.2.2 - 2016-01-25
### Fixed
- JSON::PP is built as a dependency.

## 0.2.1 - 2016-01-20
### Fixed
- Re-release for Protocol::ACME 0.09.

## 0.2.0 - 2016-01-18
### New
- `--staging` option.

## 0.1.1 - 2016-01-18
### Fixed
- Works with a single site.

## 0.1.0 - 2016-01-18
### New
- First release.
