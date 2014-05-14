#! /bin/ruby
#

require "time"

VERSION_LIMIT=5


def usage
  puts <<NNN
Change PDF's date interactively.
usage: #{$0} OriginalPDF NewPDF


NNN
exit
end


# regex of dates
CDATE_OLD_RE = /(\/CreationDate ?\(D:)(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\+(\d\d)'(\d\d)'\)/
MDATE_OLD_RE = /(\/ModDate ?\(D:)(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\+(\d\d)'(\d\d)'\)/
CDATE_XAP_RE = /xap:CreateDate=(["'])([^"]+)\1/
CDATE_XMP_RE = /<(xmp:CreateDate)>(.*)<\/\1>/
MDATE_XAP_RE = /xap:ModifyDate=(["'])([^"]+)\1/
MDATE_XMP_RE = /<(xmp:ModifyDate)>(.*)<\/\1>/



usage unless ARGV.size == 2
orig_file = ARGV.shift
to_file = ARGV.shift

usage unless File.file?(orig_file)
usage unless orig_file =~ /\.pdf$/i
usage unless to_file =~ /\.pdf$/i
if File.exist?(to_file)
  $stderr.puts "Output file (#(to_file}) already exist."
  $stderr.puts "Do you wish to overwrite it? (y/[n])"
  ans = gets
  exit unless ans =~ /^Y/i
end


def query(msg, tm)
    puts "#{msg} is #{tm}. \n Enter new date. (Just enter to unchange)"
    update = Time.parse(gets) rescue update = false
    return update
end

out = open(to_file, "wb")
f = open(orig_file, "rb")
header = f.gets
out.puts header

puts "Source file: #{orig_file}"
puts "Destination: #{to_file}"
puts "PDF version: #{header[5,3]}"

while line = f.gets
  if line =~ CDATE_OLD_RE
    dc = Time.local(*([$2,$3,$4,$5,$6,$7].map{|x| x.to_i}))
    if update = query("Creation Date (old)",dc)
      line.sub!(CDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:").gsub(":","'")}
    end
  end
  if line =~ MDATE_OLD_RE
    dc = Time.local(*([$2,$3,$4,$5,$6,$7].map{|x| x.to_i}))
    if update = query("Modification Date (old)", dc)
      line.sub!(MDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:").gsub(":","'")}
    end
  end

  if line =~ CDATE_XAP_RE
    dc = Time.parse($2)
    if tm = query("CreateDate", dc)
      line.sub!(CDATE_XAP_RE){
        tm.strftime("xap:CreateDate='%FT%T%:z'")}
    end
  end
  if line =~ MDATE_XAP_RE
    dm = Time.parse($2)
    if tm = query("ModifyDate", dm)
      line.sub!(MDATE_XAP_RE){
        tm.strftime("xap:ModifyDate='%FT%T%:z'")}
    end
  end
  if line =~ CDATE_XMP_RE
    dc = Time.parse($2)
    if tm = query("Create Date", dc)
      line.sub!(CDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  if line =~ MDATE_XMP_RE
    dm = Time.parse($2)
    if tm = query("Modify Date", dm)
      line.sub!(MDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  out.puts line
end
f.close
out.close

exit

############################################################################
# Rests are memos


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
