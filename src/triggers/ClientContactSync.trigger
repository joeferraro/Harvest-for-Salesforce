trigger ClientContactSync on Contact (after delete, after insert, after undelete, after update) {
	  
	if (trigger.size == 1) {
        if (HarvestAsyncControl.inFutureContext == true)
            return;  
                     
        if (trigger.isInsert || trigger.isUpdate) {
            
	        if (trigger.new.get(0).Sync_to_Harvest__c == false)
	        	return;
            
            for (Contact c : trigger.new) {
                if (trigger.isInsert) {
                    if (c.Harvest_ID__c == null)
                    	HarvestOutboundSyncController.insertClientContactAsync(c.Id); 
                } else if (trigger.isUpdate) { 
                    if (c.Harvest_ID__c != null) {
                        if (trigger.oldmap.get(c.id).Sync_To_Harvest__c != c.Sync_To_Harvest__c)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                        else if (trigger.oldmap.get(c.id).firstname != c.firstname)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                        else if (trigger.oldmap.get(c.id).lastname != c.lastname)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                        else if (trigger.oldmap.get(c.id).email != c.email)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                        else if (trigger.oldmap.get(c.id).phone != c.phone)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                        else if (trigger.oldmap.get(c.id).mobilephone != c.mobilephone)
                            HarvestOutboundSyncController.updateClientContactAsync(c.Harvest_Id__c);
                    } else {
                        HarvestOutboundSyncController.insertClientContactAsync(c.Id);
                    }
                }
            } 
        } else if (trigger.isDelete) {
            for (Contact c : trigger.old) {
                HarvestOutboundSyncController.deleteClientContactAsync(c.Harvest_Id__c);
            }
        }
    }
}