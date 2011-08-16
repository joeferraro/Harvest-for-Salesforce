public with sharing class HarvestCreateClientController {
    
    public final Account a { get; set; }
    public Harvest connection { get; set; }
    public List<ClientWrapper> matchingClients { get; set; }
    
    public class ClientWrapper {
        public Boolean isSelected { get; set; }
        public HarvestClient client { get; set; }
        public Account a { get; set; }
        public ClientWrapper(HarvestClient c) {
            this.client = c;
        }
    }
    
    public HarvestCreateClientController(ApexPages.StandardController stdController) {
        this.a = [Select Id, Name, Harvest_Id__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Id = :stdController.getId()];
        this.matchingClients = new List<ClientWrapper>();
    }
    
    public HarvestCreateClientController(String accountId) {
        this.a = [Select Id, Name, Harvest_Id__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Id = :accountId];
    	this.connection = new Harvest();
    }
    
    public PageReference init() {
        if (this.connection == null)
            this.connection = new Harvest();
        if (this.a.Harvest_Id__c != null) {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'This client already exists within Harvest');
            ApexPages.addMessage(error);
            return null;
        }
        doGetClients();
        return null;
    }
    
    public void doGetClients() {
        this.matchingClients.clear();
        for (HarvestClient hc : connection.getClients()) {
            if (hc.Name == this.a.Name) {
                this.matchingClients.add(new ClientWrapper(hc));
            }
        }
        if (this.matchingClients.size() > 0)
        	this.matchingClients.get(0).isSelected = true;
        if (this.matchingClients.size() > 0) {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.INFO, 'Would you like to merge this account with one of the following Harvest Clients?');
            ApexPages.addMessage(error);
        }
    }
    
    public PageReference doCreateClient() {
        Map<String, String> params = new Map<String, String>();
        params.put('name', a.Name);
        params.put('details', a.BillingStreet+'\n'+a.BillingCity+', '+a.BillingState+' '+a.BillingPostalCode+'\n'+a.BillingCountry+'\n'+a.Phone+'\n'+a.Fax+'\n'+a.Website);     
        String response = this.connection.insertClient(params);
        a.Harvest_Id__c = response;
        a.isActiveHarvestClient__c = true;
        a.Sync_to_Harvest__c = true;
        HarvestAsyncControl.inFutureContext = true;
        update a; 
        return new PageReference('/'+this.a.Id);
    }
    
    public PageReference doMerge() {
        for (ClientWrapper hc : this.matchingClients) {
            if (hc.isSelected == true) {
                this.a.Harvest_Id__c = hc.client.id;
                this.a.IsActiveHarvestClient__c = hc.client.active;
                break;
            }
        }
        
        this.a.Sync_to_Harvest__c = true;
        update this.a;
        return Page.HarvestCreateClientFinish;
    }
    
    
    public PageReference finish() {
        Map<String, Id> accountMap = new Map<String, Id>{ this.a.Harvest_Id__c => this.a.Id };
        List<HarvestContact> hContacts = this.connection.getContactsForClient(this.a.Harvest_Id__c);
        List<HarvestProject> hProjects = this.connection.getProjectsForClient(this.a.Harvest_Id__c);
        List<HarvestInvoice> hInvoices = this.connection.getInvoicesForClient(this.a.Harvest_Id__c);
        //system.debug('PROJECTS RETURNED: ' + hProjects);
        system.debug('INVOICES RETURNED: ' + hInvoices);
        
        /*PROCESS CONTACTS*/
        Map<String, Contact> emailMap = new Map<String, Contact>();
        for (Contact c : [Select Id, Email from Contact where AccountId = :this.a.Id])
        	emailMap.put(c.Email, c);
        List<Contact> contacts = new List<Contact>();
        List<Contact> existingContacts = new List<Contact>();
        for (HarvestContact c : hContacts) {
            if (emailMap.containsKey(c.email) == false) {
            	contacts.add(HarvestUtil.transformContact(c, accountMap));
        	} else {
        		Contact con = emailMap.get(c.email);
        		con.Harvest_ID__c = c.id;
        		con.Sync_to_Harvest__c = true;
        		existingContacts.add(con);
        	}
        }   
        upsert contacts Harvest_Id__c;
        update existingContacts;
        /*PROCESS PROJECTS*/    
        
        List<Harvest_Project__c> projects = new List<Harvest_Project__c>();
        for (HarvestProject hp : hProjects) {
            projects.add(HarvestUtil.transformProject(hp, accountMap));
        }   
        system.debug('HARVEST PROJECTS: ' + projects);
        upsert projects Harvest_Id__c;
    	
        /*PROCESS INVOICES*/    
        List<Harvest_Invoice__c> invoices = new List<Harvest_Invoice__c>();
        for (HarvestInvoice hi : hInvoices) {
            invoices.add(HarvestUtil.transformInvoice(hi, accountMap));
        }  
        upsert invoices Harvest_Id__c;
        return new PageReference('/'+this.a.Id);
    }
}