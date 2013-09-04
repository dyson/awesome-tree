$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "awesome-tree/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "awesome-tree"
  s.version     = AwesomeTree::VERSION
  s.authors     = ["Dyson Simmons"]
  s.email       = ["dysonsimmons@gmail.com"]
  s.homepage    = "http://www.dysonsimmons.com"
  s.summary     = "ActiveRecord tree structures using PostgreSQL"
  s.description = "Add awesome-treeify to your models along with a parent_id field and get access to ancestors and descendents."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "pg"
end
