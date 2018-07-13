/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class EmailListener implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        if (email.binaryAttachments != null && email.binaryAttachments.size() == 1){
        		Messaging.InboundEmail.BinaryAttachment ib= email.binaryAttachments[0];
        		system.debug('!!!!!!'+ib);
            	Blob csvBlob = ib.Body;
            	String s= EncodingUtil.base64Encode(csvBlob);
            	 system.debug(s);
            	String str = EncodingUtil.base64Decode(s).toString();
            	system.debug(str);
            	
                system.debug(csvBlob);
        		system.debug('!!!!!!'+EncodingUtil.base64Encode(ib.Body));
        		system.debug('!!!!!!&&&'+EncodingUtil.base64Encode(csvBlob));
        		
        		Map<id,account> accountsMap = new Map<id,account>([select id,name,Site_UCN__c from account]);
        		Integer intStringEndIndex = str.indexOf('\n',0);
        		Integer nextStringStartIndex = intStringEndIndex+1;
        		Integer nextStringEndIndex = str.indexOf('\n',nextStringStartIndex);
        		
        		Map<id,Set<Contact>> videoContacts = new Map<id,Set<Contact>>();
        		List<Contact> emailContact = new List<Contact>();
        		List<Account> emailAccount = new List<Account>();
        		List<String> emailAccountString = new List<String>();
        		For(contact c:[select id,firstname,lastname,accountid,email from contact where accountid=:accountsMap.keySet() and Video_Contact__c=true]){
        		
        		if(videoContacts.containsKey(c.accountid)){
        			Set<Contact> conSet = videoContacts.get(c.accountid);
        			conSet.add(c);
        			videoContacts.put(c.accountid,conSet);
        		}
        		else if(videoContacts.containsKey(c.accountid)){
        			Set<Contact> conSet = new Set<Contact>();
        		 	conSet.add(c);
        		 	videoContacts.put(c.accountid,conSet);
        		}
        		
        		
        		}
        		
        		List<Account> accountsToInsert = new List<Account>();
        		while(nextStringStartIndex>0){
        			string row=str.substring(nextStringStartIndex,nextStringEndIndex);
        			system.debug('***'+ row);
        			Boolean alreadyExists=false;
        			if(row.length()>0){
        				String[] rowvals = row.split(',');
        				for(account acc:accountsMap.values()){
        					if(acc.Site_UCN__c == rowvals[13]){
        					 alreadyExists = true;
        					 //Check if it has a video Contact, send an email
        					 Set<Contact>emailRecepientContacts = videoContacts.get(acc.id);
        					 	if(emailRecepientContacts!=null || !emailRecepientContacts.isEmpty()){
        					 	for(Contact ct:emailRecepientContacts)
        					 		{
        					 			emailContact.add(ct);
        					 		}
        					 	}	
        					 	
        					 	else{
        					 	// Email to kaleigh to acquire video contact
        					 		emailAccount.add(acc);
        					 		emailAccountString.add(acc.id);
        					 	
        					 	}
        					}
        				}
        				if(!alreadyExists){
        					Account a = new Account();
        					a.name=rowvals[0];
        					a.Site_UCN__c = rowvals[13];
        					
        					accountsToInsert.add(a);
        					system.debug('insert account'+a);
        					// Email to kaleigh to acquire  video contact
        					emailAccount.add(a);
        				
        				}
        			}
        			nextStringStartIndex = nextStringEndIndex+1;
        			if(nextStringStartIndex>str.length()) break;
        			nextStringEndIndex = str.indexOf('\n',nextStringStartIndex);
        			if(nextStringEndIndex == -1) {
        				nextStringEndIndex = str.length();
        				}
        			
        		}
        		
        		insert accountsToInsert;
        		
        		
        	
        		for(contact cont:emailContact){
        			if(cont.email!=null){
        					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        					List<String> emailList= new List<String>();
        					emailList.add(cont.email);
      						mail.setToAddresses(emailList);
      						mail.setTemplateId('00X1F000000T8kL');
      						mail.setTargetObjectId(cont.id);
      						Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        			}
        			
        		}
        		
        		if(emailAccount.size()>0){
        				
      						
      						
      						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        					mail.setReplyTo('vchok@Sagamore.com');
      						mail.setSenderDisplayName('Sagamore Sales');
							List<String> emailList= new List<String>();
							emailList.add('vinod.chokkula@nuvemconsulting.com');
      						mail.setToAddresses(emailList);
      						mail.setSubject('Acquire - Video Contact');
      						mail.setHTMLbody('Please acquire video contacts for the following accounts'+ emailAccountString);
      						
      						Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        		}
        	}
        
        
       
        return result;
    }
}