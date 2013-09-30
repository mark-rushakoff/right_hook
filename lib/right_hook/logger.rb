module RightHook
  class << self
    def logger
      @logger || Logger.new(File::NULL)
    end

    def logger=(logger)
      @logger = logger
    end
  end
end
