#! /bin/ruby
# coding: cp932

require "time"
require "date"

VERSION_LIMIT=5


def usage
  puts <<NNN
PDFファイルの日時を対話的に変更します．
使い方:
   #{$0} 元PDF 修正したPDF

日時指定は一般的なものでOKです．
たとえば
 2013/12/24 11:23:45
 2012-01-24T08:04:25
 1999-8-9
指定しなかったものはもともとの値が使用されます．

NNN

exit
end


# regex of dates
CDATE_OLD_RE = /(\/CreationDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
MDATE_OLD_RE = /(\/ModDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
CDATE_XAP_RE = /xap:CreateDate=(["'])([^'"]+)\1/
CDATE_XMP_RE = /<(xmp:CreateDate)>(.*)<\/\1>/
MDATE_XAP_RE = /xap:ModifyDate=(["'])([^'"]+)\1/
MDATE_XMP_RE = /<(xmp:ModifyDate)>(.*)<\/\1>/

DATE_FORMAT = '%F %T %:z'


usage unless ARGV.size == 2
orig_file = ARGV.shift
to_file = ARGV.shift

usage unless File.file?(orig_file)
usage unless orig_file =~ /\.pdf$/i
usage unless to_file =~ /\.pdf$/i
if File.exist?(to_file)
  $stderr.puts "出力先ファイル(#(to_file})が存在します."
  $stderr.puts "上書きしてよろしいですか? (y/[n])"
  ans = gets
  exit unless ans =~ /^Y/i
end

class Hash
  def to_datetime
    DateTime.new( self[:year], self[:mon], self[:mday], self[:hour], self[:min], self[:sec], self[:zone])
  end
end


def query(msg, tm)
    puts "#{msg}： #{tm.strftime(DATE_FORMAT)}  \n 修正内容を入力してください. (修正なしの場合はそのままエンター)"
    ans = gets
    return false if ans.nil? || ans.strip.empty?
    h = DateTime._parse(tm.to_s)
    mod = DateTime._parse(ans)
    h.update(mod)
    dt =  h.to_datetime
    puts "旧： #{tm.strftime(DATE_FORMAT)}"
    puts "新： #{dt.strftime(DATE_FORMAT)}"
    puts
    return dt
    rescue
      puts "入力の解釈に失敗しました．再入力してください"
      puts "入力の解釈結果： #{mod}"
      retry
end

out = open(to_file, "wb")
f = open(orig_file, "rb")
header = f.gets
out.puts header

puts "元ファイル: #{orig_file}"
puts "先ファイル: #{to_file}"
puts "バージョン: #{header[5,3]}"

while line = f.gets
  if line =~ CDATE_OLD_RE
    dc = DateTime.parse($2+$3)
    if update = query("作成日時",dc)
      line.sub!(CDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
    end
  end
  if line =~ MDATE_OLD_RE
    dc = DateTime.parse($2+$3)
    if update = query("更新日時", dc)
      line.sub!(MDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
    end
  end

  if line =~ CDATE_XAP_RE
    dc = DateTime.parse($2)
    if tm = query("作成日時", dc)
      line.sub!(CDATE_XAP_RE){
        tm.strftime("xap:CreateDate='%FT%T%:z'")}
    end
  end
  if line =~ MDATE_XAP_RE
    dm = DateTime.parse($2)
    if tm = query("更新日時", dm)
      line.sub!(MDATE_XAP_RE){
        tm.strftime("xap:ModifyDate='%FT%T%:z'")}
    end
  end
  if line =~ CDATE_XMP_RE
    dc = DateTime.parse($2)
    if tm = query("作成日時", dc)
      line.sub!(CDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  if line =~ MDATE_XMP_RE
    dm = DateTime.parse($2)
    if tm = query("更新日時", dm)
      line.sub!(MDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  out.puts line
end
f.close
out.close
