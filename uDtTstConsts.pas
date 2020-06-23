unit uDtTstConsts;

interface

const

  { App Specific }
  csCOMPANY             = 'Dt';
  csPRODUCT             = 'TstItemMgrı’˚€ÌÕ';
  csPRODUCT_TITLE       = 'Test Item Manager';
  ciVERSION             = 112;
  csVERSION_TITLE       = 'v1.12';
  ciDB_VERSION          = 100;
  ciDB_VERSION_100      = 100;

  { LOG levels }
  //csLOG_EXT             = '.LOG';
  csLOG_UTF8_EXT        = '.UTF-8.LOG';
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
    csINI_VAL_DB_UTF8         = 'ServerCharsetUTF8';
    csINI_VAL_DB_CONSTR_CNT   = 'ConnectStringCOUNT';
    csINI_VAL_DB_CONSTR_DEF   = 'ConnectStringDEFAULT';
    csINI_VAL_DB_CONSTR       = 'ConnectString';
    csINI_VAL_DB_USR          = 'User';
    csINI_VAL_DB_PW           = 'Password';

  { Database }
  csDB_TBL_SAMPLE           = 'SAMPLETABLE';

  csDB_TBL_ADM_DBINF        = 'admDbInfo';
  csDB_FLD_ADM_DBINF_ID     = 'ID';
  csDB_FLD_ADM_DBINF_VER    = 'Version';
  csDB_FLD_ADM_DBINF_PRD    = 'Product';

implementation

end.
