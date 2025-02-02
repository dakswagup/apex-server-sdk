# Change log

All notable changes to the LaunchDarkly Apex server-side SDK will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org).

## [1.0.0] - 2021-06-08
### Fixed:
- Fixed rollout bucketing behavior when targeting a user attribute that does not exist.

## [1.0.0-beta.3] - 2021-02-04

### Added:
- Added the `alias` method. This can be used to associate two user objects for analytics purposes by generating an alias event.

## [1.0.0-beta.2] - 2021-01-20

### Added:
- Added support for JWT based authentication in the bridge daemon with the `OAUTH_JWT_KEY` environment variable
- Added support for HTTP timeout configuration in the bridge daemon with the `HTTP_TIMEOUT` environment variable

### Fixed:
- Fixed OAuth token expiration handling in the bridge daemon

## [1.0.0-beta.1] - 2020-11-18
This is the first public release of the LaunchDarkly Apex server-side SDK. The SDK is considered to be in beta until release 1.0.0. Do not use this SDK version in production environments.
