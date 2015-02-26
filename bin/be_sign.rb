$LOAD_PATH << '.' << '../lib'

require '../lib/pdf'
require '../lib/signature_eid'
require 'optparse'

options = {}
optparse = OptionParser.new(ARGV) do |opts|

  opts.banner = "Usage: java -jar be_sign.jar options"

  opts.on("-r", "--reason MANDATORY", "Text that states the reason of signing the documents") do |r|
    options[:reason] = r
  end

  opts.on("-l", "--location MANDATORY", "Your location") do |l|
    options[:location] = l
  end

  opts.on("-s", "--signature", "An image of your wet signature") do |s|
    options[:signature_image] = File.absolute_path(s)
  end

  opts.on("-i", "--inbox MANDATORY", "A directory with the files that need to be signed") do |i|
    options[:inbox] = File.absolute_path(i)
  end

  opts.on("-o", "--outbox MANDATORY", "A directory that holds the signed files") do |o|
    options[:outbox] = File.absolute_path(o)
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

optparse.parse!
mandatory_options = [:inbox, :outbox, :reason, :location]
if (options.keys & mandatory_options).size != mandatory_options.size
  missing_options = (mandatory_options.sort - (options.keys & mandatory_options).sort).map{|a| "--#{a.to_s}"}.join(', ')
  puts "Missing option(s): #{missing_options}"

  puts optparse
  exit
end

begin
signature = SignatureEid.new

Dir[File.expand_path("#{options[:inbox]}/*.pdf")].each do |file|
  print "Signing -- #{File.basename(file)}"
  result = Pdf.sign(file, "#{options[:outbox]}/#{File.basename(file)}", signature, options[:reason], options[:location], options[:signature_image] || nil)
  puts "\t\t\t\t\t#{result ? 'OK' : 'ERROR'}"
end
rescue Exception => e
  puts e.message
end

