#! /bin/ruby
# coding: cp932

require "time"
require "date"

VERSION_LIMIT=5


def usage
  puts <<NNN
PDF�t�@�C���̓�����Θb�I�ɕύX���܂��D
�g����:
   #{$0} ��PDF �C������PDF

�����w��͈�ʓI�Ȃ��̂�OK�ł��D
���Ƃ���
 2013/12/24 11:23:45
 2012-01-24T08:04:25
 1999-8-9
�w�肵�Ȃ��������̂͂��Ƃ��Ƃ̒l���g�p����܂��D

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
  $stderr.puts "�o�͐�t�@�C��(#(to_file})�����݂��܂�."
  $stderr.puts "�㏑�����Ă�낵���ł���? (y/[n])"
  ans = gets
  exit unless ans =~ /^Y/i
end

class Hash
  def to_datetime
    DateTime.new( self[:year], self[:mon], self[:mday], self[:hour], self[:min], self[:sec], self[:zone])
  end
end


def query(msg, tm)
    puts "#{msg}�F #{tm.strftime(DATE_FORMAT)}  \n �C�����e����͂��Ă�������. (�C���Ȃ��̏ꍇ�͂��̂܂܃G���^�[)"
    ans = gets
    return false if ans.nil? || ans.strip.empty?
    h = DateTime._parse(tm.to_s)
    mod = DateTime._parse(ans)
    h.update(mod)
    dt =  h.to_datetime
    puts "���F #{tm.strftime(DATE_FORMAT)}"
    puts "�V�F #{dt.strftime(DATE_FORMAT)}"
    puts
    return dt
    rescue
      puts "���͂̉��߂Ɏ��s���܂����D�ē��͂��Ă�������"
      puts "���͂̉��ߌ��ʁF #{mod}"
      retry
end

out = open(to_file, "wb")
f = open(orig_file, "rb")
header = f.gets
out.puts header

puts "���t�@�C��: #{orig_file}"
puts "��t�@�C��: #{to_file}"
puts "�o�[�W����: #{header[5,3]}"

while line = f.gets
  if line =~ CDATE_OLD_RE
    dc = DateTime.parse($2+$3)
    if update = query("�쐬����",dc)
      line.sub!(CDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
    end
  end
  if line =~ MDATE_OLD_RE
    dc = DateTime.parse($2+$3)
    if update = query("�X�V����", dc)
      line.sub!(MDATE_OLD_RE){
        $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
    end
  end

  if line =~ CDATE_XAP_RE
    dc = DateTime.parse($2)
    if tm = query("�쐬����", dc)
      line.sub!(CDATE_XAP_RE){
        tm.strftime("xap:CreateDate='%FT%T%:z'")}
    end
  end
  if line =~ MDATE_XAP_RE
    dm = DateTime.parse($2)
    if tm = query("�X�V����", dm)
      line.sub!(MDATE_XAP_RE){
        tm.strftime("xap:ModifyDate='%FT%T%:z'")}
    end
  end
  if line =~ CDATE_XMP_RE
    dc = DateTime.parse($2)
    if tm = query("�쐬����", dc)
      line.sub!(CDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  if line =~ MDATE_XMP_RE
    dm = DateTime.parse($2)
    if tm = query("�X�V����", dm)
      line.sub!(MDATE_XMP_RE){
        tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
    end
  end
  out.puts line
end
f.close
out.close
