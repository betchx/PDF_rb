PDF_rb
======

Ruby scripts for PDF files



get_pdf_date
------------

PDFファイル内部に保存されている
* 作成日時
* 更新日時

を探し出して表示するコンソールスクリプト．

exerbやOcraでexe化されている場合は，
Enterを押すまでウインドウが閉じられない様にしている．

D&D（もしくは右クリック⇒送る）での実行が基本と考えると，
速度面からocraよりはexerbのほうがベターと思われるので，
わざわざ1.8対応としてある．


pdf_time_changer
----------------

D&DしたPDFファイル内部の日時を所定の値に更新するGUIプログラム．

VisualuRubyを使用しているので，Windows専用．

動作速度から，Ocraではなくexerbでのexe化を考えているので，Ruby1.8.7用．
Ocraを含めた1.9以降での動作については未確認．

