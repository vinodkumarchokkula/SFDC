global class BatchBirthdayEmail implements Database.Batchable<sObject> {

    public String query;
    
    global BatchBirthdayEmail() {
        
        this.query = 'SELECT Birthdate, Email, Id, HasOptedOutOfEmail, Merge_Letter__c, Ready_for_Letter__c, MailingPostalCode, Ready_for_Letter_Date__c, AccountId FROM Contact WHERE Birthdate = TODAY AND Account.Type = \'Customer\'';

    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {

    	EmailUtility.ProcessBirthdayEmails(scope);

    }

    global void finish(Database.BatchableContext BC) {

    	//Nothing necessary on finish at this time...

    }
}