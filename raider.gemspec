# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'raider'
  spec.version = '0.1.10'
  spec.authors = ['Lars Gollnow']
  spec.email = ['lg@megorei.com']

  spec.summary = 'cool tool'
  spec.description = 'does all'
  spec.homepage = 'https://raider.megorei.net'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://raider.megorei.net'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://raider.megorei.net'
  spec.metadata['changelog_uri'] = 'https://raider.megorei.net'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .gitlab-ci.yml appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'base64'
  spec.add_dependency 'debug'
  spec.add_dependency 'faraday'
  spec.add_dependency 'json'
  spec.add_dependency 'json-schema-generator'
  spec.add_dependency 'langchainrb'
  spec.add_dependency 'pdf-reader'
  spec.add_dependency 'recursive-open-struct'
  spec.add_dependency 'ruby-openai'
  spec.add_dependency 'ruby-vips'
  spec.add_dependency 'simple_json_schema_builder'
  spec.add_dependency 'slop'
  spec.add_dependency 'zeitwerk'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
