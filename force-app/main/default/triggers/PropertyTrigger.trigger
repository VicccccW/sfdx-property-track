trigger PropertyTrigger on Property__c (before insert
                                        , before update
                                        , before delete
                                        , after insert
                                        , after update
                                        , after delete
                                        , after undelete) {

	if (!GlobalUtility.isTriggerDisabled(String.valueOf(Property__c.sObjectType))){     
      //Property handler dispatches appropriate event
		  PropertyTriggerHandler.execute();  
    }
    
}