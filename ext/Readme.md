"win_ctime" 拡張ライブラリ
==========================

概要
----

Windowsにおいてファイル作成日時を取得・設定するためのクラスメソッドをFileクラスに追加します．


メソッドの説明
--------------
次のメソッドが追加されます．（追加されるのはこれだけです）

```ruby
File.create_time(file_path [, new_time] ) # => Time
```

第一引数として指定されたパスのファイルの作成日時をTimeクラスのオブジェクトで返します．
第二引数が与えられた場合は，その値で作成日時を更新します．第二引数としてはTimeオブジェクト，もしくは以下のインスタンスメソッドをもつオブジェクトが利用可能です．

必要なインスタンスメソッド： year, month, day, hour, min, sec および utc.


使用例
------
第一引数のファイルの作成日時で，残りのファイルの作成日時を変更するスクリプトの例を以下に示します.

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


履歴
----

ver 0.1 @ 2014-05-20
作成．


