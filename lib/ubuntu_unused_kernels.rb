require "ubuntu_unused_kernels/version"

module UbuntuUnusedKernels
  PACKAGE_PREFIXES = %w{linux-image linux-headers}

  class << self
    def to_remove
      packages = get_installed

      PACKAGE_PREFIXES.each do |prefix|
        latest = packages.select { |package| package.start_with?(prefix) }.last
        packages.delete(latest)
      end

      return packages
    end

    def get_installed
      return []
    end

    def get_current
      return ''
    end
  end
end
