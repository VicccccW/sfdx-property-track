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

    @AuraEnabled
    public static PropertyControllerResponse sendImportRequest() {

        PropertyControllerResponse importResponse = new PropertyControllerResponse();    

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GlobalConstants.systemConfig.Property_Import_Endpoint__c);
        request.setMethod(GlobalConstants.HTTP_GET_METHOD);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<PropertyWrapper> results = (List<PropertyWrapper>)JSON.deserialize(response.getBody(), List<PropertyWrapper>.Class);
            System.enqueueJob(new Queueable_UpsertImportProperty(results));

            importResponse.status = '200';
            importResponse.messages.add('Import Property Data Successfully.');
        } else if (response.getStatusCode() == 404) {
            importResponse.status = '404';
            importResponse.messages.add('Incorrect endpoint!');
        } else {
            importResponse.status = '400';
            importResponse.messages.add('Unknown error when import property data.');
        }
        
        return importResponse;
    }

    public static void insertProperty(List<PropertyWrapper> data) {
        if (data == null || data.size() == 0) return;
            
        List<Property__c> properties = new List<Property__c>();

        for(PropertyWrapper oneData : data) {
            Property__c property = new Property__c(
                City__c = oneData.city,
                Country__c = oneData.country,
                CountryCode__c = oneData.countryCode,
                Est_Max_Price__c = Decimal.valueOf(oneData.estMaxPrice),
                Est_Min_Price__c = Decimal.valueOf(oneData.estMinPrice),
                Geolocation__Latitude__s = Decimal.valueOf(oneData.latitude),
                Geolocation__Longitude__s = Decimal.valueOf(oneData.longitude),
                Has_Sold__c = oneData.hasSold,
                Land_Size__c = oneData.landSize,
                Main_Image_URL__c = oneData.mainImageUrl,
                Name__c = oneData.name,
                No_of_Bathrooms__c = oneData.noOfBathrooms,
                No_of_Rooms__c = oneData.noOfRooms,
                Postalcode__c = oneData.postalcode,
                Sold_Price__c = oneData.soldPrice,
                State__c = oneData.state,
                Street__c = oneData.street,
                Suburb__c = oneData.suburb,
                Uuid__c = oneData.uuid
            );

            properties.add(property);
        }

        Schema.SObjectField uuid = Property__c.Uuid__c;
        Database.UpsertResult[] upsertResult = Database.upsert(properties, uuid, false); 

        for (Database.UpsertResult result : upsertResult) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    System.debug('Error: '+ err.getStatusCode() + ' ' + err.getMessage());
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Property__c> getMapPropertyList() {
        return [SELECT Id
                        , Est_Max_Price__c
                        , Est_Min_Price__c
                        , Land_Size__c
                        , No_of_Rooms__c
                        , No_of_Bathrooms__c
                        , Name__c
                        , Postalcode__c
                        , Street__c
                        , City__c
                        , Suburb__c
                        , Country__c
                        , CountryCode__c
                        , Geolocation__Latitude__s
                        , Geolocation__Longitude__s 
                FROM Property__c
                ORDER BY LastModifiedDate DESC 
                LIMIT 100];
    }

    //data structure to return 
    public class BackupPropertyWrapper {
        public List<Property__c> properties;
    }

    public class PropertyControllerResponse {
        @AuraEnabled public String status;
        @AuraEnabled public List<String> messages;

        public PropertyControllerResponse() {
            this.messages = new List<String>();
        }
    }
}
