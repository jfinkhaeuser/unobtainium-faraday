# coding: utf-8
#
# unobtainium-faraday
# https://github.com/jfinkhaeuser/unobtainium-faraday
#
# Copyright (c) 2016 Jens Finkhaeuser and other unobtainium-faraday contributors.
# All rights reserved.
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unobtainium-faraday/version'

# rubocop:disable Style/UnneededPercentQ, Style/ExtraSpacing
# rubocop:disable Style/SpaceAroundOperators
Gem::Specification.new do |spec|
  spec.name          = "unobtainium-faraday"
  spec.version       = Unobtainium::Faraday::VERSION
  spec.authors       = ["Jens Finkhaeuser"]
  spec.email         = ["jens@finkhaeuser.de"]
  spec.description   = %q(
    The unobtainium-faraday gem is a faraday-based driver implementation for
    unobtainium.

    Unlike built-in driver implementations, it does not provide a Selenium-like
    API, but rather one mostly identical to plain faraday.
  )
  spec.summary       = %q(
    The unobtainium-faraday gem is a faraday-based driver implementation for
    unobtainium.
  )
  spec.homepage      = "https://github.com/jfinkhaeuser/unobtainium-faraday"
  spec.license       = "MITNFA"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rubocop", "~> 0.39"
  spec.add_development_dependency "rake", "~> 11.1"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "multi_xml"
  spec.add_development_dependency "faraday_middleware"
  spec.add_development_dependency "faraday_json"

  spec.add_dependency "unobtainium", "~> 0.3", ">= 0.3.4"
end
# rubocop:enable Style/SpaceAroundOperators
# rubocop:enable Style/UnneededPercentQ, Style/ExtraSpacing
