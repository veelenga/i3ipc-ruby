# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i3ipc/version'

Gem::Specification.new do |spec|
  spec.name          = 'i3ipc'
  spec.version       = I3ipc::VERSION
  spec.authors       = ['Vitalii Elengaupt']
  spec.email         = ['velenhaupt@gmail.com']
  spec.summary       = 'Interprocess communication with i3 wm'
  spec.description   = <<-DESC
    Implementation of interface for i3 tiling window manager.
    Useful for example to remote-control i3 or to get various
    information like the current workspace to implement an
    external workspace bar etc. in Ruby language.
  DESC
  spec.homepage      = 'https://github.com/veelenga/i3ipc-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
