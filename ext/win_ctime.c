
#include <ruby.h>
#include <time.h>
#include <windows.h>

#define TOO_LONG_PATH_MSG "file path is too long (given: %d, limit %d)"

/*
 * return formatted OS's Error message as Ruby string
 *
 * Ruby's string is used in order to avoid memory free error.
 */
  static
VALUE LastErrorMsg(void)
{
  VALUE retval;
  DWORD code = GetLastError();
  LPSTR msg;

  /* Get message string */
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
  /* Copy message string to ruby string for LocalFree */
  retval = rb_str_new2(msg);

  /* Release allocated buffer */
  LocalFree(msg);

  return retval;
}


/*************************************************************/

/*
 * Convert FILETIME struct to Ruby's Time object
 * */
  static
VALUE FileTimeToRubyTime(LPFILETIME pft)
{
  SYSTEMTIME st;
  VALUE rb_time;

  /* Convert to SYSTEMTIME struct */
  FileTimeToSystemTime(pft, &st);

  /* Create Time Object in UTC */
  rb_time = rb_funcall(rb_cTime, rb_intern("utc"),7,
      INT2NUM(st.wYear), INT2NUM(st.wMonth), INT2NUM(st.wDay),
      INT2NUM(st.wHour), INT2NUM(st.wMinute), INT2NUM(st.wSecond),
      INT2NUM(st.wMilliseconds));

  /* convert UTC to Local Time and return it */
  return rb_funcall(rb_time, rb_intern("localtime"),0);
}

/*
 * Convert Ruby's Time object or similer one to FILETIME struct
 */
static
void make_FileTime(VALUE tm, FILETIME *pft)
{
  SYSTEMTIME st;
  VALUE utc;

  /* Create SYSTEMTIME struct by tm */
  utc = rb_funcall(tm, rb_intern("utc"),0);
  st.wYear   = NUM2INT(rb_funcall(utc, rb_intern("year" ),0));
  st.wMonth  = NUM2INT(rb_funcall(utc, rb_intern("month"),0));
  st.wDay    = NUM2INT(rb_funcall(utc, rb_intern("day"  ),0));
  st.wHour   = NUM2INT(rb_funcall(utc, rb_intern("hour" ),0));
  st.wMinute = NUM2INT(rb_funcall(utc, rb_intern("min"  ),0));
  st.wSecond = NUM2INT(rb_funcall(utc, rb_intern("sec"  ),0));

  /* Convert to FILETIME strurt */
  if( ! SystemTimeToFileTime(&st, pft) ){
    rb_raise(rb_eSystemCallError,
        "Error in SystemTimeToFileTime\n  %s",
        RSTRING_PTR(LastErrorMsg()));
  }
}

/*************************************************************/

/** Obtain Creation Time from path
 *
 * args:
 *   path: Ruby String of Target file's path.
 */
  static
VALUE creation_time_get(VALUE path)
{
  HANDLE hfile = INVALID_HANDLE_VALUE;
  FILETIME ft;
  VALUE tm;   /* Time */
  VALUE msg; /* for Error Message */
  BOOL res;


  /* Argument check */
  if(RSTRING_LEN(path) > MAX_PATH)
    rb_raise(rb_eArgError,
        TOO_LONG_PATH_MSG,
        RSTRING_LEN(path),
        MAX_PATH);

  /* Open the File */
  hfile = CreateFile(RSTRING_PTR(path),
      GENERIC_READ,  /* Required by GetFileTime() */
      FILE_SHARE_READ /*| FILE_SHARE_WRITE*/, /*  Do not allow write access */
      NULL, /*Do not allow inheritate HANDLE to child process*/
      OPEN_EXISTING, /* File must be exist */
      FILE_ATTRIBUTE_NORMAL, /* No special attribute */
      NULL /*No Template file*/
      );

  /* Error check */
  if(hfile == INVALID_HANDLE_VALUE)
    rb_raise(rb_eSystemCallError,
        "CreateFile failed.(path=%s)\n  %s",
        RSTRING_PTR(path),
        RSTRING_PTR(LastErrorMsg()));

  /* Main */
  res = GetFileTime(hfile, &ft, NULL, NULL);

  /* Save error message because CloseHandle() may change Last error code */
  if( ! res)
    msg = LastErrorMsg();

  /* File Handle must be close*/
  if( ! CloseHandle(hfile) )
    rb_raise(rb_eSystemCallError,
        "Error in CloseHandle: %s", RSTRING_PTR(LastErrorMsg()));

  /* Error handling */
  if( ! res)
    rb_raise(rb_eSystemCallError,
        "GetFileTime failed. (path=%s)\n  %s",
        RSTRING_PTR(path),
        RSTRING_PTR(LastErrorMsg()));

  return FileTimeToRubyTime(&ft);
}



/** Update Creation time of the file.
 *
 * path: the path of target file.
 * tm:  Time class object or compatible one (see Readme)
 *
 */
  static
void creation_time_set(VALUE path, VALUE tm)
{
  HANDLE hfile = INVALID_HANDLE_VALUE;
  FILETIME ft;
  VALUE msg;
  BOOL res;

  /* Argument check */
  if(RSTRING_LEN(path) > MAX_PATH)
    rb_raise(rb_eArgError,
        TOO_LONG_PATH_MSG,
        RSTRING_LEN(path),
        MAX_PATH);

  /* Create Filetime */
  make_FileTime(tm, &ft);

  /* Open Target File */
  hfile = CreateFile(RSTRING_PTR(path),
      GENERIC_READ | GENERIC_WRITE, /* SetFileTime() require Write accress */
      FILE_SHARE_READ | FILE_SHARE_WRITE,
      NULL, /*Do not allow inheritate HANDLE to child process*/
      OPEN_EXISTING, /* Target file must exist */
      FILE_ATTRIBUTE_NORMAL, /* No special attribute */
      NULL /*No Template file*/
      );

  /* Error check */
  if(hfile == INVALID_HANDLE_VALUE)
    rb_raise(rb_eSystemCallError,
        "CreateFile failed. (path=%s)\n  %s",
        RSTRING_PTR(path), RSTRING_PTR(LastErrorMsg()));

  /* Execute */
  res = SetFileTime(hfile, &ft, NULL, NULL);

  /* Save error message because CloseHandle() may change Last error code */
  if( ! res)
    msg = LastErrorMsg();

  /* File Handle must be close*/
  if( ! CloseHandle(hfile) )
    rb_raise(rb_eSystemCallError,
        "Error in CloseHandle: %s", RSTRING_PTR(LastErrorMsg()));

  if( ! res) {
    /* Error */
    rb_raise(rb_eSystemCallError,
        "SetFileTime failed. (path=%s)\n  %s",
        RSTRING_PTR(path),
        RSTRING_PTR(msg));
  }
}

/*************************************************************/

/*
 * Method body of File.create_time
 */
  static
VALUE rb_creation_time(int argc, VALUE* argv, VALUE self)
{
  /* Create */
  switch(argc){
    case 2:
      creation_time_set(argv[0], argv[1]);
      /* Fall through */
    case 1:
      return creation_time_get(argv[0]);
  }

  /* Error */
  rb_raise(rb_eArgError,
      "wrong number of arguments (%d for 1 or 2)",
      argc);
}


/*
 * Register method
 */
void Init_win_ctime(void)
{
  rb_define_singleton_method(
      rb_cFile,
      "creation_time",
      rb_creation_time,
      -1); /* Variable Arguments in C style */
}

