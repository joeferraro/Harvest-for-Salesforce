global class HarvestInvoiceSync {   
    
    webservice static String refreshInvoice(String invoiceId) {
    
        Harvest h = new Harvest();
        /*DO CALLOUTS*/
        HarvestInvoice i = h.getInvoice(invoiceId);
        List<HarvestInvoiceMessage> hInvoiceMessages = h.getInvoiceMessages(invoiceId);

        /*PROCESS INVOICE*/ 
        Harvest_Invoice__c hi = [Select Id, Harvest_Id__c, Account__r.Harvest_Id__c, Account__c from Harvest_Invoice__c where Harvest_Id__c = :invoiceId];
        Map<String, Id> accountMap = new Map<String, Id> { hi.Account__r.Harvest_Id__c => hi.Account__c };
        Map<String, Id> invoiceMap = new Map<String, Id> { hi.Harvest_Id__c => hi.Id };
        hi = HarvestUtil.transformInvoice(i, accountMap); 
        
        /*PROCESS INVOICE MESSAGES*/ 
        List<Harvest_Invoice_Message__c> invoiceMessages = new List<Harvest_Invoice_Message__c>();
        for (HarvestInvoiceMessage im : hInvoiceMessages)
            invoiceMessages.add(HarvestUtil.transformInvoiceMessage(im, invoiceMap));
        
        /*PROCESS INVOICE LINES*/
   		/*TODO*/
        
        upsert hi Harvest_Id__c;
        upsert invoiceMessages Harvest_Id__c;
        return null;
    }
    
    
}