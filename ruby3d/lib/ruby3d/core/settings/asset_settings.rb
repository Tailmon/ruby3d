module Ruby3d::Core::Settings
  class AssetSettings
    attr_accessor :paths

    def initialize
      @paths = Array.new
    end

    def add_path(path)
      @paths << path
    end
  end
end
