# ronin-post_ex

[![CI](https://github.com/ronin-rb/ronin-post_ex/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-post_ex/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-post_ex.svg)](https://codeclimate.com/github/ronin-rb/ronin-post_ex)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-post_ex)
* [Issues](https://github.com/ronin-rb/ronin-post_ex/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-post_ex/frames)
* [Slack](https://ronin-rb.slack.com) |
  [Discord](https://discord.gg/6WAb3PsVX9) |
  [Twitter](https://twitter.com/ronin_rb)

## Description

ronin-post_ex is a Ruby API for Post-Exploitation.

## Features

* Defines a syscall-like API for Post-Exploitation.
* Provides classes for interacting with the Post-Exploitation API.
* Provides classes for interacting with remote resources (files, directories,
  commands, etc).

## Requirements

* [Ruby] >= 2.7.0
* [fake_io] ~> 0.1
* [hexdump] ~> 1.0
* [ronin-core] ~> 0.1

## Install

```shell
$ gem install ronin-post_ex
```

### Gemfile

```ruby
gem 'ronin-post_ex', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-post_ex', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-post_ex/fork)
2. Clone It!
3. `cd ronin-post_ex/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2007-2022 Hal Brodigan (postmodern.mod3 at gmail.com)

This file is part of ronin-post_ex.

ronin-post_ex is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-post_ex is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-post_ex.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[fake_io]: https://github.com/postmodern/fake_io.rb#readme
[hexdump]: https://github.com/postmodern/hexdump.rb#readme
[ronin-core]: https://github.com/ronin-rb/ronin-core#readme
