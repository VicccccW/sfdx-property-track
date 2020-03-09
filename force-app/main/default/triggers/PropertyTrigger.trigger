trigger PropertyTrigger on Property__c (before insert) {

	if(!GlobalUtility.isTriggerDisabled(String.valueOf(Property__c.sObjectType))){     
      //Property handler dispatches appropriate event
		  PropertyTriggerHandler.execute();  
    }
    
}