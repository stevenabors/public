trigger AccountTrigger on Account (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert) {AccountTriggerHandler.createOpportunities(Trigger.NewMap);}
        
        if(Trigger.isUpdate) {AccountTriggerHandler.verifyOpportunities(Trigger.NewMap);}
    }   
}