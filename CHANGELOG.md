# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- [EBMEDS-1450:](https://jira.duodecim.fi/browse/EBMEDS-1450) Upgraded the Elastic stack version to v7.6.0

### Added
- [EBMEDS-1374:](https://jira.duodecim.fi/browse/EBMEDS-1374) Added index lifecycle management for the EBMEDS indices

## V2.4.0 - 2019-11-04

- [EBMEDS-1373:](https://jira.duodecim.fi/browse/EBMEDS-1373) Changed elasticsearch indices to be monthly instead of daily.

### Added
- [EBMEDS-1279:](https://jira.duodecim.fi/browse/EBMEDS-1279) Added dsv service to the docker-compose definition
- [EBMEDS-1319:](https://jira.duodecim.fi/browse/EBMEDS-1319) Added the package.json that is required by the Sirppi release-script

### Removed
- [EBMEDS-1230:](https://jira.duodecim.fi/browse/EBMEDS-1230) Removed clinical-datastore from the stack
- [EBMEDS-1242:](https://jira.duodecim.fi/browse/EBMEDS-1242) Removed the format-converter from the docker-compose definition
- [EBMEDS-1192:](https://jira.duodecim.fi/browse/EBMEDS-1192) Removed Redis from docker-swarm
- [EBMEDS-1285:](https://jira.duodecim.fi/browse/EBMEDS-1285) Removed the unnecessary LICENSE file
