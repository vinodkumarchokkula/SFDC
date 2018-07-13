/***************************************************************************
// Description    : Class that contains all of the functionality called by the 
//                  ContactTrigger. All contexts should be in this class.
//***************************************************************************/
 
public with sharing class ContactTriggerHandler {
 
	private boolean m_isExecuting = false;  
	private integer BatchSize = 0;

	//Constructor
	public ContactTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}  
 
  	//On Before insert trigger method
  	public void OnBeforeInsert(List<Contact> newList) {   
		//Whatever method should be called here...
  	}
 
	// On Before update trigger method
	public void OnBeforeUpdate (Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {    
		//Whatever method should be called here...
	}

	// On Before update trigger method
	public void OnBeforeDelete (Map<Id, Contact> oldMap) {
		//Whatever method should be called here...
	}  

	//On after insert trigger method
	public void OnAfterInsert(Map<Id, Contact> newMap) {   
		CreatePersonAccountFromHubspotContact(newMap.values());
	}  

	// On after update trigger method
	public void OnAfterUpdate (Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {    
		//Whatever method should be called here...  
	}

	// On after update trigger method
	public void OnAfterDelete (Map<Id, Contact> oldMap) {    
		//Whatever method should be called here...  
	}  
 

	private void CreatePersonAccountFromHubspotContact(List<Contact> newList) {

		if (UserInfo.getUserName().startsWithIgnoreCase('jeff@') || UserInfo.getUserName().startsWithIgnoreCase('admin@') || UserInfo.getUserName().startsWithIgnoreCase('api@')) {

			//Get the data first
			List<RecordType> rtList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount'];

			if (rtList.isEmpty()) return;	//Then the record type isn't found, nothing to do.

			Id personAccountRT = rtList[0].Id;

			List<Account> personAccountsToInsert = new List<Account>();
			Set<Id> contactIdSetToKill = new Set<Id>();

			for (Contact c : newList) {

				//Why are these fields no longer visible???	
				//if (c.HubSpot_Inc__HubSpot_Intelligence__c != null) {

					//Then process it...
					Account newPersonAccount = new Account();
					newPersonAccount.RecordTypeId = personAccountRT;
					newPersonAccount.FirstName = c.FirstName;
					newPersonAccount.LastName = c.LastName;
					newPersonAccount.PersonBirthdate = c.Birthdate;

					//Why are these fields no longer visible???
					//newPersonAccount.HubSpot_Inc__HubSpot_Intelligence__pc = c.HubSpot_Inc__HubSpot_Intelligence__c;
					//newPersonAccount.HubSpot_Inc__SICCode__pc = c.HubSpot_Inc__SICCode__c;
					//Why are these fields no longer visible???

					newPersonAccount.PersonTitle = c.Title;
					newPersonAccount.Phone = c.Phone;
					newPersonAccount.PersonMobilePhone = c.MobilePhone;
					newPersonAccount.Fax = c.Fax;
					newPersonAccount.Type = 'Prospect';
					newPersonAccount.PersonEmail = c.Email;
					newPersonAccount.PersonMailingStreet = c.MailingStreet;
					newPersonAccount.PersonMailingCity = c.MailingCity;
					newPersonAccount.PersonMailingState = c.MailingState;
					newPersonAccount.PersonMailingPostalCode = c.MailingPostalCode;
					newPersonAccount.PersonMailingCountry = c.MailingCountry;
					newPersonAccount.PersonHasOptedOutOfEmail = c.HasOptedOutOfEmail;
					newPersonAccount.OwnerId = c.OwnerId;

					contactIdSetToKill.add(c.Id);

					//flag the contact for deletion now...
					personAccountsToInsert.add(newPersonAccount);				
				//}
			}

			if (!personAccountsToInsert.isEmpty()) insert personAccountsToInsert;

			if (!contactIdSetToKill.isEmpty()) PurgeContacts(contactIdSetToKill);
		}
	}

	@future
	private static void PurgeContacts(Set<Id> contactIdSet) {

		List<Contact> contactListToPurge = [SELECT Id FROM Contact WHERE Id IN :contactIdSet];

		if (!contactListToPurge.isEmpty()) delete contactListToPurge;

	}

} // End of ContactTriggerHandler class