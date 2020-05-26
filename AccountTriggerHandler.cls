public class AccountTriggerHandler {
    
    public static void createOpportunities(Map<Id,Account> acctsMap) {
        List<Opportunity> newOppsList = new List<Opportunity>(); // New List of opportunities to be created
        for (Id key : acctsMap.keyset()) {
            newOppsList.add(createOpportunity(key, 'Default Residential Opp'));
            newOppsList.add(createOpportunity(key, 'Default Commercial Opp'));
        }
        if (newOppsList.size()>0) {
            insert newOppsList;
        }
    }
    
    public static void verifyOpportunities(Map<Id,Account> acctsMap) {
        Map<Id, Account> verAcctsMap = new Map<Id, Account>
            ([SELECT Id, Name, OwnerId, Owner.Email, (SELECT Name FROM Opportunities WHERE Name='Default Residential Opp' OR Name='Default Commercial Opp')
              FROM Account WHERE Id IN :acctsMap.keySet() AND Type='Prospect']); // New Map of Accounts to Verify Opportunities
        if (verAcctsMap.size()>0) {
            List<Opportunity> newOppsList=new List<Opportunity>(); // New List of opportunities to be created if needed
            for (Id key : verAcctsMap.keySet()) {            
                if (verAcctsMap.get(key).Opportunities.size()<2) {
                    if (verAcctsMap.get(key).Opportunities.size() == 1) {
                        if (verAcctsMap.get(key).Opportunities[0].Name == 'Default Residential Opp') {
                            newOppsList.add(createOpportunity(key, 'Default Commercial Opp'));
                        }
                        if (verAcctsMap.get(key).Opportunities[0].Name == 'Default Commercial Opp') {
                            newOppsList.add(createOpportunity(key, 'Default Residential Opp'));
                        }
                    }else{
                        newOppsList.add(createOpportunity(key, 'Default Residential Opp'));
                        newOppsList.add(createOpportunity(key, 'Default Commercial Opp'));
                    }
                }else{
                    verAcctsMap.remove(key); // Remove Map Entry if both Opportunities are present (for email handling)
                }
            }
            if (newOppsList.size()>0) {
                insert newOppsList;
                sendEmail(verAcctsMap); // Sends Accounts that needed Opportunities Created
            }
        }
    } 
    
    private static Opportunity createOpportunity(Id accId, String name) {
        Opportunity opp=new Opportunity();
        opp.AccountId=accId;
        opp.Name=name;
        opp.StageName='Prospecting';
        opp.CloseDate=Date.toDay();
        return opp;
    }
    
    private static void sendEmail(Map<Id,Account> verAcctsMap) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); // List of individual emails
        for (Account a : verAcctsMap.values()) { 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{a.Owner.Email});
            email.setTargetObjectId(a.OwnerId);
            email.setSaveAsActivity(false); 
            email.setSubject('Opportunities for Account '+ a.Name + ' Have been altered or deleted');
            email.setHtmlBody('<div>Please use below link to go to the Account:</div>'+
                              '<div><a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+a.id+'>'+a.Name+'</a><div>');
            emailList.add(email);
        }
        Messaging.sendEmail(emailList);     
    }
}
