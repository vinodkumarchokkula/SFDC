global class BatchCaseEmailReminder_Schedule implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      Id BatchCaseEmailReminder = Database.executeBatch(new BatchCaseEmailReminder(),1);
      
   }


}