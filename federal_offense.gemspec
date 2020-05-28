# frozen_string_literal: true

require_relative "lib/federal_offense/version"

Gem::Specification.new do |spec|
  spec.name = "federal_offense"
  spec.version = FederalOffense::VERSION
  spec.authors = ["Flip Sasser"]
  spec.email = ["hello@flipsasser.com"]

  spec.summary = "Everyone knows it's a federal offense to mess with the mail!"
  spec.description = "Federal Offense intercepts outbound emails in Rails and allows you to preview them in a user-configurable mounted location"
  spec.homepage = "https://github.com/flipsasser/federal_offense"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] =

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 6.0", ">= 6.0.3.1"

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop", "~> 0.8"
  spec.add_development_dependency "rubocop-ordered_methods", "~> 0.6"
  spec.add_development_dependency "rubocop-performance", "~> 1.5.2"
  spec.add_development_dependency "rubocop-rails", "~> 2.5.2"
  spec.add_development_dependency "rubocop-rspec", "~> 1.39"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "standard", "~> 0.4"
  spec.add_development_dependency "timecop"
end
