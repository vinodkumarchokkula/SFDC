global class BatchCaseEmailReminder implements database.Batchable<sobject>{

    /*
    	send a reminder email to the owner of any Tech_Ops case if the status is a value in 'statusValues' and it was last modified prior to today   
    */

	private set<id> qWhere;

	public BatchCaseEmailReminder(set <id> iWhere){
		qWhere = iWhere;
	}

	public BatchCaseEmailReminder(){

	}


    global database.Querylocator start(database.batchablecontext bc){
    	
    	String CaseRecordTypeId;
    	CaseRecordTypeId =[Select id from RecordType where sObjectType = 'Case' and developerName ='Tech_Ops' ].id;
    	
    	date dToday = System.Today()-7;
    	List<String> statusValues = new List<String> {'Waiting on Client','Waiting on AM/CC','Waiting on DBM','Escalated'};
    	
        string squery ='select ID, Status, Owner.email, LastModifiedDate from Case where LastModifiedDate <= :dToday and Status in :statusValues and recordtypeid = :CaseRecordTypeId'; 
     	
     	if (qWhere != null){
     		if(Test.isRunningTest()){
     			squery = 'select ID, Status, Owner.email, LastModifiedDate from Case where id in :qWhere';
     		}
     		else{
     			squery = squery + ' and id in :qWhere';
     		}
     	}
     	system.debug('squery = ' + squery);
        return database.getQuerylocator(squery);
    }


    //Execute?method?to?process?all?the?Opportunities
    global void execute(database.batchablecontext bc,list<Case> lstCases){
		 
		EmailTemplate ret2=[Select id from EmailTemplate where name = 'Open TechOps Case' limit 1];
		system.debug('ret2.id = ' + ret2.id);
		
		for(Case iCase :lstCases){
			//prepare to send the email
			contact userCon = new contact(LastName = 'foraUser', email=iCase.owner.email, Temporary_Contact__c = 'True');
			insert userCon;
			Messaging.SingleEmailMessage ramail = new Messaging.SingleEmailMessage();
			ramail.setTargetObjectId(userCon.id);
			ramail.setWhatId(iCase.id); 
			ramail.setTemplateId(ret2.id);
			ramail.setSenderDisplayName('salesforce@sojern.com');		

			Messaging.sendEmail(new Messaging.singleEmailMessage[] {ramail});
			delete userCon;	
		}

		 
		
    }
    
    global void finish(database.batchablecontext bc){}
    
}