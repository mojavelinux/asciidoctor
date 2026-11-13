# frozen_string_literal: true

# Compare checkouts with: ruby -I/path/to/checkout/lib benchmark/index.rb 500
require 'asciidoctor'
require 'benchmark'

repeat = Integer ARGV.fetch(0, '500')
abort 'Repeat count must be positive' unless repeat > 0

plain = (1..50).map {|i| "== Section #{i}\n\nA keyword and another keyword.\n\n" }.join
terms = plain.gsub 'keyword', '((keyword))'
cached = terms.gsub(/== (Section \d+)/, '== ((\1))')
samples = {
  'no terms' => plain,
  'terms, no index' => terms,
  'terms with index' => %(#{terms}[index]\n== Index\n),
  'cached terms, no index' => cached,
}

puts %(Ruby #{RUBY_VERSION}; #{repeat} conversions per sample)
puts Asciidoctor.method(:convert).source_location.first
samples.each do |name, source|
  output = Asciidoctor.convert source, standalone: false
  puts %(#{name}: #{output.bytesize} bytes, #{(output.scan '<a id="_indexterm_').size} occurrence anchors)
end

Benchmark.bmbm 24 do |bm|
  samples.each do |name, source|
    bm.report(name) { repeat.times { Asciidoctor.convert source, standalone: false } }
  end
end
