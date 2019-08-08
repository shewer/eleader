module Eleader
  Encode= ['utf-8','big5']
  require "eleader/version"
  require "eleader/struct"
  if RUBY_PLATFORM.match?(/mingw/)
    require 'eleader/api'
  end 
  class Error < StandardError; end
  class InitError < StandardError; end
  class AccountCAError < StandardError; end
  class VerifyCAError < StandardError; end
  # Your code goes here...
  class Future

    def initialize(hash)
      @data=hash 

    end 


  end 
end
