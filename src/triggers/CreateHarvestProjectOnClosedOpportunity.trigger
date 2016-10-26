trigger CreateHarvestProjectOnClosedOpportunity on Opportunity (after insert, after update) {
    
    if (trigger.size > 1) return;
    
    Harvest__c settings = Harvest__c.getInstance();
    if (settings.Create_Harvest_Project_Automatically__c == false) return;
    
    Set<Id> accountIds = new Set<Id>();
    
    for (Opportunity o : trigger.new) {
        if (o.AccountId == null) continue;
                
        accountIds.add(o.AccountId);
    }
    
    Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, Harvest_Id__c from Account where Id in :accountIds]);
    
    for (Opportunity o : trigger.new) {
        if (o.AccountId == null) continue;
		
		if (accountMap.get(o.AccountId).Harvest_Id__c == null) continue;
		
        if (trigger.isInsert) {
            if (o.IsWon == true) {
                Harvest_Project__c hp = new Harvest_Project__c();
                hp.Account__c = o.AccountId;
                hp.Opportunity__c = o.Id;
                hp.Name = o.Name;
                insert hp;
            }
        } else if (trigger.isUpdate) {
            if (trigger.oldmap.get(o.id).IsWon == false && trigger.newmap.get(o.id).IsWon == true) {
                Harvest_Project__c hp = new Harvest_Project__c();
                hp.Account__c = o.AccountId;
                hp.Opportunity__c = o.Id;
                hp.Name = o.Name;
                insert hp;
            }
        }   
    }
}