module Ruby3d::Core::Settings
  class SettingsError < Exception
    def initialize(msg)
      super(msg)
    end
  end
end