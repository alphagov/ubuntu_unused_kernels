require "ubuntu_unused_kernels/version"
require "open3"

module UbuntuUnusedKernels
  PACKAGE_PREFIXES = %w{linux-image linux-headers}
  VERSION_GLOB = '*.*.*-*'
  VERSION_REGEX = %r{\d+\.\d+\.\d+-\d+}

  class << self
    def to_remove
      current = get_current
      packages = get_installed

      latest = packages.map { |package|
        package.match(VERSION_REGEX)[0]
      }.sort.last

      packages.reject! { |package|
        package =~ /\b#{Regexp.escape(current)}\b/ ||
        package =~ /\b#{Regexp.escape(latest)}\b/
      }

      return packages
    end

    def get_current
      uname = Open3.capture2('uname', '-r')
      raise "Unable to determine current kernel" unless uname.last.success?

      match = uname.first.chomp.match(/^(#{VERSION_REGEX})-[[:alpha:]]+$/)
      raise "Unable to determine current kernel" unless match

      return match[1]
    end

    def get_installed
      args = PACKAGE_PREFIXES.collect { |prefix|
        "#{prefix}-#{VERSION_GLOB}"
      }
      dpkg = Open3.capture2(
        'dpkg-query', '--show',
        '--showformat', '${Package}\n',
        *args
      )
      raise "Unable to get list of packages" unless dpkg.last.success?

      packages = dpkg.first.split("\n")
      raise "No kernel packages found" if packages.empty?

      return packages
    end
  end
end
