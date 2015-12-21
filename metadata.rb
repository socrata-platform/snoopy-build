# Encoding: UTF-8
#
# rubocop:disable SingleSpaceBeforeFirstArg
name             'snoopy-build'
maintainer       'Jonathan Hartman'
maintainer_email 'jonathan.hartman@socrata.com'
license          'apache2'
description      'Builds Snoopy packages'
long_description 'Builds Snoopy packages'
version          '0.0.1'

depends          'apt'
depends          'build-essential'
depends          'yum-epel'

supports         'ubuntu'
# rubocop:enable SingleSpaceBeforeFirstArg
