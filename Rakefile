
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

  depend_on 'resque',     :version => "~> 1.10.0"
  depend_on 'cloudfiles', :version => "~> 1.4.8"
  depend_on 'sinatra',    :version => "~> 1.0"
  depend_on 'trollop',    :version => "~> 1.16.2"
  depend_on 'logging',    :version => "~> 1.4.3"
  depend_on 'amalgalite'  :version => "~> 0.12.0"
  depend_on 'pluginfactory' :version => "~> 1.0.7"

  depend_on 'bones', :development => true
  depend_on 'bones-extras', :version => "~> 1.2.4", :development => true

  depend_on 'rspec', :version => "~> 1.3.0", :development => true
  depend_on 'rcov',  :version => "~> 0.9.8", :development => true
}

