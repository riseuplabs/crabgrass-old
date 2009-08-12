Gem::Specification.new do |s|
  s.name    = "uglify_html"
  s.version = "0.11"
  s.date    = "2009-08-10"

  s.description = "Make ugly a Html document"
  s.summary     = "Make ugly a Html document to use for example on wysiwyg editors"
  s.homepage    = ""

  s.authors = "Alvaro Gil"
  s.email   = "zevarito@gmail.com"

  s.require_paths     = ["lib"]
  s.has_rdoc          = true
  s.rubygems_version  = "1.3.1"

  s.add_dependency "hpricot"

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency "sr-mg"
    s.add_development_dependency "contest"
    s.add_development_dependency "redgreen"
  end

  s.files = %w[
LICENSE
CHANGELOG
README.rdoc
Rakefile
uglify_html.gemspec
lib/hpricot_ext.rb
lib/uglify_html.rb
test/test_helper.rb
test/test_hpricot_ext.rb
test/test_uglify.rb
]
end
