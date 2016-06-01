class BaseService
  class MissingArgumentError < StandardError
    attr_accessor :name

    def initialize(name, message = nil)
      super(message || "argument `#{name}` is missing")
      @name = name
    end
  end
end