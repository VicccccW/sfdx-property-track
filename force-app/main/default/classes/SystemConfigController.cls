public with sharing class SystemConfigController {

    @AuraEnabled(cacheable=true)
    public static List<SystemConfigField> getSystemConfigFields() {
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_field_tokens.htm?search_text=getMap()
        //key(String) is the field names
        //value(Schema.SObjectField) is the field tokens
        //use the token for further process
        Map<String, Schema.SObjectField> fieldsMap = System_Config__c.sObjectType.getDescribe().fields.getMap();

        //get custom setting org default value first in advance
        System_Config__c orgDefaultSetting = System_Config__c.getOrgDefaults();
        
        List<SystemConfigField> systemConfigFields = new List<SystemConfigField>();

        for (String field : fieldsMap.keySet()) {
            //get one field token
            Schema.SObjectField fieldToken = fieldsMap.get(field);

            //get one field related info
            Schema.DescribeFieldResult fieldResult = fieldToken.getDescribe();
        
            SystemConfigField oneSysConfigField = new SystemConfigField();

            //use custom constructor to avoid 'Invalid constructor syntax, name=value pairs can only be used for SObjects' error
            SystemConfigField oneField = new SystemConfigField();
            oneField.name = fieldResult.getName();
            oneField.label = fieldResult.getLabel();
            oneField.value = orgDefaultSetting != null && String.valueOf(orgDefaultSetting.get(fieldResult.getName())) != null 
                           ? String.valueOf(orgDefaultSetting.get(fieldResult.getName()))
                           : '';
            oneField.isCustom = fieldResult.isCustom();
            systemConfigFields.add(oneField);
        }

        return systemConfigFields;
    }

    @AuraEnabled
    public static SystemConfigControllerResponse setSystemConfigFields(String newSysConfigStr) {
        
        //format should be '{"Id": "a02N000000JJJ8dIAH", "Property_Backup_Scan_Range_Days__c": "10"}'
        System.debug('Received newSysConfigStr is ' + newSysConfigStr);

        System_Config__c newValue = (System_Config__c)System.JSON.deserialize(newSysConfigStr, System_Config__c.class);

        Database.UpsertResult result = Database.upsert(newValue, System_Config__c.Id);

        if (result.isSuccess()) {
            System.debug('Success ');
            return new SystemConfigControllerResponse('Success', null);
        } else {
            List<String> errorMessages = new List<String>();

            for(Database.Error err : result.getErrors()) {
                errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
            }

            return new SystemConfigControllerResponse('Error', errorMessages);
        }
    }

    //in order for LWC to return custom defined apex, declare each property with @AuraEnabled
    public class SystemConfigField {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCustom;

        public SystemConfigField() {

        }
        
        //implement custom constructor
        public SystemConfigField(String name, String label, String value, Boolean isCustom) {
            this.name = name;
            this.label = label;
            this.value = value;
            this.isCustom = isCustom;
        }
    }

    public class SystemConfigControllerResponse {
        @AuraEnabled public String status;
        @AuraEnabled public List<String> messages;

        public SystemConfigControllerResponse(String status, List<String> messages) {
            this.status = status;
            this.messages = messages;
        }
    }
}
