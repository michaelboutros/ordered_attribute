$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name              = 'ordered_attribute'
  s.version           = '0.0.1'
  s.platform          = Gem::Platform::RUBY
  s.author            = 'Michael Boutros'
  s.email             = ['me@michaelboutros.com']
  s.homepage          = 'http://www.michaelboutros.com/'
  s.summary           = 'A summary.'
  s.description       = 'A description.'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end