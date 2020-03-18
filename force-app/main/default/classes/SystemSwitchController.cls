public class SystemSwitchController {

    @AuraEnabled(cacheable=true)
    public static List<SystemSwitchField> getSystemSwitchFields() {
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_field_tokens.htm?search_text=getMap()
        //key(String) is the field names
        //value(Schema.SObjectField) is the field tokens
        //use the token for further process
        Map<String, Schema.SObjectField> fieldsMap = System_Switch__c.sObjectType.getDescribe().fields.getMap();

        //get custom setting org default value first in advance
        System_Switch__c orgDefaultSetting = System_Switch__c.getOrgDefaults();
        
        List<SystemSwitchField> systemSwitchFields = new List<SystemSwitchField>();

        for (String field : fieldsMap.keySet()) {
            //get one field token
            Schema.SObjectField fieldToken = fieldsMap.get(field);

            //get one field related info
            Schema.DescribeFieldResult fieldResult = fieldToken.getDescribe();

            SystemSwitchField oneSysSwitchField = new SystemSwitchField();

            //use custom constructor to avoid 'Invalid constructor syntax, name=value pairs can only be used for SObjects' error
            SystemSwitchField oneField = new SystemSwitchField();
            oneField.name = fieldResult.getName();
            oneField.label = fieldResult.getLabel();
            oneField.value = orgDefaultSetting != null && String.valueOf(orgDefaultSetting.get(fieldResult.getName())) != null 
                           ? String.valueOf(orgDefaultSetting.get(fieldResult.getName()))
                           : '';
            oneField.isCustom = fieldResult.isCustom();
            oneField.soapType = String.valueOf(fieldResult.getSoapType());
            systemSwitchFields.add(oneField);
        }
        
        return systemSwitchFields;
    }

    @AuraEnabled
    public static SystemSwitchControllerResponse setSystemSwitchFields(String newSysSwitchStr) {
        
        //format should be '{"Id": "a02N000000JJJ8dIAH", "xxx": "10"}'
        System.debug('Received newSysSwitchStr is ' + newSysSwitchStr);

        System_Switch__c newValue = (System_Switch__c)System.JSON.deserialize(newSysSwitchStr, System_Switch__c.class);

        Database.UpsertResult result = Database.upsert(newValue, System_Switch__c.Id);

        if (result.isSuccess()) {
            System.debug('Success ');
            return new SystemSwitchControllerResponse('Success', null);
        } else {
            List<String> errorMessages = new List<String>();

            for(Database.Error err : result.getErrors()) {
                errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
            }

            return new SystemSwitchControllerResponse('Error', errorMessages);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getOrgDefaultMapMarkerRedirect() {
        if (System_Switch__c.getOrgDefaults().Enable_Map_Marker_Select_Redirect__c) {
            return true;
        }

        return false;
    }

    //in order for LWC to return custom defined apex, declare each property with @AuraEnabled
    public class SystemSwitchField {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public String soapType;

        public SystemSwitchField() {

        }
        
        //implement custom constructor
        public SystemSwitchField(String name, String label, String value, Boolean isCustom, String soapType) {
            this.name = name;
            this.label = label;
            this.value = value;
            this.isCustom = isCustom;
            this.soapType = soapType;
        }
    }

    public class SystemSwitchControllerResponse {
        @AuraEnabled public String status;
        @AuraEnabled public List<String> messages;

        public SystemSwitchControllerResponse(String status, List<String> messages) {
            this.status = status;
            this.messages = messages;
        }
    }
}