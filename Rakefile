# coding: utf-8

if RUBY_PLATFORM =~ /mingw/
  disp_coding = "-s"
else
  disp_coding = "-w"
end
require 'nkf'

#exes = FileList['*.rb'].pathmap("%X.exe")
exes = FileList[%w(pdf_time_changer.exe get_pdf_date.exe)]

task :default => exes #["qplr-sf.exe"]

rule 'exe' => '.exy' do |t|
  sh "exerb #{t.source}"
end

rule '.exy' => ['.rb', '.ver'] do |t|
  rb,ver = *t.sources
  #puts rb
  #puts ver
  sh "ruby -I ../lib -r exerb/mkexy #{rb}"
  exy = t.name
  tmp = exy + ".tmp"
  File.rename(exy, tmp)
  versions = open(ver,"rb").read
  open(exy, "wb") do |out|
    open(tmp,"rb")do |f|
      while line = f.gets
        if line =~ /core:/
          if versions =~ /CORE:GUI/
            line.sub!(/cui/,'gui')
          end
        end
        if line =~ /^file:/
          out.print versions
          out.puts
        end
        out.puts line
      end
    end
  end
  File.unlink(tmp)
end

task :ver => exes.pathmap("%X.ver")

rule '.ver' do |t|
  open(t.name,"w")do |out|
    out.puts <<-NNN
# -*- mode: yaml; coding: utf-8 -*-
# vim: set fenc=utf-8 :
resource:
  version:
    file_version_number   : 0.1.0.0
    product_version_number: 0.1.0.0
    comments              : 
    company_name          : Nikken Sekkei Civil Eng. Ltd.
    legal_copyright       : Atsushi Tanabe
    legal_trademarks      : 
    file_version          : Version 0.1
    product_version       : Version 0.1
    product_name          : 
    file_description      : 
    internal_name         : #{t.name.pathmap '%X'}
    original_filename     : #{t.name.pathmap '%X.rb'}
    private_build         : 
    special_build         : 
# GUIにする場合は次の行のCUIをGUIに変更してください．
# CORE:CUI
    NNN
  end
  raise NKF.nkf(disp_coding, "#{t.name}の修正が必要です．")
end


