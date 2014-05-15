## CAUTION!! ## This code was automagically ;-) created by FormDesigner.
# NEVER modify manualy -- otherwise, you'll have a terrible experience.

require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrddrop'

module Frm_form1
  include VRDropFileTarget

  def _form1_init
    $_form1_fonts=[
      @screen.factory.newfont('メイリオ',-13,0,4,0,0,0,50,128)
    ]
    self.caption = 'PDF 時間修正ツール'
    self.move(140,124,503,544)
    addControl(VREdit,'mmon',"12",136,88,24,24,1342251138)
    addControl(VRStatic,'static13',"時",248,88,16,24,1342177280)
    addControl(VRStatic,'static6',"秒",328,48,16,24,1342177280)
    addControl(VRStatic,'static4',"変更したい部分のみ記入してください．   その他は元ファイルの値が使用されます．",8,0,312,40,1342177280)
    addControl(VRButton,'btn_clearl_medits',"更新日時をクリア",352,88,136,24,1342242816)
    addControl(VREdit,'cmday',"12",176,48,24,24,1342251138)
    addControl(VRStatic,'static5',"分",288,48,16,24,1342177280)
    addControl(VREdit,'mmday',"12",176,88,24,24,1342251138)
    addControl(VRButton,'btnClearMsg',"メッセージクリア",336,184,152,32,1342177280)
    addControl(VRStatic,'static7',"時",248,48,16,24,1342177280)
    addControl(VREdit,'chour',"12",224,48,24,24,1342251138)
    addControl(VRStatic,'static11',"月",160,88,16,24,1342177280)
    addControl(VRStatic,'static1',"年",120,48,16,24,1342177280)
    addControl(VREdit,'mhour',"12",224,88,24,24,1342251138)
    addControl(VRStatic,'static14',"分",288,88,16,24,1342177280)
    addControl(VRStatic,'static8',"日",200,48,16,24,1342177280)
    addControl(VREdit,'cmin',"12",264,48,24,24,1342251138)
    addControl(VRText,'msg',"",0,216,488,296,1345325124)
    @msg.setFont($_form1_fonts[0])
    addControl(VRStatic,'static2',"月",160,48,16,24,1342177280)
    addControl(VREdit,'mmin',"12",264,88,24,24,1342251138)
    addControl(VRStatic,'static9',"更新日時",8,88,72,24,1342177280)
    addControl(VREdit,'csec',"12",304,48,24,24,1342251138)
    addControl(VRStatic,'static17',"メッセージ，実行ログ",8,192,200,24,1342177280)
    addControl(VRStatic,'static12',"日",200,88,16,24,1342177280)
    addControl(VREdit,'msec',"12",304,88,24,24,1342251138)
    addControl(VREdit,'cyear',"2014",80,48,40,24,1342251138)
    addControl(VRStatic,'static15',"秒",328,88,16,24,1342177280)
    addControl(VREdit,'myear',"2014",80,88,40,24,1342251138)
    addControl(VRCheckbox,'cbVerbose',"詳細表示",216,192,112,24,1342177283)
    addControl(VRStatic,'static3',"作成日時",8,48,72,24,1342177280)
    addControl(VRButton,'btn_clear_cedits',"作成日時をクリア",352,48,136,24,1342242816)
    addControl(VREdit,'cmon',"12",136,48,24,24,1342251138)
    addControl(VRStatic,'static16',"上を設定後，修正したいPDFファイルをD＆D してください",8,120,480,24,1342177280)
    addControl(VRStatic,'static10',"年",120,88,16,24,1342177280)
  end 

  def construct
    _form1_init
  end 

end 

#VRLocalScreen.start Frm_form1
