unit uDtTstConsts;

interface

const

  { App Specific }
  csCOMPANY             = 'Dt';
  csPRODUCT             = 'TstItemMgrı’˚€ÌÕ';
  csPRODUCT_FULL        = csCOMPANY + csPRODUCT;
  csPRODUCT_TITLE       = 'Test Item Manager';
  ciVERSION             = 123;
  csVERSION_TITLE       = 'v1.23';

  { App - Menu }
  ccMnuBtn                     = '0';
  ccMnuGrp                     = '1';
  ccMnuItm                     = '2';
  ccMnuCap                     = '3';
  // --------------------------------
  ciMnuIdx_Ctrl                = 1;
  ciMnuIdx_ID                  = 2;
  ciMnuCch                     = 4;
  // --------------------------------
  ciMnuGrpItmLeftMargin        = 8; //13;
  // --------------------------------
  ccMnuGrpID_Database          = '1';
  // --------------------------------
  ccMnuItmID_Table             = '2';
  ccMnuItmID_Table_Column      = '3';
  ccMnuItmID_Query             = '4';
  // --------------------------------
  ccMnuBtnID_Refresh           = '1';
  ccMnuBtnID_Open              = '2';
  ccMnuBtnID_Import_Table      = '3';
  ccMnuBtnID_Drop_Table        = '4';
  ccMnuBtnID_Drop_Column       = '5';

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
    csINI_VAL_DB_ISQLPATH_ALT = 'IsqlPathAlternate';
    csINI_VAL_DB_ISQLOPTS     = 'IsqlOptions';
    csINI_VAL_DB_UTF8         = 'ServerCharsetUTF8';
    csINI_VAL_DB_CONSTR_CNT   = 'ConnectStringCOUNT';
    csINI_VAL_DB_CONSTR_DEF   = 'ConnectStringDEFAULT';
    csINI_VAL_DB_CONSTR       = 'ConnectString';
    csINI_VAL_DB_USR          = 'User';
    csINI_VAL_DB_PW           = 'Password';
  csINI_SEC_APP               = 'Database'; // BUG: Not worked with any other value!!!
    csINI_VAL_APP_ADMIN_MODE  = 'AdminMode';

  { Firebird }
  csISQL_FILE_IN              = '_Isql_IN.sql';
  csISQL_FILE_OUT             = '_Isql_OUT.txt';
  csISQL_SUCCESS              = 'ISQL_EXEC_OK';
  csFBRD_FDB_FILE_FILTER      = 'Firebird Database Files (*.FDB)|*.fdb';

  { Generic }
  csCSV_FILE_FILTER           = 'CSV Files (*.CSV)|*.csv';

  { Database - SAMPLE }
  csDB_TBL_SAMPLE             = 'SAMPLETABLE';

  { Database - Base }
//ciDB_VERSION_ADM            = 100; // CRE admDbInfo
//ciDB_VERSION_ADM            = 101; // CRE admUsers,  INS User
//ciDB_VERSION_ADM            = 102; // CRE admTables, INS Table admUsers
  ciDB_VERSION_ADM            = 103; // ALT admDbInfo, CRE ProductVersion = 100
  // ------------------------------------
  csDB_FLD_ADM_X_ID           = 'ID';
  csDB_FLD_ADM_X_USRCRE       = 'admCreUsr';
  csDB_FLD_ADM_X_TSPCRE       = 'admCreTsp';
  csDB_FLD_ADM_X_USRUPD       = 'admUpdUsr';
  csDB_FLD_ADM_X_TSPUPD       = 'admUpdTsp';
  // ------------------------------------
  csDB_TBL_ADM_DBINF          = 'admDbInfo';
  csDB_FLD_ADM_DBINF_VER      = 'Version';
  csDB_FLD_ADM_DBINF_PRD      = 'Product';
  csDB_FLD_ADM_DBINF_PRD_VER  = 'ProductVersion';
  // ------------------------------------
  csDB_TBL_ADM_USERS          = 'admUsers';
  csDB_FLD_ADM_USERS_USER     = 'UserName'; //'User';
  csDB_FLD_ADM_USERS_LSTLOGIN = 'LastLoginTSP';
  // ------------------------------------
  csDB_TBL_ADM_TABLES         = 'admTables';
  csDB_FLD_ADM_TABLES_NAME    = 'TableName';

  { Database - Product ItemMgr }
//ciDB_VERSION_PRD            = 100;
  ciDB_VERSION_PRD            = 101; // CRE usrItemType
  // ------------------------------------
  csDB_TBL_USR_ITEMTYPE       = 'usrItemType';
  csDB_FLD_USR_ITEMTYPE_NAME  = 'Name';

implementation

end.
