# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.1] - ??

### Fixed
- Remove debug output
- Paths with spaces on dash
- Custom names for .env
- Usage of double slashes
- Infinite loop when symlinking across mountpoints

## [0.2.0] - 2016-08-08

### Added
- setup.py for pyPi
- setup.py in the Makefile
- Support for OS X
- Support for the dash shell
- Accept 'y' or 'Y' as answer
- Expose `AUTOENV_CUR_FILE` and `AUTOENV_CUR_DIR`

### Fixed
- Fix spaces in filenames
- Strange grep behaviour
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
- Follow .env files until the moutpoint

### Security
- Add quotes everywhere in the shell script
- Print hidden characters

## [0.1.0] - 2012-02-15

### Added
- .env files need approval now

### Fixed
- Execution on zsh

### Changed
- Put autoenv under a public license

## [0.0.1] - 2012-02-13

### Added
- Initial public version of autoenv
- Allwos executing .env files recursively
- Makefile for testing
- Unit tests with dtf
- Travis file for testing

[0.0.1]: https://github.com/kennethreitz/autoenv/releases/tag/v0.0.1
[0.1.0]: https://github.com/kennethreitz/autoenv/releases/tag/v0.1.0
[0.2.0]: https://github.com/kennethreitz/autoenv/releases/tag/v0.2.0
[0.2.1]: https://github.com/kennethreitz/autoenv
