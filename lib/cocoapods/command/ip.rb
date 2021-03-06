require 'cocoapods/command/ip/create'
require 'cocoapods/command/ip/get'
require 'cocoapods/command/ip/get_with_shell'
require 'cocoapods/command/ip/get_with_board'
require 'cocoapods/command/ip/make'
require 'cocoapods/command/ip/install'

module Pod
  class Command
    class Ip < Command
      self.abstract_command = true
      self.summary = 'Develop with hardware IP'
    end
  end
end
