module Ruby3d::Core::Settings
  class VideoSettings
    attr_accessor :x_resolution
    attr_accessor :y_resolution

    def initialize(x = 800, y = 600)
      @x_resolution = x
      @y_resolution = y
    end
  end
end