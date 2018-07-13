trigger VehicleCreateOnLead on Lead (after insert, after update) {
	
	List<Lead> NewLeads = [select Vehicle_Name__c,Vehicle_URL__c,Vehicle_Location__c,Stock__c,pi__comments__c,pi__conversion_date__c,Rental_Date__c,Rental_Request_Information__c from Lead where id=:trigger.new];
    
    List<Lead> leadsToUpdate = new List<Lead>();
    List<vehicle__c> vehiclesToInsert = new List<vehicle__c>();
    
    for(Lead l: NewLeads)
		{
			if(l.Vehicle_Name__c!=null || l.Vehicle_URL__c !=null || l.Vehicle_Location__c !=null || l.Stock__c !=null || l.pi__comments__c !=null || l.pi__conversion_date__c !=null || l.Rental_Date__c !=null || l.Rental_Request_Information__c != null)
			{
				vehicle__c vh = new vehicle__c();
			
					vh.Vehicle_Name__c = l.Vehicle_Name__c;
					vh.Vehicle_URL__c = l.Vehicle_URL__c;
					vh.Vehicle_Location__c =l.Vehicle_Location__c;
					vh.Stock__c = l.stock__c;
					vh.Comments__c = l.pi__comments__c;
					vh.conversion_date__c = l.pi__conversion_date__c;
					vh.Rental_Date__c = l.Rental_Date__c;
					vh.Rental_Request_Information__c = l.Rental_Request_Information__c;
			 	vehiclesToInsert.add(vh);
			
			
					l.Vehicle_Name__c = null;
					l.Vehicle_URL__c = null;
					l.Vehicle_Location__c = null;
					l.Stock__c = null;
					l.pi__comments__c = null;
					l.pi__conversion_date__c = null;
					l.Rental_Date__c = null;
					l.Rental_Request_Information__c = null;
			
				leadsToUpdate.add(l);
			
			}
			
		}    
		
		if(vehiclesToInsert.size()>0){
			insert vehiclesToInsert;
			}
			
		if(leadsToUpdate.size()>0){
			update leadsToUpdate;
			}
}