Gem::Specification.new do |s|
  s.name    = "greencloth"
  s.version = "0.1"
  s.date    = "2009-09-11"

  s.description = "GreenCloth is derived from RedCloth, the defacto text to html converter for ruby."
  s.summary     = "The purpose of GreenCloth is to add a bunch of new features to RedCloth that make it more suited for wiki markup."
  s.homepage    = "https://labs.riseup.net/"

  s.authors = "Riseup Labs"
  s.email   = "labs@riseup.net"

  s.require_paths     = ["lib"]
  s.has_rdoc          = false
  s.rubygems_version  = "1.3.1"

  s.add_dependency("RedCloth", ">= 4.2.2")

  s.files = %w[LICENSE README.textile Rakefile SYNTAX_REFERENCE greencloth.gemspec]
  s.files << Dir['lib/*.rb'] + Dir['test/*.rb']
end
