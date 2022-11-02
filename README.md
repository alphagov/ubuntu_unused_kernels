# ubuntu-unused-kernels

**This project was archived in October 2022 and is no longer maintained.**

Identify old kernel packages that can be deleted from Ubuntu machines. It
will omit the currently running kernel and the latest kernel that would be
used if the machine was rebooted.

## Installation

Add this line to your application's Gemfile:

    gem 'ubuntu_unused_kernels'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ubuntu_unused_kernels

## Usage

```
sudo apt-get purge $(ubuntu-unused-kernels)
```

## Contributing

1. Fork it ( http://github.com/gds-operations/ubuntu_unused_kernels/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
