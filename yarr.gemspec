Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name        = "yarr"
  spec.version     = "0.0.1"
  spec.summary     = "YARR. Yet Another Ruby REPL"
  spec.description = "YARR. Yet Another Ruby REPL. A Ruby REPL (just a hobby, won't be big and professional like pry)"
  spec.author      = "Arturo Herrero"
  spec.email       = "arturo.herrero@gmail.com"
  spec.homepage    = "https://github.com/arturoherrero/yarr"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.0.0"

  spec.files         = Dir["{bin,lib}/**/*", "LICENSE", "README.md"]
  spec.test_files    = Dir["spec/**/*"]
  spec.require_paths = ["lib"]
  spec.executables   = ["yarr"]

  spec.add_development_dependency "guard-rspec", "~> 4.5"
  spec.add_development_dependency "rspec", "~> 3.2"
end
