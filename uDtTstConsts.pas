unit uDtTstConsts;

interface

const

  { App Specific }
  csCOMPANY             = 'Dt';
  csPRODUCT             = 'TstItemMgrı’˚€ÌÕ';
  csPRODUCT_FULL        = csCOMPANY + csPRODUCT;
  csPRODUCT_TITLE       = 'Test Item Manager';
  ciVERSION             = 114;
  csVERSION_TITLE       = 'v1.14';
  ciDB_VERSION          = 101;

  { LOG levels }
  //csLOG_EXT             = '.LOG';
  csLOG_UTF8_EXT        = '.UTF-8.LOG';
  ciLOGLEVEL_ALL        = -1;
  ciLOGLEVEL_NONE       = 0;
  ciLOGLEVEL_DECORATION = 0;
  ciLOGLEVEL_ERROR      = 1;
  ciLOGLEVEL_VERSION    = 2;
  ciLOGLEVEL_LIFETIME   = 3;
  ciLOGLEVEL_UI         = 4;
  ciLOGLEVEL_SQL        = 5;
  ciLOGLEVEL_NA         = 6;

  { INI File }
  csINI_EXT                   = '.INI';
  csINI_SEC_LOG               = 'Log';
    csINI_VAL_LOG_LEVEL       = 'Level';
  csINI_SEC_DB                = 'Database';
    csINI_VAL_DB_ISQLPATH     = 'IsqlPath';
    csINI_VAL_DB_ISQLOPTS     = 'IsqlOptions';
    csINI_VAL_DB_UTF8         = 'ServerCharsetUTF8';
    csINI_VAL_DB_CONSTR_CNT   = 'ConnectStringCOUNT';
    csINI_VAL_DB_CONSTR_DEF   = 'ConnectStringDEFAULT';
    csINI_VAL_DB_CONSTR       = 'ConnectString';
    csINI_VAL_DB_USR          = 'User';
    csINI_VAL_DB_PW           = 'Password';

  { Database - SAMPLE }
  csDB_TBL_SAMPLE             = 'SAMPLETABLE';

  { Database - Base }
  csDB_TBL_ADM_DBINF          = 'admDbInfo';
  csDB_FLD_ADM_DBINF_ID       = 'ID';
  csDB_FLD_ADM_DBINF_VER      = 'Version';
  csDB_FLD_ADM_DBINF_PRD      = 'Product';
  // ------------------------------------
  csDB_FLD_ADM_TSPCRE         = 'admCreTsp';
  // ------------------------------------
  csDB_TBL_ADM_USERS          = 'admUsers';
  csDB_FLD_ADM_USERS_ID       = 'ID';
  csDB_FLD_ADM_USERS_USER     = 'UserName'; //'User';
  csDB_FLD_ADM_USERS_LSTLOGIN = 'LastLoginTSP';

  { Firebird }
  csISQL_FILE_IN              = '_Isql_IN.sql';
  csISQL_FILE_OUT             = '_Isql_OUT.txt';
  csISQL_SUCCESS              = 'ISQL_OK';

implementation

end.
