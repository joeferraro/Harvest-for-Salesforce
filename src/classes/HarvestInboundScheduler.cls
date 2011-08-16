global class HarvestInboundScheduler {
    
    global void HarvestInboundScheduler() {  }
 
    public static void start() {
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String jobId = System.schedule('Harvest Inbound Sync', '0 0 1-23 * * ?', new HarvestInboundSync());
        Harvest__c settings = Harvest__c.getOrgDefaults(); 
        settings.CronTriggerId__c = jobId;
        upsert settings; 
    }
    
}