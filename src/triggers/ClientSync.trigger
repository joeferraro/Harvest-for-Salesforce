trigger ClientSync on Account (after insert, after update, after delete) {
         
    if (trigger.size == 1) {
        if (HarvestAsyncControl.inFutureContext == true)
            return;
                     
        if (trigger.isInsert || trigger.isUpdate) {          
            if (trigger.new.get(0).Sync_to_Harvest__c == false)
                return;
            
            for (Account a : trigger.new) { 
                if (trigger.isInsert) {
                    if (a.Harvest_Id__c == null)
                        HarvestOutboundSyncController.insertClientAsync(a.Id); 
                } else if (trigger.isUpdate) {
                    if (trigger.oldmap.get(a.Id).Harvest_Id__c == null && a.Harvest_Id__c != null)
                        return;
                    if (a.Harvest_ID__c != null) {
                        if (trigger.oldmap.get(a.id).Sync_To_Harvest__c != a.Sync_To_Harvest__c)
                            HarvestOutboundSyncController.toggleClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).isActiveHarvestClient__c != a.isActiveHarvestClient__c)
                            HarvestOutboundSyncController.toggleClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).name != a.name)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).billingstreet != a.billingstreet)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).billingcity != a.billingcity)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).billingstate != a.billingstate)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).billingpostalcode != a.billingpostalcode)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).billingcountry != a.billingcountry)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).phone != a.phone)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).fax != a.fax)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                        else if (trigger.oldmap.get(a.id).website != a.website)
                            HarvestOutboundSyncController.updateClientAsync(a.Harvest_Id__c);
                    } else {
                        HarvestOutboundSyncController.insertClientAsync(a.Id);
                    }
                }
            } 
        } else if (trigger.isDelete) {
            for (Account a : trigger.old) {
                HarvestOutboundSyncController.deleteClientAsync(a.Harvest_Id__c);
            }
        }
    }
}