Gem::Specification.new do |s|
  s.name    = "undress"
  s.version = "0.2.4"
  s.date    = "2009-07-29"

  s.description = "Simply translate HTML to Textile, Markdown, or whatever other markup format you need"
  s.summary     = "Convert HTML into other markup languages"
  s.homepage    = "http://undress.rubyforge.org"

  s.authors = "Nicolás Sanguinetti"
  s.email   = "contacto@nicolassanguinetti.info"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "undress"
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
undress.gemspec
lib/undress.rb
lib/hpricot_ext.rb
lib/undress/grammar.rb
lib/undress/textile.rb
lib/undress/greencloth.rb
lib/core_ext/object.rb
test/test_helper.rb
test/test_grammar.rb
test/test_textile.rb
test/test_greencloth.rb
test/test_hpricot_ext.rb
]
end
