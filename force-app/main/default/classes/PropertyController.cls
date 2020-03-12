/**
 * This class is used to call external service endpoint to backup Salesforce property records
 * This class retrieves and stringfy data, send it to an end point (POST)
 * This class will be implmented in a Scheduled Class
 */
global without sharing class PropertyController {

    public static void sendBackupRequest() {
        BackupPropertyWrapper data = getBackupData();
        sendBackupPostRequest(data);
    }

    private static BackupPropertyWrapper getBackupData() {
        BackupPropertyWrapper backupPropertyWrapper = new BackupPropertyWrapper();

        Integer scanDateRange = GlobalConstants.systemConfig.Property_Backup_Scan_Range_Days__c != null 
                                ? Integer.valueOf(GlobalConstants.systemConfig.Property_Backup_Scan_Range_Days__c)
                                : 7;

        Datetime scanDate = System.now().addDays(-scanDateRange);

        String scanDateString = scanDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        String propertySoql = GlobalUtility.getAllObjectFieldAPINames(GlobalConstants.PROPERTY_OBJECT_API);

        if (propertySoql != null){
            propertySoql += GlobalConstants.SPACE
                    + GlobalConstants.SOQL_CLAUSE_WHERE
                    + GlobalConstants.SPACE
                    + 'UUID__c'
                    + GlobalConstants.SPACE
                    + GlobalConstants.SPECIAL_CHAR_NOT_EQUAL_TO
                    + GlobalConstants.SPACE
                    + 'NULL'
                    + GlobalConstants.SPACE
                    + GlobalConstants.SOQL_CLAUSE_AND
                    + GlobalConstants.SPACE
                    + 'LastModifiedDate'
                    + GlobalConstants.SPACE
                    + GlobalConstants.SPECIAL_CHAR_GREATER_THAN
                    + GlobalConstants.SPACE
                    + scanDateString;

                    backupPropertyWrapper.properties = Database.query(propertySoql);
        }

        return backupPropertyWrapper;
    }

    //create http request and sent the request
    private static void sendBackupPostRequest(BackupPropertyWrapper backupPropertyWrapper) {
        if(backupPropertyWrapper.properties == null || backupPropertyWrapper.properties.size() == 0) return; 

        String requestBody = JSON.serialize(backupPropertyWrapper);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GlobalConstants.systemConfig.Property_Backup_Endpoint__c);
        request.setMethod(GlobalConstants.HTTP_POST_METHOD);
        request.setHeader(GlobalConstants.HTTP_CONTENT_TYPE, GlobalConstants.HTTP_CONTENT_TYPE_JSON_APP);
        request.setBody(requestBody);
        request.setTimeout(20000);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            System.debug('Backup Successfully');
        } else {
            System.debug('ERROR When Backup!');
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
        }
    }

    // public static void sendImportRequest() {
        
    // }


    //data structure to return 
    public class BackupPropertyWrapper {
        public List<Property__c> properties;
    }
}
