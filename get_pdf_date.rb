#! /bin/ruby
# coding: cp932

require "date"
require "time"

DATE_FORMAT = '%F %T %:z'

VERSION_LIMIT=5
ICRE = 0
IMOD = 1

def check_old_pdf(f)
  flags = [false, false]
  while line = f.gets
#    if line =~ /\/CreationDate ?\(D:(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)([+-]\d\d)'(\d\d)'\)/
#      dc = DateTime.new(*([$1,$2,$3,$4,$5,$6].map{|x| x.to_i}.append($7+$8)))
    if line =~ /\/CreationDate ?\(D:(\d{14}[+-]\d\d)'(\d\d)'\)/
      dc = DateTime.parse($1+$2)
      flags[ICRE] = true
      break if flags.all?
    end
#    if line =~ /\/ModDate ?\(D:(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)([+-]\d\d)'(\d\d)'\)/
#      dm = DateTime.new(*([$1,$2,$3,$4,$5,$6].map{|x| x.to_i}.append($7+$8)))
    if line =~ /\/ModDate ?\(D:(\d{14}[+-]\d\d)'(\d\d)'\)/
      dm = DateTime.parse($1+$2)
      flags[IMOD] = true
      break if flags.all?
    end
  end
  return dc, dm
end

def check_new_pdf(f)
  flags = [false, false]
  while line = f.gets
    case line
    when /xap:CreateDate=(["'])([^"]+)\1/
      dc = DateTime.parse($2)
      flags[ICRE] = true
      break if flags.all?
    when /xap:ModifyDate=(["'])([^"]+)\1/
      dm = DateTime.parse($2)
      flags[IMOD] = true
      break if flags.all?
    when /<(xmp:CreateDate)>(.*)<\/\1>/
      dc = DateTime.parse($2)
      flags[ICRE] = true
      break if flags.all?
    when /<(xmp:ModifyDate)>(.*)<\/\1>/
      dm = DateTime.parse($2)
      flags[IMOD] = true
      break if flags.all?
    end
  end
  return dc, dm
end

ARGV.each do |file|
  ct = DateTime.parse(File.ctime(file).to_s)
  mt = DateTime.parse(File.mtime(file).to_s)
  puts file + ":"
  f = open(file,"rb")
  header = f.gets
  unless header =~ /^%PDF-1\.(\d)/
    f.close
    puts " PDFファイルではないのでスキップします．"
    next
  end
  dc = nil
  dm = nil
  if $1.to_i < VERSION_LIMIT
    dc, dm = check_old_pdf(f)
  else
    dc, dm = check_new_pdf(f)
  end
  puts "  作成日時: #{dc.strftime(DATE_FORMAT)} (file:#{ct.strftime(DATE_FORMAT)})"
  puts "  修正日時: #{dm.strftime(DATE_FORMAT)} (file:#{mt.strftime(DATE_FORMAT)})"
  f.close
  puts
end

if ENV.key?("OCRA_EXECUTABLE") || $Exerb
  puts "Enterキーを押すと終了します．"
  $stdin.gets 
end

