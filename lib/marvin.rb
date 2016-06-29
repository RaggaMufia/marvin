require_relative 'marvin/version'
require_relative 'marvin/logger'
require_relative 'marvin/configuration'

# This module contains all of the classes belonging to Marvin.
module Marvin
  class << self
    attr_accessor :configuration
  end

  # Allows for setting configuration directly on the +Marvin+ module.
  #
  # @yield [c] A +Configuration+ object to set options on.
  # @return [nil]
  def self.configure
    self.configuration ||= Configuration.new

    yield(configuration)
  end
  
  # A helper method to get to the logger.
  #
  # @return [Marvin::Logger] Our sweet logger.
  def self.logger
    self.configuration.logger
  end
end
