# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fnsapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'fnsapi'
  spec.version       = Fnsapi::VERSION
  spec.authors       = ['Fedor Koshel']
  spec.email         = ['alexsnaumov@gmail.com']

  spec.summary       = %(Ruby implementation for Russian FNS api)
  spec.description   = %(If you got approved for wirking with Russian FNS API, this gem will help you.)
  spec.homepage      = 'https://github.com/actie/fnsapi'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'none'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/actie/fnsapi'
    spec.metadata['changelog_uri'] = 'https://github.com/actie/fnsapi/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'savon'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
