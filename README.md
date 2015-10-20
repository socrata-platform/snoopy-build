Snoopy Omnibus Project
======================
[![Build Status](https://img.shields.io/travis/RoboticCheese/snoopy-omnibus.svg)][travis]

[travis]: https://travis-ci.org/RoboticCheese/snoopy-omnibus

This project creates full-stack, platform-specific packages for Snoopy Logger.

Installation
------------
You must have a sane Ruby 1.9+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

Usage
-----
This project comes with a Test Kitchen config that handles all the builds
automatically for the supported platforms. Normally, the CI server will kick
off a Kitchen run, which will build the package, install it, verify the
results, and publish the new package to PackageCloud.io.

Should the need arise, Omnibus commands can still be manually run...

***Build***

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build snoopy
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

***Clean***

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean snoopy
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/snoopy`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean snoopy --purge
```

***Publish***

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

***Help***

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Version Manifest
----------------
Git-based software definitions may specify branches as their
default_version. In this case, the exact git revision to use will be
determined at build-time unless a project override (see below) or
external version manifest is used.  To generate a version manifest use
the `omnibus manifest` command:

```
omnibus manifest PROJECT -l warn
```

This will output a JSON-formatted manifest containing the resolved
version of every software definition.

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@hartman.io>

Copyright 2015 Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
