#! ruby -Ks
require 'vr/vruby'
require '_frm_pdf_time_changer.rb'

require 'date'
require 'time'


# regex of dates
CDATE_OLD_RE = /(\/CreationDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
MDATE_OLD_RE = /(\/ModDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
CDATE_XAP_RE = /xap:CreateDate=(["'])([^'"]+)\1/
CDATE_XMP_RE = /<(xmp:CreateDate)>(.*)<\/\1>/
MDATE_XAP_RE = /xap:ModifyDate=(["'])([^'"]+)\1/
MDATE_XMP_RE = /<(xmp:ModifyDate)>(.*)<\/\1>/

DATE_FORMAT = '%F %T'

class Hash
  def to_datetime
    DateTime.new( self[:year], self[:mon], self[:mday], self[:hour], self[:min], self[:sec], self[:zone])
  end
end


module Frm_form1
  def self_created
    @c_edits = {:year => @cyear, :mon => @cmon, :mday => @cmday, :hour => @chour, :min => @cmin, :sec => @csec}
    @m_edits = {:year => @myear, :mon => @mmon, :mday => @mmday, :hour => @mhour, :min => @mmin, :sec => @msec}
    @msg_text = ""
  end
  def get_mod(h)
    res = Hash.new
    h.each do |k,c|
      res[k] = c.text.to_i unless c.text.empty?
    end
    res
  end

  def btn_clear_cedits_clicked
    @c_edits.each do |k,c|
      c.text = ""
    end
  end

  def btn_clearl_medits_clicked
    @m_edits.each do |k, c|
      c.text = ""
    end
  end



  # ���b�Z�[�W��\��
  def disp(msg = "", cont = false)
    if cont
      @msg_text += msg
    else
      @msg_text += msg.chomp + "\r\n"
    end
    @msg.text = @msg_text
    n = @msg_text.size
    @msg.setSel(n, n)
    @msg.setCaret(n)
  end

  # ���b�Z�[�W���ڍׂɕ\������ꍇ
  def info(msg)
    if @cbVerbose.checked?
      @msg_text += msg.chomp + "\r\n"
      @msg.text = @msg_text
    end
  end

  # ���C�����s��
  def self_dropfiles(files)

    # Start
    disp "==============================================================="
    disp "�����J�n�F #{DateTime.now.strftime(DATE_FORMAT)}"

    # �C�����ڃn�b�V���̎擾
    c_mod = get_mod(@c_edits)
    m_mod = get_mod(@m_edits)
    f   = nil # �X�R�[�v�΍�
    out = nil # �X�R�[�v�΍�

    ok = 0 # �����ɐ��������t�@�C����
    ng = 0 # �����Ɏ��s�����t�@�C����

    files.each do |file|
      disp "---------------------------------------------------------------"
      disp "�Ώۃt�@�C���F#{file}"
      back = file + ".bak"
      disp "�Ώۃt�@�C����ޔ� ==> #{back} ", true
      begin
        File.rename(file, back)
        disp " OK"
      rescue
        disp " �G���[ (�������X�L�b�v���܂�)"
        ng += 1
        next
      end
      begin
        f = open(back, "rb")
        info "PDF���I�[�v��"
      rescue
        disp "�ޔ���̃t�@�C��(#{back})��ǂݍ��ݗl�ɊJ���܂���ł����D(BUG)"
        disp "�Ȃ�炩�̏d��ȃG���[���������\��������̂ŏ����𒆒f���܂����D"
        return
      end
      begin
        out = open(file, "wb")
        info "�o�͐���I�[�v��"
      rescue
        disp "�t�@�C��(#{file})���������ݗl�ɊJ���܂���ł����D"
        disp "�f�B�X�N�̋󂫂��s�����Ă���Ȃǂ��̃G���[���l�����܂��D"
        disp "�d��ȃG���[�̈׏����𒆒f���܂����D"
        return
      end
      header = f.gets
      disp "PDF �o�[�W����: #{header}"
      begin
        out.puts header
      rescue
        disp "�t�@�C�����������݂ł��܂���ł���."
        disp "�X�L�b�v���܂�."
        out.close
        f.close
        File.delete(file)
        File.rename(back, file)
        ng += 1
        next
      end
      while line = f.gets
        ### reset for debug
        tm = nil
        #####################################
        begin # �쐬����
        if line =~ CDATE_OLD_RE
          dc = DateTime.parse($2+$3)
          if tm = query("�쐬����", c_mod, dc)
            line.sub!(CDATE_OLD_RE){
              $1 + tm.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
          end
        end
        if line =~ CDATE_XAP_RE
          dc = DateTime.parse($2)
          if tm = query("�쐬����", c_mod, dc)
            line.sub!(CDATE_XAP_RE){
              tm.strftime("xap:CreateDate='%FT%T%:z'")}
          end
        end
        if line =~ CDATE_XMP_RE
          dc = DateTime.parse($2)
          if tm = query("�쐬����", c_mod, dc)
            line.sub!(CDATE_XMP_RE){
              tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
          end
        end
        rescue StandardError => e
          disp "�G���[�������܂����D"
          disp " �쐬�����̐ݒ�ɃG���[�����邩������܂���D"
          info " dc: #{dc.to_s}"
          info " $2: #{$2}"
          info " mod: #{c_mod.inspect}"
          info " tm: #{tm}"
          disp "�����𒆒f���C�t�@�C���𕜋����܂��D"
          out.close
          f.close
          File.delete(file)
          File.rename(back, file)
          #File.rename(file, file+".err")
          #disp "���ӁF�����r���������t�@�C����#{file+'.err'}�Ɉړ����C�I���W�i���t�@�C���𕜌����܂����D"
          info e.message
          return
        end

        begin # mod
        if line =~ MDATE_OLD_RE
          dm = DateTime.parse($2+$3)
          if tm = query("�X�V����", m_mod, dm)
            line.sub!(MDATE_OLD_RE){
              $1 + tm.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
          end
        end
        if line =~ MDATE_XAP_RE
          dm = DateTime.parse($2)
          if tm = query("�X�V����", m_mod, dm)
            line.sub!(MDATE_XAP_RE){
              tm.strftime("xap:ModifyDate='%FT%T%:z'")}
          end
        end
        if line =~ MDATE_XMP_RE
          dm = DateTime.parse($2)
          if tm = query("�X�V����", m_mod, dm)
            line.sub!(MDATE_XMP_RE){
              tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
          end
        end
        rescue
          disp "�G���[�������܂����D"
          disp " �X�V�����̐ݒ�ɃG���[�����邩������܂���D"
          info " dm: #{dm}"
          info " $2: #{$2}"
          info " mod: #{m_mod.inspect}"
          info " tm: #{tm}"
          disp "�����𒆒f���C���t�@�C���𕜋����܂��D"
          out.close
          f.close
          File.delete(file)
          File.rename(back, file)
          return
        end

        out.puts line
        ####################################
      end

      # �R�s�[����
      out.close
      f.close

      ok += 1

    end

    disp
    disp " #{files.size}�t�@�C��������"
    disp " #{ok}�t�@�C���̏C���ɐ����D" if ok > 0
    disp " #{ng}�t�@�C���͏C���Ɏ��s " if ng > 0
    disp " �����I�� at #{DateTime.now.strftime(DATE_FORMAT)}"
    disp
    disp "!!����!! �t�@�C���V�X�e���̎����͌��ݎ����̂܂܂ł��̂ŕʓr�C�����Ă��������D"
    disp

  end

  def query(msg, mod, tm)
    return false if mod.empty? # ���ԏC����������Ή������Ȃ��D

    # �ĉ��߂��ăR�s�[ �iTime�������Ƃ��Ă���ꍇ�����邽�߁j
    h = DateTime._parse(tm.to_s)
    info " old h: #{h.inspect}"
    h.update(mod)
    info " new h: #{h.inspect}"
    dt =  h.to_datetime

    return false if dt == tm  # ���ԏC����������Ή������Ȃ��D

    disp "#{msg}���C���F #{tm.strftime(DATE_FORMAT)} ==> #{dt.strftime(DATE_FORMAT)}"
    return dt
  end

  def btnClearMsg_clicked
    @msg_text = ""
    @msg.text = ""
  end




# �L�����Z���D �s���艻�̌����ɂȂ肻���Ȃ̂�
#  def change_file_time(ct, mt, at = nil)
#    at = mt if at.nil?
#
#  end
#
#  def make_filetime(tm)
#
#  end

end

VRLocalScreen.start Frm_form1
