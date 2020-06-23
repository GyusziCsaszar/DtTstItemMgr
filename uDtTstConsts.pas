unit uDtTstConsts;

interface

const

  { App Specific }
  csCOMPANY             = 'Dt';
  csPRODUCT             = 'TstItemMgr';
  csPRODUCT_FULL        = csCOMPANY + csPRODUCT;
  csPRODUCT_TITLE       = 'Test Item Manager';
  ciVERSION             = 127;
  csVERSION_TITLE       = 'v1.27';

  { App - Strings }
  csITEM                = 'ITEM';
  csITEM_TYPE           = 'ITEM TYPE';

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
  //
  ccMnuItmID_View              = '2';
  ccMnuItmID_Table             = '3';
  ccMnuItmID_Table_Column      = '4';
  ccMnuItmID_Table_Trigger     = '5';
  ccMnuItmID_Table_Constraint  = '6';
  ccMnuItmID_Query             = '7';
  // --------------------------------
  ccMnuBtnID_Refresh           = '1';
  ccMnuBtnID_Details           = '2';
  ccMnuBtnID_Open              = '3';
  ccMnuBtnID_Import_Table      = '4';
  ccMnuBtnID_Delete_From_Table = '5';
  ccMnuBtnID_Drop_Table        = '6';
  ccMnuBtnID_Drop_Column       = '7';
  ccMnuBtnID_Drop_View         = '8';
  //
  ccMnuBtnID_Import_Item_Type  = '9';
  ccMnuBtnID_Import_Item       = 'A';

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

  // ATTN!!!
  // Max VarChar (UTF8) Lenght when Indexing IS: 253 // When FDB Page Size is 4096
  // SRC: https://stackoverflow.com/questions/1953690/what-is-the-maximum-size-of-a-primary-key-in-firebird
  ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN = 253;

  { Database - SAMPLE }
  csDB_TBL_SAMPLE             = 'SAMPLETABLE';

  { Database - Base }
//ciDB_VERSION_ADM            = 100; // CRE admDbInfo
//ciDB_VERSION_ADM            = 101; // CRE admUsers,  INS User
//ciDB_VERSION_ADM            = 102; // CRE admTables, INS Table admUsers
  ciDB_VERSION_ADM            = 103; // ALT admDbInfo, CRE ProductVersion = 100
  // ------------------------------------
  csDB_FLD_ADM_X_ID           = 'ID';
  ciDB_FLD_ADM_X_USR_Lenght   = 8;            // ATTN: Allowed User Name's Max Length!!!
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
//ciDB_VERSION_PRD            = 101; // CRE ItemType
  ciDB_VERSION_PRD            = 102; // CRE Item
  // ------------------------------------
  csDB_TBL_USR_ITEMTYPE             = 'ItemType';
  ciDB_FLD_USR_ITEMTYPE_NAME_Length = 20; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEMTYPE_NAME        = 'ItemType_Name';
  // ------------------------------------
  csDB_TBL_USR_ITEM                 = 'Item';
  ciDB_FLD_USR_ITEM_ITEMNR_Length   = 10; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEM_ITEMNR          = 'Item_NR';
  ciDB_FLD_USR_ITEM_NAME_Length     = 30; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEM_NAME            = 'Item_Name';
  csDB_FLD_USR_ITEM_ITEMTYPE_ID     = 'ItemType_ID';
  csDB_FLD_USR_ITEM_AMO             = 'Item_Amount';

implementation

end.
