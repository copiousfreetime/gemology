
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'gemology'
  authors  'Jeremy Hinegardner'
  email    'jeremy@copiousfreetime.org'
  url      'http://gemology.copiousfreetime.org'

  ignore_file  '.gitignore'
}

