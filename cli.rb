require 'optparse'
opt = OptionParser.new

# ブロック内で引数を受け取るようにし、入力値を格納する
option = {}
opt.on('-s', '--start') do |v|
  option[:start] = v
end
opt.on('-a MANDATORY', '--arrive') { |v| option[:arrive] = v } 

# 入力値を出力
puts "all args: " + ARGV.join(", ")
opt.parse!(ARGV)
puts "only options: " + ARGV.join(", ")

# オプションの値をそれぞれ出力
puts option[:start]
