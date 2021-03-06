# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'defaulter/version'

Gem::Specification.new do |gem|
  gem.name          = "defaulter"
  gem.version       = Defaulter::VERSION
  gem.authors       = ["Amol Hatwar"]
  gem.email         = ["amol@hatwar.org"]
  gem.description   = %q{Mark and maintain default ActiveRecord records.}
  gem.summary       = %q{Often ActiveRecord is used to return a collection of objects, for example a user can have many email addresses. But which email address to use to send an email? That is where marking one object in the collection as default comes in. The defaulter gem does it simply and elegantly, with the minimum amount of code.}
  gem.homepage      = "https://github.com/AxisOfEval/defaulter"

  gem.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  gem.test_files = Dir["test/**/*"]
  gem.add_dependency "rails", ">= 3.2.0"
  gem.add_development_dependency "sqlite3"
end
