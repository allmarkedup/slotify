Gem::Specification.new do |gem|
  gem.name = "slotify"
  gem.version = "0.0.0"
  gem.summary = "Superpowered slots for your Rails partials."
  gem.authors = ["Mark Perkins"]
  gem.license = "MIT"

  gem.files = Dir["{lib}/**/*", "LICENSE.txt", "README.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1.0"

  gem.add_dependency "zeitwerk"
  gem.add_dependency "actionview"
end
