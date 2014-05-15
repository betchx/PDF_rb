## CAUTION!! ## This code was automagically ;-) created by FormDesigner.
# NEVER modify manualy -- otherwise, you'll have a terrible experience.

require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrddrop'

module Frm_form1
  include VRDropFileTarget

  def _form1_init
    self.caption = 'PDF 時間修正ツール'
    self.move(140,124,361,544)
    addControl(VRStatic,'static13',"時",248,88,16,24,1342177280)
    addControl(VRStatic,'static6',"秒",328,48,16,24,1342177280)
    addControl(VRStatic,'static4',"変更したい部分のみ記入してください．   その他は元ファイルの値が使用されます．",8,0,312,40,1342177280)
    addControl(VRCheckbox,'cbKeepBackup',"バックアップファイルを保存する",8,160,280,24,1342177283)
    addControl(VREdit,'mmon',"12",136,88,24,24,1342185602)
    addControl(VRStatic,'static5',"分",288,48,16,24,1342177280)
    addControl(VREdit,'mmin',"12",264,88,24,24,1342185602)
    addControl(VRStatic,'static7',"時",248,48,16,24,1342177280)
    addControl(VRStatic,'static11',"月",160,88,16,24,1342177280)
    addControl(VRStatic,'static1',"年",120,48,16,24,1342177280)
    addControl(VRStatic,'static14',"分",288,88,16,24,1342177280)
    addControl(VRStatic,'static8',"日",200,48,16,24,1342177280)
    addControl(VRText,'msg',"",0,216,352,288,1345325124)
    addControl(VREdit,'mmday',"12",176,88,24,24,1342185602)
    addControl(VREdit,'chour',"12",224,48,24,24,1342185602)
    addControl(VRStatic,'static2',"月",160,48,16,24,1342177280)
    addControl(VREdit,'msec',"12",304,88,24,24,1342185602)
    addControl(VRStatic,'static9',"更新日時",8,88,72,24,1342177280)
    addControl(VREdit,'cyear',"2014",80,48,40,24,1342185602)
    addControl(VRStatic,'static17',"メッセージ，実行ログ",8,192,200,24,1342177280)
    addControl(VRStatic,'static12',"日",200,88,16,24,1342177280)
    addControl(VREdit,'cmin',"12",264,48,24,24,1342185602)
    addControl(VRStatic,'static15',"秒",328,88,16,24,1342177280)
    addControl(VREdit,'myear',"2014",80,88,40,24,1342185602)
    addControl(VREdit,'cmon',"12",136,48,24,24,1342185602)
    addControl(VRCheckbox,'cbVerbose',"詳細表示",232,192,112,24,1342177283)
    addControl(VREdit,'mhour',"12",224,88,24,24,1342185602)
    addControl(VREdit,'csec',"12",304,48,24,24,1342185602)
    addControl(VRStatic,'static3',"作成日時",8,48,72,24,1342177280)
    addControl(VRStatic,'static16',"上を設定後，修正したいPDFファイルをD＆D してください",8,120,336,40,1342177280)
    addControl(VRStatic,'static10',"年",120,88,16,24,1342177280)
    addControl(VREdit,'cmday',"12",176,48,24,24,1342185602)
  end 

  def construct
    _form1_init
  end 

end 

#VRLocalScreen.start Frm_form1
