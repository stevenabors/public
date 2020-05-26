@isTest
public class AccountTriggerHandlerTest {
    private static List<Account> acclist = new List<Account>([Select Id From Account]);
    
    @testSetup static void Setup() {
        List<Account> acclist = new List<Account>();
        // Create non-Prospect Account
        account a = new Account(Name = 'Test Account 1', Type = 'Other');
        acclist.add(a);
        // Create Prospect Account
        a = new Account(Name = 'Test Account 2', Type = 'Prospect');
            acclist.add(a);
        insert acclist;
    }
    
    @isTest static void testGovernorLimits() {
        for(integer i=0; i<101; i++){
            Account a = new Account(Name = 'Test Account'+i,
                                    Type = 'Prospect');
            acclist.add(a);
        }
        upsert acclist;
    }
    
    @isTest static void testInsertAccts() {
        // Verify 2 opps were created for each Account
        system.assertEquals(4, [Select count() from Opportunity], 'Too Many or No Opportunities created');
    }
    
    @isTest static void testUpdateAllAccts() {
        // Update accounts and verify there are still only 2 Spps per account
        update acclist; 
        system.assertEquals(4, [Select count() from Opportunity], 'Extra Opportunities Created on Update');
    }
    
    @isTest static void testDeleteAllOpps(){
        // Delete All opportunies
        Delete [Select Id from Opportunity];
        // Update each account and verify 2 Opps were recreated for Prospect Account Only.
        update acclist;
        system.assertEquals(2, [Select count() from Opportunity], 'Too Many or No Opportunities created');
    }
    
    @isTest static void testDeleteOneOpp(){
        // Delete Opps of certain Type and Verify they were recreated on Update
        Delete [Select Id from Opportunity Where Name='Default Residential Opp'];
        update acclist;
        system.assertEquals(1, [Select count() from Opportunity Where Name='Default Residential Opp'],
                            'Too Many or No Opportunities created');
        Delete [Select Id from Opportunity Where Name='Default Commercial Opp'];
        update acclist;
        system.assertEquals(1, [Select count() from Opportunity Where Name='Default Commercial Opp'],
                            'Too Many or No Opportunities created');
    }
}