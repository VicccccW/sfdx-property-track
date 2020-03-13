global with sharing class GlobalConstants {

    //custom settings
    public static final System_Config__c systemConfig = System_Config__c.getInstance();
    public static final System_Switch__c systemSwitch = System_Switch__c.getInstance();

    //API codes
    public static final Integer STATUS_CODE_NOT_FOUND = 404;
    public static final Integer STATUS_CODE_OK = 200;
    public static final Integer STATUS_CODE_BAD_REQUEST = 400;
    public static final Integer STATUS_CODE_SUCCESS = 200;

    //SPECIAL CHARACTERS
    public static final String SPECIAL_CHAR_HYPHEN = '-';
    public static final String SPECIAL_CHAR_PLUS = '+';
    public static final String SPECIAL_CHAR_EQUAL_TO = '=';
    public static final String SPECIAL_CHAR_NOT_EQUAL_TO = '!=';
    public static final String SPECIAL_CHAR_GREATER_THAN = '>';
    public static final String SPECIAL_CHAR_SMALLER_THAN = '<';
    public static final String SPECIAL_CHAR_OPEN_BRACKET = '(';
    public static final String SPECIAL_CHAR_CLOSED_BRACKET = ')';
    public static final String SPECIAL_CHAR_QUOTE = '\'';
    public static final String SPECIAL_CHAR_DOT = '.';
    public static final String EMPTY_STRING = '';
    public static final String SPACE = ' ';
    public static final String COMMA = ',';

    public static final String SOQL_CLAUSE_WHERE = 'WHERE';
    public static final String SOQL_CLAUSE_AND = 'AND';

    //Object API
    public static final String PROPERTY_OBJECT_API = 'Property__c';

    public static final String HTTP_POST_METHOD = 'POST';
    public static final String HTTP_GET_METHOD = 'GET';
    public static final String HTTP_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_CONTENT_TYPE_JSON_APP = 'application/json';

    //Named Credential API Name
    //public static final String ENDPOINT_PROPERTY_BACKUP_MONGODB = 'callout:Property_Backup_SF_To_MongoDB';
}
