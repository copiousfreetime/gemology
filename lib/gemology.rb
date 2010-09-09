#--
# Copyright (c) 2010 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
module Gemology
  class Error < ::StandardError; end
end
require 'gemology/paths'
require 'gemology/version'
require 'gemology/web'
require 'gemology/webhook'
require 'gemology/logable'
require 'gemology/spec_lite'

