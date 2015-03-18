require "ubuntu_unused_kernels/version"

module UbuntuUnusedKernels
  class << self
    def to_remove
      packages = get_installed
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
