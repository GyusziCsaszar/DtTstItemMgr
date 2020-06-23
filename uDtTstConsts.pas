unit uDtTstConsts;

interface

const

  { LOG levels }
  csLOG_EXT             = '.LOG';
  ciLOGLEVEL_ALL        = -1;
  ciLOGLEVEL_NONE       = 0;
  ciLOGLEVEL_DECORATION = 0;
  ciLOGLEVEL_ERROR      = 1;
  ciLOGLEVEL_LIFETIME   = 2;
  ciLOGLEVEL_NA         = 3;

  { INI File }
  csINI_EXT                   = '.INI';
  csINI_SEC_LOG               = 'Log';
    csINI_VAL_LOG_LEVEL       = 'Level';
  csINI_SEC_DB                = 'Database';
    csINI_VAL_DB_CONSTR_CNT   = 'ConnectStringCOUNT';
    csINI_VAL_DB_CONSTR_DEF   = 'ConnectStringDEFAULT';
    csINI_VAL_DB_CONSTR       = 'ConnectString';
    csINI_VAL_DB_USR          = 'User';
    csINI_VAL_DB_PW           = 'Password';

implementation

end.
