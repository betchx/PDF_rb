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

DATE_FORMAT = '%F %T %:z'


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
  
  # メッセージを表示
  def show(msg = "", cont = false)
    if cont
      @msg_text += msg
    else
      @msg_text += msg.chomp + "\r\n"
    end
    @msg.text = @msg_text
    n = @msg_text.size
    @msg.setSel(n, n)
  end
  
  # メッセージを詳細に表示する場合
  def info(msg)
    if @cbVerbose
      @msg_text += msg.chomp + "\r\n"
      @msg.text = @msg_text
    end
  end
  
  # メイン実行部
  def self_dropfiles(files)

    # Start
    show "==============================================================="
    show "処理開始： #{DateTime.now.strftime(DATE_FORMAT)}"
    show "---------------------------------------------------------------"

    # 修正項目ハッシュの取得
    c_mod = get_mod(@c_edits)
    m_mod = get_mod(@m_edits)
    f   = nil # スコープ対策
    out = nil # スコープ対策
    
    ok = 0 # 処理に成功したファイル数
    ng = 0 # 処理に失敗したファイル数
    
    files.each do |file|
      show "対象ファイル：#{file}"
      back = file + ".bak"
      show "対象ファイルを退避 ==> #{back} ", true
      begin
        File.rename(file, back)
        show " OK"
      rescue
        show " エラー (処理をスキップします)"
        ng += 1
        next
      end
      begin
        f = open(back, "rb")
        info "PDFをオープン"
      rescue
        show "退避後のファイル(#{back})を読み込み様に開けませんでした．(BUG)"
        show "なんらかの重大なエラーが生じた可能性があるので処理を中断しました．"
        return
      end
      begin
        out = open(file, "wb")
        info "出力先をオープン"
      rescue
        show "ファイル(#{file})を書き込み様に開けませんでした．"
        show "ディスクの空きが不足しているなどがのエラーが考えられます．"
        show "重大なエラーの為処理を中断しました．"
        return
      end
      header = f.gets
      msg "PDF バージョン: #{header}"
      begin
        out.puts header
      rescue
        show "ファイルが書き込みできませんでした."
        show "スキップします."
        out.close
        f.close
        File.delete(file)
        File.rename(back, file)
        ng += 1
        next
      end
      while line = f.gets
        #####################################
        begin # 作成日時
        if line =~ CDATE_OLD_RE
          dt = DateTime.parse($2+$3)
          if update = query("作成日時", c_mod, dt)
            line.sub!(CDATE_OLD_RE){
              $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
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
        rescue 
          show "エラーが生じました． 作成日時の設定にエラーがあるかもしれません．"
          show "処理を中断し，ファイルを復旧します．"
          out.close
          f.close
          File.delete(file)
          File.rename(back, file)
          #File.rename(file, file+".err")
          #show "注意：処理途中だったファイルを#{file+'.err'}に移動し，オリジナルファイルを復元しました．"
          return
        end
        
        begin # mod
        if line =~ MDATE_OLD_RE
          dt = DateTime.parse($2+$3)
          if update = query("更新日時", m_mod, dt)
            line.sub!(MDATE_OLD_RE){
              $1 + update.strftime("%Y%m%d%H%M%S%:z:)").gsub(":","'")}
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
        rescue 
          show "エラーが生じました． 更新日時の設定にエラーがあるかもしれません．"
          show "処理を中断し，元ファイルを復旧します．"
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
      
      ok += 1
      
    end
    
    show 
    show "---------------------------------------------------------------"
    show " #{file.size}ファイルを処理"
    show " #{ok}ファイルの修正に成功．" if ok > 0
    show " #{ng}ファイルは修正に失敗 " if ng > 0
    show " 処理終了 at #{DateTime.now.strftime(DATE_FORMAT)}"
    show 
    show "!!注意!! ファイルシステムの時刻は現在時刻のままですので別途修正してください．"
    show
    
  end

  def query(msg, mod, tm)
    return false if mod.empty? # 時間修正が無ければ何もしない．

    # 再解釈してコピー （Timeが引数としてくる場合があるため）
    h = DateTime._parse(tm.to_s)
    h.update(mod)
    dt =  h.to_datetime

    return false if dt == tm  # 時間修正が無ければ何もしない．
    
    show "#{msg}を修正： #{tm.strftime(DATE_FORMAT)} ==> #{dt.strftime(DATE_FORMAT)}"
    return dt
  end

# キャンセル． 不安定化の原因になりそうなので
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
