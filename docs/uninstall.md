# Uninstall

The uninstallation procedure depends on your installation method.

## Method

### Homebrew

If you installed autoenv with homebrew, run the following:

```sh
$ brew uninstall 'autoenv'
```

### With npm

If you installed autoenv with npm, run the following:

```sh
$ npm uninstall -g '@hyperupcall/autoenv'
```

### With Git

If you installed autoenv with Git, run the following:

```sh
rm -rf ~/.autoenv
```

## Post Cleanup

After uninstalling autoenv, your shell may still contain parts of autoenv in memory. To prevent executing these parts, run the following in each open terminal:

```sh
unset -f 'cd'
```

Note that the `-f` is important. This removes autoenv's custom `cd` _function_ and allows the shell to use its own `cd` _builtin_ instead.
