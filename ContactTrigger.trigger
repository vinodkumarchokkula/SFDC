/*******************************************************************
// Trigger that *should be* invoked for all contexts that
// delegates control to AccountTriggerHandler. 
********************************************************************/
trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete) {
 
    ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
 
    if (Trigger.isInsert && Trigger.isBefore) {
        //Handler for before insert
        handler.OnBeforeInsert(Trigger.new);     
    } 
    else if (Trigger.isUpdate && Trigger.isBefore) {    
        //Handler for before update trigger
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    } 
    else if (Trigger.isDelete && Trigger.isBefore) {     
        //Handler for before Delete trigger
        handler.OnBeforeDelete(Trigger.oldMap);
    } 
    else if (Trigger.isInsert && Trigger.isAfter) {
        //Handler for after insert
        handler.OnAfterInsert(Trigger.newMap);
    } 
    else if (Trigger.isUpdate && Trigger.isAfter) {   
        //Handler for after update trigger
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);    
    } 
    else if (Trigger.isDelete && Trigger.isAfter) {     
        //Handler for After Delete trigger
        handler.OnAfterDelete(Trigger.oldMap);    
    }
}