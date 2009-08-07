require 'rake'
require 'mkmf'

SPEC = Gem::Specification.new do |spec|
  # Descriptive and source information for this gem.
  spec.name = "nilsimsa"
  spec.version = "1.0.1"
  spec.summary = "Computes Nilsimsa values.  Nilsimsa is a distance based hash"
  spec.author = "Jonathan Wilkins"
  spec.email = "jwilkins[at]nospam[dot]bitland[dot]net"
  spec.has_rdoc = true
  spec.extra_rdoc_files = ["README"]
  spec.require_path = "."
  spec.autorequire = "nilsimsa.rb"

  spec.files = %w(README nilsimsa.gemspec nilsimsa.rb bin/nilsimsa
                  examples/simple.rb ext/extconf.rb ext/nilsimsa.c)
  spec.executables = ['nilsimsa']

  # optional native component
  if cc_command
    spec.extensions << 'ext/extconf.rb'
  end

  puts "Building gem w/ "
  spec.files.each do |f|
    puts "- #{f}"
  end

end