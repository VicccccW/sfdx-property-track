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

    public void publishPlatformEvent(List<Property__c> properties) {

        // List<SF_Property_Event__e> events = new List<SF_Property_Event__e>();
        SF_Property_Event__e event = new SF_Property_Event__e(
            Number_Of_Records__c = properties.size()
        );

        if(Trigger.isInsert) {
            event.Event_Type__c = 'INSERTED';
        } else if(Trigger.isUpdate) {
            event.Event_Type__c = 'UPDATED';
        } else if(Trigger.isDelete) {
            event.Event_Type__c = 'DELETED';
        } else if(Trigger.isUndelete) {
            event.Event_Type__c = 'UNDELETED';
        }

        Database.SaveResult sr = EventBus.publish(event);
        
        // Inspect publishing result 
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }
    }
}
