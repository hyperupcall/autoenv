# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [v0.3.0] - 2021-9-5

### Fixed

- Leave `$OLDPWD` intact (#141)
- `AUTOENV_CUR_DIR` contains leading double quote (#150)
- Prevent any alias usage (#144)
- Broken mountpoint detection (#151)
- Add `AUTOENV_ASSUME_YES` (#162)
- Execute `.env.leave` when leaving directory (#167)
- Ensure parent directory of `AUTOENV_AUTH_FILE` exists (#201)
- Improve platform compatibility (#174, #176, #202)

## [v0.2.1] - 2016-10-18

### Fixed

- Remove debug output (#126)
- Paths with spaces on dash
- Custom names for .env (#109)
- Usage of double slashes (#125)
- Infinite loop when symlinking across mountpoints (#133)
- Don't allow chdir aliases
- Mountpoint detection (#138 #139)
- No more override of `$OLDPWD` (#141)
- .env files at mountpoint are now being found (#146)

## [v0.2.0] - 2016-08-08

### Added

- setup.py for pyPi
- setup.py in the Makefile
- Support for OS X
- Support for the dash shell
- Accept 'y' or 'Y' as answer
- Expose `AUTOENV_CUR_FILE` and `AUTOENV_CUR_DIR`

### Fixed

- Fix spaces in filenames
- Strange grep behavior
- Look for a .env file when activating autoenv
- Fix sha1sum not being found
- Support aliased cd
- Require .env to be a regular file
- autoenv now works with noclobber
- Crash with zsh 5.1

### Changed

- Don't run in mc
- Updated readme
- Export all variables
- Rewrote tests
- Follow .env files until the mountpoint

### Security

- Add quotes everywhere in the shell script
- Print hidden characters

## [v0.1.0] - 2012-02-15

### Added

- .env files need approval now

### Fixed

- Execution on zsh

### Changed

- Put autoenv under a public license

## [v0.0.1] - 2012-02-13

### Added

- Initial public version of autoenv
- Allows executing .env files recursively
- Makefile for testing
- Unit tests with dtf
- Travis file for testing

[v0.0.1]: https://github.com/inishchith/autoenv/releases/tag/v0.0.1
[v0.1.0]: https://github.com/inishchith/autoenv/releases/tag/v0.1.0
[v0.2.0]: https://github.com/inishchith/autoenv/releases/tag/v0.2.0
[v0.2.1]: https://github.com/inishchith/autoenv/releases/tag/v0.2.1
[v0.3.0]: https://github.com/inishchith/autoenv/releases/tag/v0.3.0
