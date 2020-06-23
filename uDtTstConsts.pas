unit uDtTstConsts;

interface

const

  { App Specific }
  csCOMPANY             = 'Dt';
  csPRODUCT             = 'TstItemMgr';
  csPRODUCT_FULL        = csCOMPANY + csPRODUCT;
  csPRODUCT_TITLE       = 'Test Item Manager';
  ciVERSION             = 137;
  csVERSION_TITLE       = 'v1.37';

  { App - Titles }
  csITEM                = 'ITEM';
  csITEM_TYPE           = 'ITEM TYPE';
  csITEM_GROUP          = 'ITEM GROUP';
  csITEM_ITEMGROUP      = 'ITEM -> ITEM GROUP';
  //
  csINSERT              = 'New';
  csUPDATE              = 'Modify';
  csDELETE              = 'Delete';
  //
  csADD                 = 'Add';
  csREMOVE              = 'Remove';

  { LOG levels }
  //csLOG_EXT             = '.LOG';
  csLOG_UTF8_EXT        = '.UTF-8.LOG';
  ciLOGLEVEL_ALL        = -1;
  ciLOGLEVEL_NONE       = 0;
  ciLOGLEVEL_DECOR      = 0;
  ciLOGLEVEL_SQL        = 1;
  ciLOGLEVEL_ERROR      = 2;
  ciLOGLEVEL_VERSION    = 3;
  ciLOGLEVEL_LIFETIME   = 4;
  ciLOGLEVEL_UI         = 5;
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
    csINI_VAL_IMPDEF_CNT      = 'ImportDefCOUNT';
    csINI_VAL_IMPDEF          = 'ImportDef';
    csINI_VAL_REL_CNT         = 'RelationCOUNT';
    csINI_VAL_REL             = 'Relation';
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
  ciDB_VERSION_ADM_NONE       =   0;
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

  { Database - Tree }

  csDB_TREE_NODE      = '(TREE NODE)';
  csDB_TREE_PARENT    = '(TREE PARENT NODE)';
  csDB_TREE_PATH      = '(TREE PATH)';
  csDB_TREE_LEVEL     = '(TREE LEVEL)';
  csDB_TREE_Delimiter = CHR(10);

  { Database - Product ItemMgr }
  ciDB_VERSION_PRD_NONE       =   0;
//ciDB_VERSION_PRD            = 100;
//ciDB_VERSION_PRD            = 101; // CRE ItemType
//ciDB_VERSION_PRD            = 102; // CRE Item
//ciDB_VERSION_PRD            = 103; // CRE ItemGroup
  ciDB_VERSION_PRD            = 104; // CRE Item_ItemGroup
  // ------------------------------------
  csDB_TBL_USR_ITEMTYPE               = 'ItemType';
  ciDB_FLD_USR_ITEMTYPE_NAME_Length   = 10; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEMTYPE_NAME          = 'ItemType_Name';   // ATTN: Keep UNIQUE NAME
  // ------------------------------------
  csDB_TBL_USR_ITEM                   = 'Item';
  ciDB_FLD_USR_ITEM_ITEMNR_Length     = 20; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEM_ITEMNR            = 'Item_NR';
  ciDB_FLD_USR_ITEM_NAME_Length       = 75; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEM_NAME              = 'Item_Name';
  csDB_FLD_USR_ITEM_ITEMTYPE_ID       = 'ItemType_ID';     // ATTN: Keep UNIQUE NAME
  csDB_FLD_USR_ITEM_AMO               = 'Item_Amount';
  // ------------------------------------
  csDB_TBL_USR_ITEMGROUP              = 'ItemGroup';
  ciDB_FLD_USR_ITEMGROUP_NODE_Length  = 50; //ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEMGROUP_NODE         = 'ItemGroup_Node';  // ATTN: Keep UNIQUE NAME
  csDB_FLD_USR_ITEMGROUP_LEVEL        = 'ItemGroup_Level'; // ATTN: Keep UNIQUE NAME
  ciDB_FLD_USR_ITEMGROUP_PATH_Length  = ciFDB_INDEXED_VARCHAR_UF8_MAX_LEN;
  csDB_FLD_USR_ITEMGROUP_PATH         = 'ItemGroup_Path';  // ATTN: Keep UNIQUE NAME
  // ------------------------------------
  csDB_TBL_USR_ITEM_ITEMGROUP               = 'Item_ItemGroup';
  csDB_TBL_USR_ITEM_ITEMGROUP_ITEM_ID       = 'Item_ID';
  csDB_TBL_USR_ITEM_ITEMGROUP_ITEMGROUP_ID  = 'ItemGroup_ID';

implementation

end.
