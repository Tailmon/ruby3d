module Ruby3d::Assets
  class AssetError < Exception
    def initialize(msg)
      super(msg)
    end
  end
end