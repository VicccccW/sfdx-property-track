public with sharing class GlobalUtility {
    public GlobalUtility() {

    }

    public static String getAllObjectFieldAPINames (String ObjectAPI) {
        String querySOQL;
        Schema.DescribeSObjectResult schemaRes = Schema.getGlobalDescribe().get(ObjectAPI).getDescribe();
        
        List<String> apiNames =  new List<String>();
        
        for(String apiName : schemaRes.fields.getMap().keySet()){
            DescribeFieldResult describeFieldResult = schemaRes.fields.getMap().get(apiName).getDescribe();
            
            if (describeFieldResult.isAccessible() && describeFieldResult.getType() != Schema.DisplayType.LOCATION) {
                apiNames.add(apiName);
			}
        }

        if (apiNames.size() > 0){
            String outputString = String.join(apiNames, ',');
            querySOQL = 'SELECT ' + outputString + ' FROM ' + ObjectAPI;
        }
        
        return querySOQL;
    }

    public static Boolean isTriggerDisabled(String objType){
        Boolean isDisabled = false;

        if(String.isNotBlank(objType)){
            System_Switch__c custSettings = GlobalConstants.systemSwitch;
            
            if(custSettings != null){
                String objsDisabled = custSettings.ObjectTriggersToBeDisabled__c != null 
                                    ? custSettings.ObjectTriggersToBeDisabled__c.trim() 
                                    : null ;

                if(String.isNotBlank(objsDisabled)){
                    Set<String> objSet = new Set<String>();
                    objSet.addAll(trimStringList(objsDisabled.split(GlobalConstants.COMMA)));

                    System.debug('** objSet ==>'+objSet);

                    if(objSet.contains(objType) && custSettings.DisableTriggers__c){
                        isDisabled = true;
                    }
                }
            }
        }
        
        System.debug('** Triggers Disabled ==>'+isDisabled);

        return isDisabled;
    }

    /**
      * @description       This method is used to trim content of list
      * @param             strList - List<String> 
      * @return            Void
      * @throws            NA
    */
    public static List<String> trimStringList(List<String> strList){
        List<String> retList = new List<String>();
        
        for(String str : strList){
            retList.add(str.trim());
        }

        System.debug('** retList ==>'+retList);
        
        return retList;
    }

    /**
     * hack method to get sessionId to use in LWC call SF API
     */
    public static String getSessionIdFromVFPage(PageReference visualforcePage){
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }
}
