# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "populr"
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Gotow"]
  s.date = "2013-06-06"
  s.description = "Gem for interacting with the Populr.me API that allows you to create and publish one-page websites, subscribe to web hooks and receive events when those pages are interacted with. Visit http://www.populr.me/ for more information. "
  s.email = "ben@populr.me"
  s.extra_rdoc_files = [
    "LICENSE.md",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.md",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/asset.rb",
    "lib/background_image_asset.rb",
    "lib/document_asset.rb",
    "lib/domain.rb",
    "lib/embed_asset.rb",
    "lib/image_asset.rb",
    "lib/pop.rb",
    "lib/populr.rb",
    "lib/restful_model.rb",
    "lib/restful_model_collection.rb",
    "lib/template.rb",
    "lib/tracer.rb",
    "populr.gemspec",
    "spec/pop_spec.rb",
    "spec/populr_spec.rb",
    "spec/restful_model_collection_spec.rb",
    "spec/restful_model_spec.rb",
    "spec/spec_helper.rb",
    "spec/tracer_spec.rb"
  ]
  s.homepage = "http://github.com/populr/populr_api_ruby"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Gem for interacting with the Populr.me API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3.5"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
    else
      s.add_dependency(%q<rest-client>, [">= 1.6"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.3.5"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 1.6"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.3.5"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
  end
end

