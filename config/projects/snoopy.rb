#
# Copyright 2015 YOUR NAME
#
# All Rights Reserved.
#

name "snoopy"
maintainer "CHANGE ME"
homepage "https://CHANGE-ME.com"

# Defaults to C:/snoopy on Windows
# and /opt/snoopy on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# snoopy dependencies/components
dependency "snoopy"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
