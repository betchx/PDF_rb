"win_ctime" �g�����C�u����
==========================

�T�v
----

Windows�ɂ����ăt�@�C���쐬�������擾�E�ݒ肷�邽�߂̃N���X���\�b�h��File�N���X�ɒǉ����܂��D


���\�b�h�̐���
--------------
���̃��\�b�h���ǉ�����܂��D�i�ǉ������̂͂��ꂾ���ł��j

```ruby
File.create_time(file_path [, new_time] ) # => Time
```

�������Ƃ��Ďw�肳�ꂽ�p�X�̃t�@�C���̍쐬������Time�N���X�̃I�u�W�F�N�g�ŕԂ��܂��D
���������^����ꂽ�ꍇ�́C���̒l�ō쐬�������X�V���܂��D�������Ƃ��Ă�Time�I�u�W�F�N�g�C�������͈ȉ��̃C���X�^���X���\�b�h�����I�u�W�F�N�g�����p�\�ł��D

�K�v�ȃC���X�^���X���\�b�h�F year, month, day, hour, min, sec ����� utc.


�g�p��
------
�������̃t�@�C���̍쐬�����ŁC�c��̃t�@�C���̍쐬������ύX����X�N���v�g�̗���ȉ��Ɏ����܂�.

```ruby
require 'win_ctime'

unless ARGV.size > 1
  puts <<EOU
usage:
  #{$0} source_file target_file(s)

EOU
  exit
end

source = ARGV.shift
tm = File.create_time(source)

ARGV.each do |file|
  File.create_time(file, tm)
end

```


����
----

ver 0.1 @ 2014-05-20
�쐬�D


