require 'logger'

module CM

  # utility module for Logger
  module Util
    def new_logger
      Logger.new(STDOUT)
    end
  end
end