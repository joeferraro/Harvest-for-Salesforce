global class HarvestInboundSyncController {
    
    @future (callout = true)
    public static void sync() {        
        Harvest h = new Harvest();
		Harvest__c settings = Harvest__c.getOrgDefaults();
		
		List<HarvestClient> clients;
		List<HarvestContact> hContacts;
		List<HarvestProject> hProjects;
		
		if (settings.InboundLastRunDateTime__c != null) {
        	clients = h.getClientsUpdatedSince(settings.InboundLastRunDateTime__c);
        	hContacts = h.getContactsUpdatedSince(settings.InboundLastRunDateTime__c);
        	hProjects = h.getProjectsUpdatedSince(settings.InboundLastRunDateTime__c);
		} else {
        	clients = h.getClients();
        	hContacts = h.getContacts();
        	hProjects = h.getProjects();
		}

        List<HarvestUser> hUsers = h.getUsers();
        List<HarvestTask> hTasks = h.getTasks();
        List<HarvestInvoice> hInvoices = h.getInvoices();
        if (hInvoices.size() == 50)
        	hInvoices.addAll(h.getInvoicesByPage(2));
    	if (hInvoices.size() == 100)
        	hInvoices.addAll(h.getInvoicesByPage(3));
    	if (hInvoices.size() == 150)
        	hInvoices.addAll(h.getInvoicesByPage(4));

		HarvestAsyncControl.inFutureContext = true;
		
        /*PROCESS CLIENTS*/      
        List<Account> accounts = new List<Account>();
        for (HarvestClient c : clients) {
            accounts.add(HarvestUtil.transformClient(c));
        }   
        upsert accounts Harvest_Id__c;
        
        /*PROCESS CONTACTS*/        
        set<string> clientIds = new set<string>();
        for (HarvestContact c: hContacts) {
            clientIds.add(c.clientId);
        }  
        
        Map<String, Id> accountMap = HarvestUtil.getHarvestAccountMap(clientIds);   

        List<Contact> contacts = new List<Contact>();
        for (HarvestContact c : hContacts) {
            contacts.add(HarvestUtil.transformContact(c, accountMap));
        }   
        upsert contacts Harvest_Id__c;  
                
        /*PROCESS PROJECTS*/
        clientIds.clear();
        for (HarvestProject p : hProjects) {
            clientIds.add(p.clientId);
        } 
        
        accountMap.clear(); 
        accountMap = HarvestUtil.getHarvestAccountMap(clientIds);   
        
        List<Harvest_Project__c> projects = new List<Harvest_Project__c>();
        for (HarvestProject p : hProjects) {
            projects.add(HarvestUtil.transformProject(p, accountMap));
        }
        upsert projects Harvest_Id__c;
                
        /*PROCESS USERS*/
        List<Harvest_User__c> users = new List<Harvest_User__c>();
        for (HarvestUser u : hUsers) {
            users.add(HarvestUtil.transformUser(u));
        }
        upsert users Harvest_Id__c;
        
        /*PROCESS TASKS*/
        List<Harvest_Task__c> tasks = new List<Harvest_Task__c>();
        for (HarvestTask ht : hTasks) {
            tasks.add(HarvestUtil.transformTask(ht));
        }
        upsert tasks Harvest_Id__c;

        /*PROCESS INVOICES*/
        clientIds.clear();
        clientIds = new Set<String>();
        for (HarvestInvoice hi : hInvoices) {
            clientIds.add(hi.clientId);
        } 
        
        Map<String, Id> clientMap = new Map<String, Id>();
        for (Account a : [Select Id, Harvest_Id__c from Account where Harvest_Id__c in :clientIds])
            clientMap.put(a.Harvest_Id__c, a.Id);
            
        List<Harvest_Invoice__c> invoices = new List<Harvest_Invoice__c>();
        for (HarvestInvoice hi : hInvoices) {
            invoices.add(HarvestUtil.transformInvoice(hi, clientMap));
        }  
        upsert invoices Harvest_Id__c;
        

		settings.InboundLastRunDateTime__c = DateTime.now();
		upsert settings;
    }    
}