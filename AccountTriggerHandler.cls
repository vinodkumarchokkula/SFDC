public with sharing class AccountTriggerHandler {


    public static void onBeforeInsert(List<Account> lstAccountsNEW)
    {
	    set<string> setZips = new set<string>();
    	   
        for(Account iAccount : lstAccountsNEW)
        {
            if(iAccount.ShippingPostalCode != null){
            	setZips.add(iAccount.ShippingPostalCode);
            	system.debug('AImatt0 = ' + iAccount.ShippingPostalCode);
            }
        }

		list<ZipToLocation__c> lstZips = [Select id, name, Location__c from ZipToLocation__c where name in :setZips];
		Map<string,ZipToLocation__c> MapZips = new Map<string, ZipToLocation__c>();

        for(ZipToLocation__c iZip : lstZips)
        {
			MapZips.put(iZip.Name, iZip);
        }		
		

        for(Account iAccount : lstAccountsNEW)
        {
			iAccount.Location_from_Zip__c = label.location_default;
			system.debug('AImatt1');
			if(iAccount.ShippingPostalCode != null){
				system.debug('AImatt2');
				if(MapZips.get(iAccount.ShippingPostalCode)!=null){
					system.debug('AImatt3');
					iAccount.Location_from_Zip__c = MapZips.get(iAccount.ShippingPostalCode).Location__c;
				} 
			}
        }
    }
    
    
    public static void onBeforeUpdate(List<Account> lstAccountsNEW, List<Account> lstAccountsOLD, Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts)
    {
    	
    	set<string> setZips = new set<string>();
    	set<id> setAccountsToUpdate = new set<id>();
    	
        for(Account iAccount :lstAccountsNEW)
        {
            if(iAccount.ShippingPostalCode != oldAccounts.get(iAccount.id).ShippingPostalCode){
            	setZips.add(iAccount.ShippingPostalCode);
            	setAccountsToUpdate.add(iAccount.id);
            	system.debug('AUmatt0 = ' + iAccount.ShippingPostalCode);
            }
        }

		IF(setZips.size()>0){
			list<ZipToLocation__c> lstZips = [Select id, name, Location__c from ZipToLocation__c where name in :setZips];
			Map<string,ZipToLocation__c> MapZips = new Map<string, ZipToLocation__c>();
	
	        for(ZipToLocation__c iZip : lstZips)
	        {
				MapZips.put(iZip.Name, iZip);
	        }		
	
	        for(Account iAccount :lstAccountsNEW)
	        {	
	        	system.debug('AUmatt1');
	        	iAccount.Location_from_Zip__c = label.location_default;
	        	if(setAccountsToUpdate.contains(iAccount.id) && iAccount.ShippingPostalCode != null && MapZips.get(iAccount.ShippingPostalCode) != null){
					system.debug('AUmatt2');
					iAccount.Location_from_Zip__c = MapZips.get(iAccount.ShippingPostalCode).Location__c;
	        	}
	        }
		}

    
    
    }    
}