global class HarvestClientImportWizard implements ObjectPaginatorListener {
    public Harvest harvestConnection { get; set; }
    global List<ClientWrapper> clients { get; set; }
    public List<ClientWrapper> clientsForImport { get; set; }
    public List<Account> matchingAccounts { get; set; }
    public Integer conflicts { get; set; }
    public Integer conflictsResolved { get; set; }
	global ObjectPaginator paginator {get;private set;}
    List<ClientWrapper> all = new List<ClientWrapper>();
    public HarvestClientImportWizard() {
        this.clients = new List<ClientWrapper>();
        this.clientsForImport = new List<ClientWrapper>();
        this.conflicts = 0;
        this.conflictsResolved = 0;
        
    }
    
    public void init() {
        this.harvestConnection = new Harvest();
        doGetClients();
    }
    
    public void doGetClients() {
        //this.clients.clear();
        List<HarvestClient> hClients = harvestConnection.getClients();

        
        system.debug('\n\n\n TESTINGCLIENTS \n\n\n' + hClients);
        Map<String, Boolean> clientMap = new Map<String, Boolean>();
        for (HarvestClient hc : hClients)
            clientMap.put(hc.id, false);    
        
        for (Account a : [Select Id, Harvest_Id__c from Account where Harvest_Id__c in :clientMap.keySet()])
            clientMap.put(a.Harvest_Id__c, true);
        
        for (HarvestClient hc : hClients) {
            if (clientMap.get(hc.id) == true) continue;
            ClientWrapper client = new ClientWrapper(hc);
            all.add(client);
        }
        system.debug('\n\n\n TESTINGCLIENTS AFTER \n\n\n' + this.clients);
		paginator = new ObjectPaginator(20,this);
		paginator.setRecords(all);
    }
    
    public PageReference cancel() {
        return Page.HarvestSetup;
    }
    
    global void handlePageChange(List<Object> newPage) {
		clients.clear();
		if (newPage != null) {
			for (Object cw : newPage) {
				clients.add((ClientWrapper)cw);
			}
		}
	}
    
    
    global class ClientWrapper {
        public Boolean isSelected { get; set; }
        public HarvestClient client { get; set; }
        public Account a { get; set; }
        public String importResult { get; set; }
        public String action { get; set; }
        public List<MatchingAccount> matchingAccounts { get; set; }
        public ClientWrapper(HarvestClient c) {
            this.client = c;
            this.matchingAccounts = new List<MatchingAccount>();
        }
    }
    
    public void setAction() {
        String clientId = ApexPages.currentPage().getParameters().get('id');
        String action = ApexPages.currentPage().getParameters().get('action');
        for (ClientWrapper cw : clientsForImport) {
            if (cw.client.id == clientId) {
                if (cw.action == null) conflictsResolved++;
                cw.action = action;
                break;
            }
        }
    }
    
    public class MatchingAccount {
        public Boolean isSelected { get; set; }
        public Account a { get; set; }
        public MatchingAccount(Account acc) {
            this.a = acc;
        }
    }
        
    public PageReference doImport() {
        Integer i = 0;
        for (ClientWrapper c : all)
            if (c.isSelected == true) i++;
        if (i == 0) {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Harvest Client to import');
            ApexPages.addMessage(error);
            return null;
        }
        Set<String> clientNames = new Set<String>();
        for (ClientWrapper c : all) {
            if (c.isSelected == true) {
                clientNames.add(c.client.Name);
                clientsForImport.add(c);
            }
        }
        this.matchingAccounts = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Website, Phone, Owner.Name, Harvest_Id__c from Account where Name in :clientNames order by Name];
        
        for (ClientWrapper cw : clientsForImport) {
            for (Account a : this.matchingAccounts) {
                integer j = 0;
                if (cw.client.Name == a.Name) {
                    cw.matchingAccounts.add(new MatchingAccount(a));
                    if (j == 0) cw.matchingAccounts.get(0).isSelected = true;
                    j++;
                }
            }
        }
        
        for (ClientWrapper cw : clientsForImport) {
            if (cw.matchingAccounts.size() > 0) conflicts++;
        }
        system.debug('\n\n\n TESTING SELECTED \n\n\n' + this.clientsForImport);
        return Page.HarvestClientImportConfirmation;
    }
    
    public void mergeAll() {
        for (ClientWrapper cw : clientsForImport) {
        	if (cw.matchingAccounts.size() > 0)
        		cw.action = 'merge';
        }
        this.conflictsResolved = this.conflicts;
        //PageReference pr = finishImport();
        //return pr;
    }
    
    public PageReference finishImport() {
        List<Account> newAccounts = new List<Account>();
        List<Account> mergeAccounts = new List<Account>();
        for (ClientWrapper cw : clientsForImport) {
            if (cw.matchingAccounts.size() == 0 || cw.action == 'create') {
                Account a = new Account(Name=cw.client.name,Harvest_Id__c=cw.client.id,Sync_To_Harvest__c=true);
                newAccounts.add(a);
            } else if (cw.action == 'merge') {
                for (MatchingAccount ma : cw.matchingAccounts) {
                    if (ma.isSelected == true) {
                        ma.a.Harvest_Id__c = cw.client.id;
                        ma.a.IsActiveHarvestClient__c = cw.client.active;
                        ma.a.Sync_to_Harvest__c = true;
                        mergeAccounts.add(ma.a);
                    }
                }
            }
        }
        insert newAccounts;
        update mergeAccounts;
        return new PageReference('/001/o');
    }
}