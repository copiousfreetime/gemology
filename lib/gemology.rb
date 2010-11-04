#--
# Copyright (c) 2010 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

## builtin libs
require 'digest/md5'
require 'digest/sha1'
require 'fileutils'
require 'net/http'
require 'stringio'

## rubygems libs
begin
  require 'rubygems'
rescue LoadError
  nil
end

require 'cloudfiles'
require 'configurability/config'
require 'httparty'
require 'json'
require 'logging'
require 'pluginfactory'
require 'resque'
require 'resque/server'
require 'rubygems/format'
require 'rubygems/platform'
require 'rubygems/version'
require 'sequel'
require 'sinatra'

module Gemology
  class Error < ::StandardError; end

  def self.libdir(*args, &block)
    @libdir ||= File.expand_path(__FILE__).sub(/\.rb$/,'')
    libdir = args.empty? ? @libdir : File.join(@libdir, *args.map{|arg| arg.to_s})
  ensure
    if block then
      begin
        $LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.first == libdir
        module_eval( &block )
      ensure
        $LOAD_PATH.shift if $LOAD_PATH.first == libdir
      end
    end
  end

  def self.config_file
    File.expand_path( "~/.gemologyrc" )
  end

  def self.config
    Configurability::Config.load( config_file )
  end

  def self.init
    config.install
    Db.init
  end
end

Gemology.libdir do 
  require 'version'
  require 'logable'
  require 'spec_lite'

  # configurabilty
  require 'cloud_container'
  require 'db'

  require 'gem_version_data'
  require 'web'
  require 'resque_job'
  require 'resque_jobs/fetch_store'
  require 'resque_jobs/extract_metadata'
  require 'resque_jobs/check_fetched'
  require 'specs_to_jobs'
  require 'cloud_container'
  require 'rubygems_client'

  require 'webhook'
  require 'webhook/app'
  require 'webhook/logger'
end

Gemology.init 
