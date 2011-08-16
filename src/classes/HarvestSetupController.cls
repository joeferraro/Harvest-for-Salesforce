public class HarvestSetupController {
    
    public Harvest harvestConnection { get; set; }
    public HarvestUser user { get; set; }   
    public List<ClientWrapper> clients { get; set; }
    public List<ContactWrapper> contacts { get; set; }
    public List<ProjectWrapper> projects { get; set; }
    public List<UserWrapper> users { get; set; }
    public Harvest__c settings { get; set; }
    public Boolean inboundScheduled { get; set; }
    public String connectionStatus { get; set; }
    
    public String clientId { get; set; }
    public String contactId { get; set; }
    public String projectId { get; set; }
    public String userId { get; set; }
    
    public String loginResponse { get; set; }
        
    public HarvestSetupController() { }
    
    public void init() {
        if (Harvest__c.getInstance() == null) { //new setup
        	upsert new Harvest__c(SetupOwnerId=UserInfo.getOrganizationId());
        	this.settings = Harvest__c.getOrgDefaults();  
        } else {         
        	this.settings = Harvest__c.getOrgDefaults();  
        }
        inboundScheduled = false;
        if (this.settings.CronTriggerId__c != null)
        	inboundScheduled = true;
        this.clients = new List<ClientWrapper>();
        this.contacts = new List<ContactWrapper>();
        this.projects = new List<ProjectWrapper>(); 
        this.users = new List<UserWrapper>();
    }
    
    public void runInboundSync() {
    	HarvestInboundSyncController.sync();
    } 
    
    public void testConnection() {   	
    	HttpRequest req = new HttpRequest();
     	req.setHeader('Accept', 'application/xml');
     	req.setHeader('Content-Type', 'application/xml');
     	String endpoint = '';
     	if (this.settings.SSL__c == true) endpoint += 'https://';
     	else endpoint += 'http://';
     	endpoint += this.settings.Subdomain__c + '.harvestapp.com/account/who_am_i';
     	req.setEndpoint(endpoint);
      	req.setMethod('GET');      	
      	Blob headerValue = Blob.valueOf(this.settings.Username__c + ':' + this.settings.Password__c);
      	String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
      	req.setHeader('Authorization', authorizationHeader);
		HttpResponse resp = new http().send(req);
		this.connectionStatus = 'failed';
		if (resp.getStatusCode() == 200)
			this.connectionStatus = 'ok';
    }
        
    public PageReference save() {
        if (settings.Subdomain__c == null || settings.Username__c == null || settings.Password__c == null) {
        	ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify your Harvest Subdomain and Username/Password');
        	ApexPages.addMessage(error);
        	return null;	
        } else {
        	upsert this.settings;
        	return Page.HarvestSetup;
        }
    }
    /*
    public void testCreds() {
    	this.harvestConnection = new Harvest();
		if (this.HarvestConnection.user == null) {
        	ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify your Harvest Subdomain and Username/Password');
        	ApexPages.addMessage(error);
		} else {
        	ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.INFO, 'You successfully connected to Harvest');
        	ApexPages.addMessage(error);
		}	
    }
    */
       
   	
    public PageReference startInboundSync() {
    	HarvestInboundScheduler.start();
        return Page.HarvestSetup;
    }
    
    public PageReference stopInboundSync() {
		System.abortJob(settings.CronTriggerId__c);
		this.settings.CronTriggerId__c = null;
		upsert this.settings;  
        return Page.HarvestSetup;
    }
        
    public PageReference cancel() {
        return Page.HarvestSetup;
    }
    
    public PageReference goToClientImportWizard() {
        return Page.HarvestClientImportWizard;
    }
    
    public PageReference goToSetupInboundIntegration() {
        return Page.HarvestSetupInboundIntegration;
    }
    
    public PageReference goToClientExportWizard() {
        return Page.HarvestClientExportWizard;
    }
    
    /*
    public void doGetClient() {
        this.clients.clear();
        HarvestClient hClient = harvestConnection.getClient(clientId);
        if (hClient != null) {
            ClientWrapper client = new ClientWrapper(hClient);
            this.clients.add(client);
        }
    }
    
    public void doGetContact() {
        this.contacts.clear(); 
        HarvestContact c = harvestConnection.getContact(contactId);
        if (c != null) {
            ContactWrapper contact = new ContactWrapper(c);
            this.contacts.add(contact);
        }
    }
    
    public void doGetProject() {
        this.projects.clear();
        HarvestProject p = harvestConnection.getProject(projectId);
        if (p != null) {
            ProjectWrapper project = new ProjectWrapper(p);
            this.projects.add(project);
        }
    } 
    
    public void doGetUser() {
        this.users.clear();
        HarvestUser u = harvestConnection.getUser(userId);
        if (u != null) {
            UserWrapper user = new UserWrapper(u);
            this.users.add(user);
        }
    }
    */
        
    public class ClientWrapper {
        public Boolean isSelected { get; set; }
        public HarvestClient client { get; set; }
        public Account a { get; set; }
        public String importResult { get; set; }
        
        public ClientWrapper(HarvestClient c) {
            this.client = c;
        }
    }
            
    public class ContactWrapper {
        public Boolean isSelected { get; set; }
        public HarvestContact contact { get; set; }
        public Contact c { get; set; }
        public String importResult { get; set; }
        
        public ContactWrapper(HarvestContact c) {
            this.contact = c;
        }
    }
    
    public class ProjectWrapper {
        public Boolean isSelected { get; set; }
        public HarvestProject project { get; set; }
        public Harvest_Project__c p { get; set; }
        public String importResult { get; set; }
        
        public ProjectWrapper(HarvestProject p) {
            this.project = p;
        }
    }
    
    public class UserWrapper {
        public Boolean isSelected { get; set; }
        public HarvestUser user { get; set; }
        public Harvest_User__c u { get; set; }
        public String importResult { get; set; }
        
        public UserWrapper(HarvestUser u) {
            this.user = u;
        }
    }
     
    public void doGetClients() {
        this.clients.clear();
        List<HarvestClient> hClients = harvestConnection.getClients();
        for (HarvestClient hc : hClients) {
            ClientWrapper client = new ClientWrapper(hc);
            this.clients.add(client);
        }
    }
        
    public void doGetContacts() {
        this.contacts.clear();
        List<HarvestContact> hContacts = harvestConnection.getContacts();
        for (HarvestContact hc : hContacts) {
            ContactWrapper contact = new ContactWrapper(hc);
            this.contacts.add(contact);
        }
    }
    
    public void doGetProjects() {
        this.projects.clear();
        List<HarvestProject> hProjects = harvestConnection.getProjects();
        for (HarvestProject hp : hProjects) {
            ProjectWrapper p = new ProjectWrapper(hp);
            this.projects.add(p);
        }
    }
    
    public void doGetUsers() {
        this.projects.clear();
        List<HarvestUser> hUsers = harvestConnection.getUsers();
        for (HarvestUser hu : hUsers) {
            UserWrapper u = new UserWrapper(hu);
            this.users.add(u);
        }
    }
        
    public void doImportClients() {     
        List<Account> accounts = new List<Account>();
        set<string> clientIds = new set<string>();
        
        for (ClientWrapper c : this.clients) {
            if (c.isSelected == true) {
                clientIds.add(c.client.id);
            }
        }
        
        map<string, Account> accountMap = new map<string, Account>();       
        for (Account a : [Select Id, Harvest_Id__c from Account where Harvest_Id__c in :clientIds]) {
            accountMap.put(a.Harvest_Id__c, a);
        }
        
        for (ClientWrapper c : this.clients) {
            if (c.isSelected == true) {
                if (accountMap.containsKey(c.client.id)) {
                    c.importResult = 'A Salesforce Account already exists for this Harvest Id';
                } else {
                    c.importResult = 'Salesforce Account successfully created';
                    Account a = new Account();
                    a.Name = c.client.name;
                    a.isActiveHarvestClient__c = c.client.active;
                    a.Harvest_ID__c = c.client.id;
                    accounts.add(a);
                    c.isSelected = false;
                }
            }
        }
        
        insert accounts;
    }
    
    public void doImportContacts() {        
        List<Contact> contacts = new List<Contact>();
        
        set<string> clientIds = new set<string>();
        for (ContactWrapper cw: this.contacts) {
            clientIds.add(cw.contact.clientId);
        }
        
        Map<String, Id> harvestIdMap = new Map<String, Id>();       
        for (Account a : [Select Id, Harvest_Id__c from Account where Harvest_Id__c in :clientIds]) {
            harvestIdMap.put(a.Harvest_Id__c, a.Id);
        }
        
        for (ContactWrapper cw : this.contacts) {
            if (cw.isSelected == true) {
                Contact c = new Contact();
                c.FirstName = cw.contact.firstname;
                c.LastName = cw.contact.lastname;
                c.Harvest_ID__c = cw.contact.id;
                c.AccountId = harvestIdMap.get(cw.contact.clientId);
                contacts.add(c);
                cw.isSelected = false;
            }
        }  
        
        try {
            upsert contacts Harvest_ID__c;
        } catch (DmlException e) {
            throw e;
        }
    }
    

}