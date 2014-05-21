"win_ctime" extension library
=============================

Abstract
--------

This extension library provide methods to obtain and modify file creation time on Windows OS as a singleton method of the File class.


Method to be added
------------------
This library provide just one class method only as below:

```ruby
File.create_time(file_path [, new_time] ) # => Time
```

This method returns the creation time of the file specified by the first argument as a Time object.
If the second argument was given, the creation time of the specified file was chaned by it.
The second argment can be the Time class ojbect or similar object which has following instance methods: year, month, day, hour, min, sec and utc.


Example
-------
Following is a example code to copy creation time from the first argument file to rest files.

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


History
-------

ver 0.1 @ 2014-05-20
Created.


