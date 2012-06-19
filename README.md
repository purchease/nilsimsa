nilsimsa
--------
[![Build Status](https://secure.travis-ci.org/jwilkins/nilsimsa.png)](http://travis-ci.org/jwilkins/nilsimsa)

Nilsimsa is a distance based hash, which is the opposite of more familiar
hashes like MD5.  Instead of small changes making a large difference in
the resulting hash (to avoid collisions), distance based hashes cause
similar values to have similar output.  This is good for detecting near
similar documents without having to store the original text.

Standard usage is as follows:

  require 'nilsimsa'

  n1 = Nilsimsa::new
  text1 = "The quick brown fox"
  n1.update(text1)
  puts "Text '#{text1}': #{n1.hexdigest}"


