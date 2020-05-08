public with sharing class PropertyTriggerHandler{
    
    private static PropertyTriggerHelper helper;
    
    public static void execute() {
        
        helper = new PropertyTriggerHelper();
        
        // Check for event type of trigger
        if (Trigger.isBefore) {
            beforeHandler();        // invoke of before handler
        } else if (Trigger.isAfter) {
            afterHandler();
        }
    }

    private static void beforeHandler() {
        //Logic to fire in 'before' context 
        if (Trigger.isInsert) {
            helper.generateUuid(Trigger.new);
            helper.formatPropertyName(Trigger.new);
        } 
        
        if (Trigger.isUpdate) {
            helper.formatPropertyName(Trigger.new);
        }
    }

    private static void afterHandler() {
        if (Trigger.isInsert) {
            helper.publishPlatformEvent(Trigger.new);
        }

        if (Trigger.isUpdate) {
            helper.publishPlatformEvent(Trigger.new);
        }

        if (Trigger.isDelete) {
            helper.publishPlatformEvent(Trigger.old);
        }

        if (Trigger.isUndelete) {
            helper.publishPlatformEvent(Trigger.new);
        }
    }
}