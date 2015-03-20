require "ubuntu_unused_kernels/version"
require "open3"

module UbuntuUnusedKernels
  PACKAGE_PREFIXES = %w{linux-image linux-headers}
  KERNEL_VERSION = %r{\d+\.\d+\.\d+-\d+}

  class << self
    def to_remove
      current, suffix = get_current
      packages = get_installed(suffix)

      PACKAGE_PREFIXES.each do |prefix|
        latest = packages.sort.select { |package|
          package =~ /^#{prefix}-#{KERNEL_VERSION}-#{suffix}$/
        }.last

        packages.delete(latest)
        packages.delete("#{prefix}-#{current}-#{suffix}")
      end

      return packages
    end

    def get_current
      uname = Open3.capture2('uname', '-r').first.chomp
      match = uname.match(/^(#{KERNEL_VERSION})-([[:alpha:]]+)$/)

      return match[1], match[2]
    end

    def get_installed(suffix)
      return []
    end
  end
end
