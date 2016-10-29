/*
global class HarvestProjectSync {
    
    webService static String refreshProject(String projectId) {     
        Harvest h = new Harvest();
        HarvestProject p = h.getProject(projectId);
                
        Harvest_Project__c hp = [Select Id, Harvest_Id__c, Account__c, Account__r.Harvest_Id__c from Harvest_Project__c where Harvest_Id__c = :projectId];
        Map<String, Id> accountMap = new Map<String, Id> { hp.Account__r.Harvest_Id__c => hp.Account__c };
        Map<String, Id> projectMap = new Map<String, Id> { hp.Harvest_Id__c => hp.Id };

        hp = HarvestUtil.transformProject(p, accountMap);           
        upsert hp Harvest_Id__c; 
        return null;
    }
}
*/
 
global class HarvestProjectSync {
	
	webService static String refreshProject(String projectId) {		
		Harvest h = new Harvest();
		/*DO CALLOUTS*/
		HarvestProject p = h.getProject(projectId); 
		List<HarvestTaskAssignment> hTaskAssignments = h.getTaskAssignments(projectId);
		List<HarvestUserAssignment> hUserAssignments = h.getUserAssignments(projectId);
		List<HarvestTImeEntry> hTimeEntries = h.getTimeEntriesForProject(projectId, Date.today().addDays(-31), Date.today());
		
		/*PROCESS PROJECT*/
		Harvest_Project__c hp = [Select Id, Harvest_Id__c, Account__c, Account__r.Harvest_Id__c from Harvest_Project__c where Harvest_Id__c = :projectId];
		Map<String, Id> accountMap = new Map<String, Id> { hp.Account__r.Harvest_Id__c => hp.Account__c };
		Map<String, Id> projectMap = new Map<String, Id> { hp.Harvest_Id__c => hp.Id };

		hp = HarvestUtil.transformProject(p, accountMap);
		
		/*PROCESS TASK ASSIGNMENTS*/
		Map<String, Id> taskMap = new Map<String, Id>();
		Set<String> taskIds = new Set<String>();
		List<Harvest_Task_Assignment__c> taskAssignments = new List<Harvest_Task_Assignment__c>();
		
		for (HarvestTaskAssignment ta : hTaskAssignments) {
			taskIds.add(ta.taskId);
		}
		
		for (Harvest_Task__c t : [Select Id, Harvest_Id__c from Harvest_Task__c where Harvest_Id__c in :taskIds]) {
			taskMap.put(t.Harvest_Id__c, t.Id);
		}

		for (HarvestTaskAssignment ta : hTaskAssignments){
			taskAssignments.add(HarvestUtil.transformTaskAssignment(ta, projectMap, taskMap));
		}
		/*PROCESS USER ASSIGNMENTS*/
		Map<String, Id> userMap = new Map<String, Id>();
		Set<String> userIds = new Set<String>();
		List<Harvest_User_Assignment__c> userAssignments = new List<Harvest_User_Assignment__c>();

		for (HarvestUserAssignment ua : hUserAssignments) {
			userIds.add(ua.userId);
		}

		for (HarvestTImeEntry ht : hTimeEntries) {
			userIds.add(ht.userId);
		}
		
		for (Harvest_User__c u : [Select Id, Harvest_Id__c from Harvest_User__c where Harvest_Id__c in :userIds]){
			userMap.put(u.Harvest_Id__c, u.Id);
		}

		for (HarvestUserAssignment ua : hUserAssignments) {
	 		userAssignments.add(HarvestUtil.transformUserAssignment(ua, projectMap, userMap));
		}

		/* PROCESS TIME ENTRIEs
		*/
		List<Harvest_Time_Entry__c> timeEntries = new List<Harvest_Time_Entry__c>();

		for (HarvestTImeEntry ht : hTimeEntries) {
			timeEntries.add(HarvestUtil.transformTimeEntry(ht, userMap, taskMap, accountMap, projectMap));
		}
		
			
		upsert hp Harvest_Id__c; 
		upsert taskAssignments Harvest_Id__c;
		upsert userAssignments Harvest_Id__c;
		upsert timeEntries Harvest_Id__c; 
		
		return null;
	}
}