## CAUTION!! ## This code was automagically ;-) created by FormDesigner.
# NEVER modify manualy -- otherwise, you'll have a terrible experience.

require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrddrop'

module Frm_form1
  include VRDropFileTarget

  def _form1_init
    self.caption = 'PDF ���ԏC���c�[��'
    self.move(140,124,361,544)
    addControl(VRStatic,'static13',"��",248,88,16,24,1342177280)
    addControl(VRStatic,'static6',"�b",328,48,16,24,1342177280)
    addControl(VRStatic,'static4',"�ύX�����������̂݋L�����Ă��������D   ���̑��͌��t�@�C���̒l���g�p����܂��D",8,0,312,40,1342177280)
    addControl(VRCheckbox,'cbKeepBackup',"�o�b�N�A�b�v�t�@�C����ۑ�����",8,160,280,24,1342177283)
    addControl(VREdit,'mmon',"12",136,88,24,24,1342185602)
    addControl(VRStatic,'static5',"��",288,48,16,24,1342177280)
    addControl(VREdit,'mmin',"12",264,88,24,24,1342185602)
    addControl(VRStatic,'static7',"��",248,48,16,24,1342177280)
    addControl(VRStatic,'static11',"��",160,88,16,24,1342177280)
    addControl(VRStatic,'static1',"�N",120,48,16,24,1342177280)
    addControl(VRStatic,'static14',"��",288,88,16,24,1342177280)
    addControl(VRStatic,'static8',"��",200,48,16,24,1342177280)
    addControl(VRText,'msg',"",0,216,352,288,1345325124)
    addControl(VREdit,'mmday',"12",176,88,24,24,1342185602)
    addControl(VREdit,'chour',"12",224,48,24,24,1342185602)
    addControl(VRStatic,'static2',"��",160,48,16,24,1342177280)
    addControl(VREdit,'msec',"12",304,88,24,24,1342185602)
    addControl(VRStatic,'static9',"�X�V����",8,88,72,24,1342177280)
    addControl(VREdit,'cyear',"2014",80,48,40,24,1342185602)
    addControl(VRStatic,'static17',"���b�Z�[�W�C���s���O",8,192,200,24,1342177280)
    addControl(VRStatic,'static12',"��",200,88,16,24,1342177280)
    addControl(VREdit,'cmin',"12",264,48,24,24,1342185602)
    addControl(VRStatic,'static15',"�b",328,88,16,24,1342177280)
    addControl(VREdit,'myear',"2014",80,88,40,24,1342185602)
    addControl(VREdit,'cmon',"12",136,48,24,24,1342185602)
    addControl(VRCheckbox,'cbVerbose',"�ڍו\��",232,192,112,24,1342177283)
    addControl(VREdit,'mhour',"12",224,88,24,24,1342185602)
    addControl(VREdit,'csec',"12",304,48,24,24,1342185602)
    addControl(VRStatic,'static3',"�쐬����",8,48,72,24,1342177280)
    addControl(VRStatic,'static16',"���ݒ��C�C��������PDF�t�@�C����D��D ���Ă�������",8,120,336,40,1342177280)
    addControl(VRStatic,'static10',"�N",120,88,16,24,1342177280)
    addControl(VREdit,'cmday',"12",176,48,24,24,1342185602)
  end 

  def construct
    _form1_init
  end 

end 

#VRLocalScreen.start Frm_form1
