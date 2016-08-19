# Homebrew-versions

These formulae provide multiple versions of existing packages, or  newer versions of packages that are too incompatible to go in homebrew/core yet *(Such as GnuPG21)*.

## How do I install these formulae?

Just `brew tap homebrew/versions` and then `brew install <formula>`.

If the formula conflicts with one from `homebrew/core` or another tap, you can `brew install homebrew/versions/<formula>`.

You can also install via URL:

```
brew install https://raw.githubusercontent.com/Homebrew/homebrew-versions/master/<formula>.rb
```

## Acceptable Formulae.

**Please note that `homebrew/versions` is currently in the process of major changes in what we support, how long for and on what basis.**

Versions is not intended to be used for all and any old versions you personally require for xyz project; formulae submitted here should be expected to be used by a reasonable number of people and supported by contributors long-term.

You may wish to consider hosting your own [tap](https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/How-to-Create-and-Maintain-a-Tap.md) for formulae you wish to personally support that do not meet the above standards.

You can read Homebrew’s Acceptable Formulae document [here](https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Acceptable-Formulae.md). There are some differences between `homebrew/core` (which these guidelines cover) and here:

* Versions formulae *must* not exceed +/-2 major/minor (not patch) versions from the current stable release.
* Versions formulae *usually* do not have head or devel sections.
* Versions formulae *can* depend on other versions formulae.
* If copied from `homebrew/core` prior formulae please remove any deprecated options and fix any issues raised by `brew audit --strict`.
* If a newer/older version exists in `homebrew/core` please add a `conflicts_with` line, like [this](https://github.com/Homebrew/homebrew-versions/commit/c70582a2055ea6649cc1974076f57001f8c471a3).

## Troubleshooting
First, please run `brew update` and `brew doctor`.

Second, read the [Troubleshooting Checklist](https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Troubleshooting.md#troubleshooting).

**If you don’t read these it will take us far longer to help you with your problem.**

## More Documentation

`brew help`, `man brew` or check [our documentation](https://github.com/Homebrew/brew/tree/master/share/doc/homebrew#readme).

## License
Code is under the [BSD 2 Clause (NetBSD) license](https://github.com/Homebrew/homebrew/tree/master/LICENSE.txt).
