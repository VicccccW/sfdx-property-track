public with sharing class SystemConfigController {
    
    private List<SystemConfigField> systemConfigFields;
    
    public SystemConfigController() {
        buildSystemConfigFields();
    }

    private void buildSystemConfigFields() {
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_field_tokens.htm?search_text=getMap()
        //key(String) is the field names
        //value(Schema.SObjectField) is the field tokens
        //use the token for further process
        Map<String, Schema.SObjectField> fieldsMap = System_Config__c.sObjectType.getDescribe().fields.getMap();

        //get custom setting org default value first in advance
        System_Config__c orgDefaultSetting = System_Config__c.getOrgDefaults();
        
        systemConfigFields = new List<SystemConfigField>();

        for (String field : fieldsMap.keySet()) {
            //get one field token
            Schema.SObjectField fieldToken = fieldsMap.get(field);

            //get one field related info
            Schema.DescribeFieldResult fieldResult = fieldToken.getDescribe();
        
            SystemConfigField oneSysConfigField = new SystemConfigField();
           
            //use custom constructor to avoid 'Invalid constructor syntax, name=value pairs can only be used for SObjects' error
            systemConfigFields.add(new SystemConfigField(
                fieldResult.getName(), 
                fieldResult.getLabel(), 
                String.valueOf(orgDefaultSetting.get(fieldResult.getName()))
                ));
        }
    }

    public class SystemConfigField {
        String fieldName;
        String fieldLabel;
        String fieldValue;

        public SystemConfigField() {

        }
        
        //implement custom constructor
        public SystemConfigField(String fieldName, String fieldLabel, String fieldValue) {
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.fieldValue = fieldValue;
        }
    }
}
