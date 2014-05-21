
require 'mkmf'

if ARGV.empty?
  $CFLAGS='-O2 -DNDEBUG'
else
  $CFLAGS='-O2 -g'
end

PACKAGE_NAME='win_ctime'


dir_config(PACKAGE_NAME)
if have_header('windows.h') #and have_header('narray_config.h') and have_library('narray')
  create_makefile(PACKAGE_NAME)
end


