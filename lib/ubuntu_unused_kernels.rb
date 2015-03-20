require "ubuntu_unused_kernels/version"

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
      return '', ''
    end

    def get_installed(suffix)
      return []
    end
  end
end
