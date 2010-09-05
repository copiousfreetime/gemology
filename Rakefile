
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
}

