# Changelog

The format of this file is based on [Keep a Changelog](http://keepachangelog.com); this project adheres to [Semantic Versioning](http://semver.org).

## [v0.4.0] - 2025-04-08

Another yet-again long-awaited release! 🥳

As per the title, this mostly includes features, but also includes the usual bug fixes, documentation updates, and maintenance chores.

### Features

##### Add ability to disable sourcing of particular `.env` files

When `cd`ing to a directory with an `.env` (by default) file, `autoenv` used to _always prompt_ to source the file:

```console
$ cd ./dir
autoenv: WARNING:
autoenv: This is the first time you are about to source /home/edwin/autoenv/.hidden/.env:
autoenv:
autoenv:   --- (begin contents) ---------------------------------------
autoenv:     echo '.env has been sourced.'$
autoenv:
autoenv:   --- (end contents) -----------------------------------------
autoenv: Are you sure you want to allow this? (y/N)
```

Even when selecting `n` (no), autoenv would not remember that choice. Now, there is a new option!:

```console
$ AUTOENV_VIEWER=cat cd ./dir
[autoenv] New or modified env file detected:
--- Contents of ".env" --------------------------------------------------------------------------------
echo '.env has been sourced.'
-------------------------------------------------------------------------------------------------------
[autoenv] Authorize this file? (y/n/d)
```

Choose `d` (disable) if you no longer want any "source prompts" for this file. Note that if the file content changes, then your choice is reset and `autoenv` will prompt you yet again.

The `AUTOENV_NOTAUTH_FILE` shell variable is used to configure where this data is stored. Its format is identical to the one in `AUTOENV_AUTH_FILE`.


##### Improve the default `.env` output and support customizing the printer

As you may have noticed in the above example, the prompt has been upgraded to read better, when `AUTOENV_VIEWER` is set to a non-empty variable.

By default, `autoenv` will use the old authorization prompt to reduce disruption for current users that are used to the old prompt. Opt-in by setting `AUTOENV_VIEWER` to a non-empty value, like `cat`. Another good value is `less -N`.

Thanks to @alissa-huskey! (#206)

##### Supports the XDG Base Directory Specification

The [XDG Base Directory Specification](https://xdgbasedirectoryspecification.com) is now adhered to. Some details:
- On a fresh install, both `AUTOENV_AUTH_FILE` and `AUTOENV_NOTAUTH_FILE` are written under `$HOME/.local/state/autoenv`
- If `AUTOENV_AUTH_FILE` is already written under `$HOME`, then the new `AUTOENV_NOTAUTH_FILE` will also be written under there for consistency
- For maximum backwards-compatability, files are not moved to the new location; the old locations can still be used

##### Document useful variables

Before invoking your shell script, `autoenv` sets the following _environment variables_:

- `AUTOENV_CUR_FILE` - The file being sourced
- `AUTOENV_CUR_DIR` - Equivalent to `dirname "$AUTOENV_CUR_FILE"`

These were added a while back in 988723d2e1f5d905e9fcedee7e236a3855185ad5, but were undocumented. Besides convenience, documenting it allows users to be confident that the feature will not be removed. I have also added the checking of these values to the test suite.

##### Prevent overriding `cd` with `AUTOENV_PRESERVE_CD`

By default, `autoenv` runs:

```console
cd() {
	autoenv_cd "${@}"
}
```

This would override any pre-existing `cd` function, making it a bit annoying to work around if a custom `cd` function is desired (and defined before `autoenv` is evaluated).

Now, set `AUTOENV_PRESERVE_CD` to a non-empty string to prevent this behavior. `autoenv_cd` will still be exposed for invocation in custom `cd` functions.

### Fixes

##### Path prefix match accounts for path boundaries

Before, when cding from a/b to a/bz, a/b/.env.leave would not be sourced. Path matching did not use forward slashes as a "cutoff" when testing if directories are different. Now, in the aforementioned situation, the file is properly sourced.

Thanks to @tomtseng! (#238)

##### Fix `.env.leave` when sourcing from a subdirectory

Let's say there exists the following directory structure:

```text
~/project/.env
~/project/.env.leave
~/project/src
```

If the current directory is `~/project/src`, and `cd /` is invoked, `.env.leave` was previously not executed. Now it is.

Thanks to @pashaosipyants! (#211)

##### Fix paths when installing through npm

The npm installation instructions included an incorrect installation path, which would lead to errors if followed. Now, it includes the correct paths.

Thanks to @wesleycoder! (#234)

### Other

And some less noticable, but still notable improvements:

- Improve installation instructions
  - Made instructions more clear for the different operating systems and shells
  - Add automated install script under scripts/install.sh
  - Add documentation for uninstalling and updating
- Various refactoring
- Implement some tests in Bats

## [v0.3.0] - 2021-09-05

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
