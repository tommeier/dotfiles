# RSpec TextMate Bundle

## Installation

    mkdir -p ~/Library/Application\ Support/TextMate/Pristine\ Copy/Bundles
    cd ~/Library/Application\ Support/TextMate/Pristine\ Copy/Bundles
    git clone git://github.com/rspec/rspec-tmbundle.git RSpec.tmbundle
    osascript -e 'tell app "TextMate" to reload bundles'

## Support for both RSpec-1 and RSpec-2

This `RSpec.tmbundle` works with both rspec-1 and rspec-2. Given
that they work differently, the `RSpec.tmbundle` tries its best to
figure out which one you're using in each project when you try to
run RSpec examples. There are two separate parts to this process,
and you have some control over how each one works.

### LOAD_PATH

The `RSpec.tmbundle` prepares the `LOAD_PATH` as follows:

1. If a `Gemfile` is present, `Bundler` is used to prepare the
Load Path with `requires 'bundler'` and then `Bundler.setup` is
executed. (This can be overridden - see below).

2. If `Bundler` isn't being used, `vendor/plugins` and
`vendor/gems` are searched for `rspec`. If `rspec` is found, then
it's `lib` directory is added to `LOAD_PATH`.

### RSpec-version

Once the `LOAD_PATH` is prepared, `RSpec-tmbundle` tries to
determine which version of RSpec to use as follows:

1. `RSpec-tmbundle` checks for an `./rspec-tm` file in the
project's root directory. If that file is exists, then
`RSpec-tmbundle` attempts to set the RSpec version from the
configuration found there.

To configure the version using this method add a file named
`.rspec-tm` to the project's root directory containing:

    --rspec-version 2.0.0

or whichever version you are using. 

This is the one foolproof way to ensure that the right version is
invoked, but you don't really need to do this in most cases.

2. If no version is configured, `RSpec-tmbundle` searches for
`rspec` in the `vendor/gems` and the `vendor/plugins` directories.
If `rspec` is found, `RSpec-tmbundle` determines the version to
use based on the files present there.

3. If no version is configured and no rspec directory could be
found in vendor, then `RSpec-tmbundle` attempts to run rspec-2
with:

    require 'rspec/core'

If that raises an exception, `RSpec-tmbundle` makes a final
attempt by trying to run rspec-1 with:

    require 'spec/autorun'

### Which Approach Should I Use?

The effectiveness of each approach is partially dependent on how
you manage your gem environment. The simplest (and suggested)
approach is to first just see if it just works, and if not, then
configure the version you want in the `.rspec-tm` file.

## Rubygems

The RSpec TextMate bundle does not `require "rubygems"` so that
users who choose other packaging mechanisms can still use it. If
you _are_ using Rubygems as your package manager, then the
simplest thing to do is

* open the TextMate Preferences
* go to the `Advanced` tab
* add a variable named `RUBYOPT` with the value `rubygems`

## Options

You can set the following options in an `.rspec-tm` file in the
root directory of your project:

### --rspec-version

see RSpec-version, above.

### --bundler

Use `Bundler`, even if there is no `Gemfile` (in which case you
should have the `BUNDLER_GEMFILE` environment variable set).

### --skip-bundler

Don't use `Bundler`, even if there is a `Gemfile`.

## TextMate shell variables

In addition to the standard TextMate shell variables, the RSpec
TextMate bundle supports the following:

### TM_RSPEC_FORMATTER

Set a custom formatter other than RSpec's TextMate formatter. Use
the full classname, e.g. `'Spec::Core::Formatters::WebKit'`

### TM_RSPEC_OPTS

Use this to set RSpec options just as you would in an `.rspec`
file.

### TM_RSPEC_HOME

If you're hacking on rspec yourself, point this to the
`rspec-core` project directory for rspec-2, or the `rspec`
directory for rspec-1.

## RVM Integration

There are lots of ways to configure TextMate to work with `rvm`,
but this is the one the we recommend:

First, copy the following into` ~/.rvm/bin/textmate_ruby`

    #!/usr/bin/env sh
    source ~/.rvm/scripts/rvm
    cd .
    exec ruby "$@"

Next, set up a `TM_RUBY` option in
`TextMate/Preferences/Advanced/Shell Variables` that points to the
`textmate_ruby` command.

Learn more at:

* [http://beginrescueend.com/integration/textmate/](http://beginrescueend.com/integration/textmate/)
* [http://groups.google.com/group/rubyversionmanager/browse_thread/thread/64b84bbcdf49e9b?fwc=1&pli=1](http://groups.google.com/group/rubyversionmanager/browse_thread/thread/64b84bbcdf49e9b?fwc=1&pli=1)

## History

Parts of `RSpec.tmbundle` are based on Florian Weber's TDDMate.

## License

The license of `RSpec.tmbundle` is the same as
[RSpec](http://github.com/rspec/rspec/blob/master/License.txt)'s.

