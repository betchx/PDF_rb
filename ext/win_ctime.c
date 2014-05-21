
#include <ruby.h>
#include <time.h>
/*#include <winbase.h>*/
#include <windows.h>

#define TOO_LONG_PATH_MSG "file path is too long (given: %d, limit %d)"


/* See Windows NB 167296 */
static
void UnixTimeToFileTime(time_t t, LPFILETIME pft)
{
  LONGLONG ll;
  ll = Int32x32To64(t, 10000000) + 116444736000000000;
  pft->dwLowDateTime = (DWORD)ll;
  pft->dwHighDateTime = ll >> 32;
}

static
VALUE FileTimeToRubyTime(LPFILETIME pft)
{
  SYSTEMTIME st;
  VALUE rb_time;

  FileTimeToSystemTime(pft, &st);

  rb_time = rb_funcall(rb_cTime, rb_intern("utc"),7,
      INT2NUM(st.wYear), INT2NUM(st.wMonth), INT2NUM(st.wDay),
      INT2NUM(st.wHour), INT2NUM(st.wMinute), INT2NUM(st.wSecond),
      INT2NUM(st.wMilliseconds));

  return rb_funcall(rb_time, rb_intern("localtime"),0);
}

static VALUE creation_time_get(VALUE path)
{
  HANDLE hfile = INVALID_HANDLE_VALUE;
  time_t tt;
  FILETIME ft;
  VALUE tm;
  BOOL res;


  if(RSTRING_LEN(path) > MAX_PATH)
    rb_raise(rb_eArgError,
        TOO_LONG_PATH_MSG,
        RSTRING_LEN(path),
        MAX_PATH);

  hfile = CreateFile(RSTRING_PTR(path),
      GENERIC_READ,
      FILE_SHARE_READ /*| FILE_SHARE_WRITE*/,
      NULL, /*Do not allow inheritate HANDLE to child process*/
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL,
      NULL /*No Template file*/
      );
  if(hfile == INVALID_HANDLE_VALUE)
    rb_raise(rb_eSystemCallError,
        "CreateFile failed.(path=%s)",
        RSTRING_PTR(path));

  res = GetFileTime(hfile, &ft, NULL, NULL);
  CloseHandle(hfile);
  if(!res)
    rb_raise(rb_eSystemCallError,
        "GetFileTime failed. (path=%s)",
        RSTRING_PTR(path));

  return FileTimeToRubyTime(&ft);
}

static VALUE creation_time_set(VALUE path, VALUE tm)
{
  HANDLE hfile = INVALID_HANDLE_VALUE;
  FILETIME ft;
  SYSTEMTIME st;
  VALUE t, utc;

  if(RSTRING_LEN(path) > MAX_PATH)
    rb_raise(rb_eArgError,
        TOO_LONG_PATH_MSG,
        RSTRING_LEN(path),
        MAX_PATH);

#if 0
  time_t tt;
  if(RSTRING_LEN(klass) != 4 ||
      strncmp("Time", RSTRING_PTR(klass), 4) != 0)
    rb_raise(rb_eArgError,
        "RHS must be Time but %s given.",
        RSTRING_PTR(klass));
  /* OK */
  t = rb_funcall(rb_funcall(tm,rb_intern("utc"),0),rb_intern("tv_sec"),0);
  tt = (time_t)NUM2INT(t);
  UnixTimeToFileTime(tt, &ft);
#endif
  utc = rb_funcall(tm, rb_intern("utc"),0);
  st.wYear   = NUM2INT(rb_funcall(utc, rb_intern("year"),0));
  st.wMonth  = NUM2INT(rb_funcall(utc, rb_intern("month"),0));
  st.wDay    = NUM2INT(rb_funcall(utc, rb_intern("mday"),0));
  st.wHour   = NUM2INT(rb_funcall(utc, rb_intern("hour"),0));
  st.wMinute = NUM2INT(rb_funcall(utc, rb_intern("min"),0));
  st.wSecond = NUM2INT(rb_funcall(utc, rb_intern("sec"),0));

  if( ! SystemTimeToFileTime(&st, &ft) ){
    rb_raise(rb_eSystemCallError,
        "Error in SystemTimeToFileTime"
        );
  }

  hfile = CreateFile(RSTRING_PTR(path),
      GENERIC_READ | GENERIC_WRITE,
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      NULL, /*Do not allow inheritate HANDLE to child process*/
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL,
      NULL /*No Template file*/
      );
  if(hfile == INVALID_HANDLE_VALUE)
    rb_raise(rb_eSystemCallError,
        "CreateFile failed. (path=%s)",
        RSTRING_PTR(path));

  if(! SetFileTime(hfile, &ft, NULL, NULL)){
    /* Error */
    CloseHandle(hfile);
    DWORD code = GetLastError();
    LPSTR msg;
    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        code,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR)&msg,
        0,
        NULL);
    rb_raise(rb_eSystemCallError,
        "SetFileTime failed. (path=%s)\nReason: %s",
        RSTRING_PTR(path),
        (LPCTSTR)msg);
    LocalFree(msg);
  }

  /* OK */
  CloseHandle(hfile);

  return tm;
}

static
VALUE rb_create_time(int argc, VALUE* argv, VALUE self)
{
  switch(argc){
  case 1:
    return creation_time_get(argv[0]);
  case 2:
    return creation_time_set(argv[0], argv[1]);
  }
  rb_raise(rb_eArgError,
      "wrong number of arguments (%d for 1 or 2)",
      argc);
}


void Init_win_ctime(void)
{
  rb_define_singleton_method(
      rb_cFile,
      "create_time",
      rb_create_time,
      -1);
}

