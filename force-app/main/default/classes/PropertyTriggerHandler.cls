public with sharing class PropertyTriggerHandler{
    
    private static PropertyTriggerHelper helper;
    
    public static void execute() {
        
        helper = new PropertyTriggerHelper();
        
        // Check for event type of trigger
        if (Trigger.isBefore) {
            beforeHandler();        // invoke of before handler
        }
    }

    private static void beforeHandler() {
        //Logic to fire in 'before' context 
        if (Trigger.isInsert) {
            helper.generateUuid(Trigger.new);
        }
    }
}