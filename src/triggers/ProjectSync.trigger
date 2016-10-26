trigger ProjectSync on Harvest_Project__c (after delete, after insert, after undelete, after update) {
    if (trigger.size == 1) {
        if (HarvestAsyncControl.inFutureContext == true)
            return;  

        if (trigger.isInsert || trigger.isUpdate) {
            for (Harvest_Project__c p : trigger.new) {
                if (trigger.isInsert) {
                    if (p.Harvest_ID__c == null)
                        HarvestOutboundSyncController.insertProjectAsync(p.Id); 
                } else if (trigger.isUpdate) {
                    if (p.Harvest_ID__c != null) {
                        if (trigger.oldmap.get(p.id).Name != p.Name)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Billable__c != p.Billable__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Bill_By__c != p.Bill_By__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Project_Code__c != p.Project_Code__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Notes__c != p.Notes__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Budget__c != p.Budget__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                        else if (trigger.oldmap.get(p.id).Budget_By__c != p.Budget_By__c)
                            HarvestOutboundSyncController.updateProjectAsync(p.Harvest_Id__c);
                    } else {
                        HarvestOutboundSyncController.insertProjectAsync(p.Id);
                    }
                }
            }  
        } else if (trigger.isDelete) {
            for (Harvest_Project__c p : trigger.old) {
                HarvestOutboundSyncController.deleteProjectAsync(p.Harvest_Id__c);
            }
        }
    }
}