#! ruby -Ks
require 'vr/vruby'
require '_frm_pdf_time_changer.rb'

require 'date'
require 'time'
require 'ext/win_ctime'  # ファイル作成日時へのアクセス用


# Const for MSG box
require 'vr/contrib/msgboxconst'
require 'vr/vrdialog' # for msg box
module WConst
  IDABORT    = 3 # 中止
  IDCANCEL   = 2 # キャンセル
  IDCONTINUE =11 # 続行 (Win2000用)
  IDIGNORE   = 5 # 無視
  IDNO       = 7 # いいえ
  IDOK       = 1 # OK
  IDRETRY    = 4 # 再試行
  IDTRYAGAIN =10 # 再実行 (Win2000用)
  IDYES      = 6 # はい
end

include WConst

# regex of dates
CDATE_OLD_RE = /(\/CreationDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
  MDATE_OLD_RE = /(\/ModDate ?\(D:)(\d{14}[+-]\d\d)'(\d\d)'\)/
  CDATE_XAP_RE = /xap:CreateDate=(["'])([^'"]+)\1/
  CDATE_XMP_RE = /<(xmp:CreateDate)>(.*)<\/\1>/
  MDATE_XAP_RE = /xap:ModifyDate=(["'])([^'"]+)\1/
  MDATE_XMP_RE = /<(xmp:ModifyDate)>(.*)<\/\1>/

  #DATE_FORMAT = '%F %T'
  DATE_FORMAT = '%Y-%m-%d %H-%M-%S'

TIME_KEYS = [:year, :mon, :mday, :hour, :min, :sec]

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
    @logfilename = File.basename($0,".rb")+".log"
    @log = open(@logfilename, "a")
    #@edit1.add_parentcall("char")
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



  # メッセージを表示
  def disp(msg = "", cont = false)
    if cont
      @msg_text += msg
      @log.print msg
    else
      @msg_text += msg.chomp + "\r\n"
      @log.puts msg
    end
    @msg.text = @msg_text
    n = @msg_text.size
    @msg.setSel(n, n)
    @msg.setCaret(n)
    @msg.scrolltocaret
  end

  # メッセージを詳細に表示する場合
  # ログには出力する
  def info(msg)
    if @cbVerbose.checked?
      @msg_text += msg.chomp + "\r\n"
      @msg.text = @msg_text
      @log.puts msg
    end
  end


  # メイン実行部
  def self_dropfiles(files)

    # Start
    disp "==============================================================="
    disp "処理開始： #{DateTime.now.strftime(DATE_FORMAT)}"

    # 修正項目ハッシュの取得
    c_mod = get_mod(@c_edits)
    m_mod = get_mod(@m_edits)
    f   = nil # スコープ対策
    out = nil # スコープ対策

    ok = 0 # 処理に成功したファイル数
    other = 0 # PDF以外のファイル数
    ng = 0 # 処理に失敗したファイル数

    files.each do |file|
      disp "---------------------------------------------------------------"
      disp "対象ファイル：#{file}"
      unless file =~ /\.pdf$/i
        disp "PDFファイルでないので処理しません．"
        other += 1
        next
      end
      back = file + ".bak"
      if File.exist?(back)
        if File.file?(back)
          # 通常ファイルなので削除可能なはず
          case messageBox("退避先にファイルが存在します上書きしてよろしいですか？","上書きの確認", MB_YESNOCANCEL | MB_ICONQUESTION)
          when IDNO
            disp "上書き防止のためにこのファイルの処理をスキップします．"
            ng += 1
            next
          when IDCANCEL
            disp "処理を中断しました．"
            return
          end
        else
          disp "退避先#{back}が特殊で削除できないため処理をスキップします．"
          ng += 1
          next
        end
      end
      disp "対象ファイルを退避 ==> #{back} ", true
      begin
        File.rename(file, back)
        disp " OK"
      rescue StandardError => e
        info e.message
        disp " エラー"
        disp " ファイルが使用中などの為処理できなかったのでスキップします．"
        ng += 1
        next
      end
      begin
        f = open(back, "rb")
        info "PDFをオープン"
      rescue
        disp "退避後のファイル(#{back})を読み込み様に開けませんでした．(BUG)"
        disp "なんらかの重大なエラーが生じた可能性があるので処理を中断しました．"
        return
      end
      header = f.gets
      unless header =~ /^%PDF-(1\.\d)\r?\n?/
        disp "PDFヘッダが確認できませんでした．"
        disp "PDFファイルではない様なのでスキップします．"
        other += 1
        f.close
        next
      end
      disp "PDF バージョン: #{$1}"
      begin
        out = open(file, "wb")
        info "出力先をオープン"
      rescue StandardError => e
        info e.message
        disp "ファイル(#{file})を書き込み様に開けませんでした．"
        disp "ディスクの空きが不足しているなどがのエラーが考えられます．"
        disp "重大なエラーの為処理を中断しました．"
        return
      end
      begin
        out.puts header
      rescue StandardError => e
        info e.message
        disp "ファイルに書き込みができませんでした."
        disp "スキップします."
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
        begin # 作成日時
          if line =~ CDATE_OLD_RE
            dc = DateTime.parse($2+$3)
            if tm = query("作成日時", c_mod, dc)
              line.sub!(CDATE_OLD_RE){
                $1 + tm.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
            end
          end
          if line =~ CDATE_XAP_RE
            dc = DateTime.parse($2)
            if tm = query("作成日時", c_mod, dc)
              line.sub!(CDATE_XAP_RE){
                tm.strftime("xap:CreateDate='%FT%T%:z'")}
            end
          end
          if line =~ CDATE_XMP_RE
            dc = DateTime.parse($2)
            if tm = query("作成日時", c_mod, dc)
              line.sub!(CDATE_XMP_RE){
                tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
            end
          end
        rescue StandardError => e
          info e.message
          disp "エラーが生じました．"
          disp " 作成日時の設定にエラーがあるかもしれません．"
          info " dc: #{dc.to_s}"
          info " $2: #{$2}"
          info " mod: #{c_mod.inspect}"
          info " tm: #{tm}"
          disp "処理を中断し，ファイルを復旧します．"
          out.close
          f.close
          File.delete(file)
          File.rename(back, file)
          #File.rename(file, file+".err")
          #disp "注意：処理途中だったファイルを#{file+'.err'}に移動し，オリジナルファイルを復元しました．"
          return
        end

        begin # mod
          if line =~ MDATE_OLD_RE
            dm = DateTime.parse($2+$3)
            if tm = query("更新日時", m_mod, dm)
              line.sub!(MDATE_OLD_RE){
                $1 + tm.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
            end
          end
          if line =~ MDATE_XAP_RE
            dm = DateTime.parse($2)
            if tm = query("更新日時", m_mod, dm)
              line.sub!(MDATE_XAP_RE){
                tm.strftime("xap:ModifyDate='%FT%T%:z'")}
            end
          end
          if line =~ MDATE_XMP_RE
            dm = DateTime.parse($2)
            if tm = query("更新日時", m_mod, dm)
              line.sub!(MDATE_XMP_RE){
                tm.strftime("<#{$1}>%FT%T%:z</#{$1}>")}
            end
          end
        rescue StandardError => e
          info e.message
          disp "エラーが生じました．"
          disp " 更新日時の設定にエラーがあるかもしれません．"
          info " dm: #{dm}"
          info " $2: #{$2}"
          info " mod: #{m_mod.inspect}"
          info " tm: #{tm}"
          disp "処理を中断し，元ファイルを復旧します．"
          out.close
          f.close
          File.delete(file)
          File.rename(back, file)
          return
        end

        out.puts line
        ####################################
      end

      # コピー完了
      out.close
      f.close

      if @cbChangeFileTime.checked?
        # 最終更新
        begin
          mt = File.mtime(back)
          arr = TIME_KEYS.map{|k| m_mod[k] || mt.send(k)}
          tm = Time.local( * arr )
          info "tm: #{tm} ==> #{tm.strftime(DATE_FORMAT)}"
          disp "ファイル最終更新日時を修正： #{mt.strftime(DATE_FORMAT)} ==> #{tm.strftime(DATE_FORMAT)}"
          File.utime(tm, tm, file)
        rescue StandardError => e
          info e.message
          disp "ファイル最終更新日時の修正でエラーが生じました．"
          disp " 更新日時の設定にエラーがあるかもしれません．"
          info " mt: #{mt.to_s}"
          info " arr: #{arr.inspect}"
          info " mod: #{m_mod.inspect}"
          info " tm: #{tm.to_s}"
          disp "処理を中断し，元ファイルを復旧します．"
          File.delete(file)
          File.rename(back, file)
          return nil
        end

        # 作成日時
        begin
          ct = File.creation_time(back)
          arr = TIME_KEYS.map{|k| c_mod[k] || ct.send(k)}
          tm = Time.local( * arr )
          disp "ファイル作成日時を修正:  #{ct.strftime(DATE_FORMAT)} ==> #{tm.strftime(DATE_FORMAT)}"
          File.creation_time(file, tm)
        rescue StandardError => e
          info e.message
          disp "エラーが生じました．"
          disp " 作成日時の設定にエラーがあるかもしれません．"
          info " ct: #{ct.to_s}"
          info " mod: #{c_mod.inspect}"
          info " arr: #{arr.inspect}"
          info " tm: #{tm}"
          disp "処理を中断し，ファイルを復旧します．"
          File.delete(file)
          File.rename(back, file)
          return nil
        end
      end
      ok += 1

    end

    disp
    disp " #{files.size}ファイルを処理"
    disp " #{ok}ファイルの修正に成功．" if ok > 0
    disp " #{ng}ファイルは修正に失敗 " if ng > 0
    disp " 処理対象外 #{other} ファイル" if other > 0
    disp " 処理終了 at #{DateTime.now.strftime(DATE_FORMAT)}"
    disp "!!注意!! ファイルシステムの時刻は現在時刻のままですので別途修正してください．" unless @cbChangeFileTime.checked?

  end

  def query(msg, mod, tm)
    return false if mod.empty? # 時間修正が無ければ何もしない．

    # 再解釈してコピー （Timeが引数としてくる場合があるため）
    h = DateTime._parse(tm.to_s)
    info " old h: #{h.inspect}"
    h.update(mod)
    info " new h: #{h.inspect}"
    dt =  h.to_datetime

    return false if dt == tm  # 時間修正が無ければ何もしない．

    disp "#{msg}を修正： #{tm.strftime(DATE_FORMAT)} ==> #{dt.strftime(DATE_FORMAT)}"
    return dt
  end

  def btnClearMsg_clicked
    @msg_text = ""
    @msg.text = ""
  end

  def self_resize(w,h)
    if @msg
      @msg.move(@msg.x, @msg.y, w, h - @msg.y)
    end
  end

end



#  def edit1_char(keycode, keydata)
#    disp "keycode: #{keycode}"
#    disp "keydata: #{keydata}"
#  end


#module Extn_edit1
#  def self_char(keycode,keydata)
#    messageBox(keycode.inspect, "Keycode",0)
#    messageBox(keydata.inspect, "Keydata",0)
#    call_parenthandler("edit1_char", keycode, keydata)
#  end
#end

VRLocalScreen.start Frm_form1
