#! /bin/ruby
#

require "time"

VERSION_LIMIT=5
ICRE = 0
IMOD = 1

def check_old_pdf(f)
  flags = [false, false]
  while line = f.gets
    if line =~ /\/CreationDate ?\(D:(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\+(\d\d)'(\d\d)'\)/
      dc = Time.local(*([$1,$2,$3,$4,$5,$6].map{|x| x.to_i}))
      flags[ICRE] = true
      break if flags.all?
    end
    if line =~ /\/ModDate ?\(D:(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\+(\d\d)'(\d\d)'\)/
      dm = Time.local(*([$1,$2,$3,$4,$5,$6].map{|x| x.to_i}))
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
      dc = Time.parse($2)
      flags[ICRE] = true
      break if flags.all?
    when /xap:ModifyDate=(["'])([^"]+)\1/
      dm = Time.parse($2)
      flags[IMOD] = true
      break if flags.all?
    when /<(xmp:CreateDate)>(.*)<\/\1>/
      dc = Time.parse($2)
      flags[ICRE] = true
      break if flags.all?
    when /<(xmp:ModifyDate)>(.*)<\/\1>/
      dm = Time.parse($2)
      flags[IMOD] = true
      break if flags.all?
    end
  end
  return dc, dm
end

ARGV.each do |file|
  puts file + ":"
  f = open(file,"rb")
  header = f.gets
  unless header =~ /^%PDF-1\.(\d)/
    f.close
    puts " It does not a PDF file. skipped."
    next
  end
  dc = nil
  dm = nil
  if $1.to_i < VERSION_LIMIT
    dc, dm = check_old_pdf(f)
  else
    dc, dm = check_new_pdf(f)
  end
  puts "  Create: #{dc}"
  puts "  Modify: #{dm}"
  f.close
  puts
end
