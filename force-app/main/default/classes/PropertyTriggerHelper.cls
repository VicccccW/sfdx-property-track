public with sharing class PropertyTriggerHelper {
    public PropertyTriggerHelper() {

    }

    public void generateUuid(List<Property__c> newProperties) {
        for(Property__c property : newProperties) {
            if (String.isBlank(property.UUID__c)) {
                Uuid newUuid = new Uuid();
                property.Uuid__c = newUuid.getValue();
            }
        }
    }

    public void formatPropertyName(List<Property__c> newProperties) {
        for(Property__c property : newProperties) {
            if(property.Street__c != null && property.Suburb__c != null) {
                property.Name__c = property.Street__c + ', ' + property.Suburb__c;
            }
        }
    }
}
