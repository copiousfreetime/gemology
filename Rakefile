
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

Bones {
  name  'gemology'
  authors  'Jeremy Hinegardner'
  email    'jeremy@copiousfreetime.org'
  url      'http://gemology.copiousfreetime.org'

  ignore_file  '.gitignore'

  depend_on 'resque',           :version => "~> 1.10.0"
  depend_on 'cloudfiles',       :version => "~> 1.4.8"
  depend_on 'sinatra',          :version => "~> 1.0"
  depend_on 'trollop',          :version => "~> 1.16.2"
  depend_on 'logging',          :version => "~> 1.4.3"
  depend_on 'pluginfactory',    :version => "~> 1.0.7"
  depend_on 'configurability',  :version => "~> 1.0.2"
  depend_on 'sequel',           :version => "~> 3.16.0"
  depend_on 'pg',               :version => "~> 0.9.0"
  depend_on 'json',             :version => "~> 1.4.6"

  depend_on 'bones',         :version => "~> 3.4.7", :development => true
  depend_on 'bones-extras',  :version => "~> 1.2.4", :development => true
  depend_on 'rspec',         :version => "~> 1.3.0", :development => true
  depend_on 'rcov',          :version => "~> 0.9.8", :development => true
}

desc "Test that all the files are loaded"
task :load_check do
  libdir = File.join( File.expand_path( File.dirname( __FILE__ ) ), 'lib' )
  $LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
  require 'gemology'
  FileList[ "#{libdir}/**/*.rb" ].each do |gfile|
    puts "#{gfile} not loaded" unless $LOADED_FEATURES.include?( gfile )
  end
end

