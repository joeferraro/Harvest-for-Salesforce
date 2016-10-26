trigger HarvestPeopleSync on Harvest_User__c (after insert, after undelete, after update, before delete) {
    if (trigger.size == 1) {
        if (HarvestAsyncControl.inFutureContext == true)
            return; 
                         
        if (trigger.isInsert || trigger.isUpdate) {
            for (Harvest_User__c u : trigger.new) {
                if (trigger.isInsert) {
                    if (u.Harvest_ID__c == null)
                        HarvestOutboundSyncController.insertPersonAsync(u.Id); 
                } else if (trigger.isUpdate) {
                    if (u.Harvest_ID__c != null) {  
                        if (trigger.oldmap.get(u.id).Name != u.Name)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).First_Name__c != u.First_Name__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Last_Name__c != u.Last_Name__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Email__c != u.Email__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Password__c != u.Password__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Timezone__c != u.Timezone__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Is_Admin__c != u.Is_Admin__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                        else if (trigger.oldmap.get(u.id).Phone__c != u.Phone__c)
                            HarvestOutboundSyncController.updatePersonAsync(u.Harvest_Id__c);
                    } else {
                        HarvestOutboundSyncController.insertPersonAsync(u.Id);
                    } 
                }
            } 
        } else if (trigger.isDelete) {
            for (Harvest_User__c u : trigger.old) {
                HarvestOutboundSyncController.deletePersonAsync(u.Harvest_Id__c);
            }
        }
    }
}