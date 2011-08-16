public class HarvestOutboundSyncController {
        
    private static Harvest__c creds {
        get { return Harvest__c.getInstance();  }
    }
    /* 
    public virtual Harvest getConnection() {
        return new Harvest();
    }
    
    public void execute(String objectName, String operation, String id) {
        Harvest h = getConnection();
        if (objectName == 'Account') {
            if (operation == 'insert') {
                insertClientAsync(id, h);
            } else if (operation == 'update') {
                updateClientAsync(id);
            } else if (operation == 'toggle') {
                toggleClientAsync(id);
            } else if (operation == 'delete') {
                deleteClientAsync(id);
            }
        } else if (objectName == 'Contact') {
            
        } else if (objectName == 'Harvest_Project__c') {
            
        }
    }
    */
    
    static String getHarvestDetails(Account a) {
    	String hd = '';
    	if (a.BillingStreet != null)
    		hd += a.BillingStreet + '\n';
		if (a.BillingCity != null && a.BillingState != null)
			hd += a.BillingCity + ', ' + a.BillingState + ' ';
		if (a.BillingPostalCode != null) 
			hd += a.BillingPostalCode;
		if (a.BillingCountry != null)
			hd += '\n' + a.BillingCountry;
		if (a.BillingCity != null && a.BillingState != null) 
			hd += '\n';
		if (a.Phone != null)
			hd += a.Phone + '\n';
		if (a.Fax != null)
			hd += a.Fax + '\n';
		if (a.Website != null)
			hd += a.Website;
		return hd;
    }
    
    @future (callout = true)
    public static void insertClientAsync(Id accountId) {
        map<String, String> params = new map<String, String>();
        Account a = [Select Id, Harvest_Id__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Id = :accountId];
        params.put('name', a.Name);
        params.put('details', getHarvestDetails(a));     
        Harvest h = new Harvest();
        String response = h.insertClient(params);
        a.Harvest_Id__c = response;
        a.isActiveHarvestClient__c = true;
        HarvestAsyncControl.inFutureContext = true;
        update a; 
    } 
            
    @future (callout = true)
    public static void updateClientAsync(String clientId) {
        system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
        map<String, String> params = new map<String, String>();
        Account a = [Select Id, Harvest_Id__c, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Harvest_Id__c = :clientId];
        params.put('name', a.Name);
        params.put('details', getHarvestDetails(a)); 
        Harvest h = new Harvest();
        String response = h.updateClient(clientId, params);
    }
    
    @future (callout = true)
    public static void toggleClientAsync(String clientId) {     
        Harvest h = new Harvest();
        String response = h.toggleClient(clientId);
    }
    
    @future (callout = true)
    public static void deleteClientAsync(String clientId) {     
        Harvest__c settings = Harvest__c.getInstance();
        if (settings.Delete_Client_in_Harvest__c == false) return;
        Harvest h = new Harvest();
        String response = h.deleteClient(clientId);
    }
    
    @future (callout = true)
    public static void deleteClientContactAsync(String contactId) {     
        Harvest h = new Harvest();
        String response = h.deleteClientContact(contactId);
    }
    
    @future (callout = true)
    public static void insertClientContactAsync(Id contactId) {
        map<String, String> params = new map<String, String>();
        Contact c = [Select Id, Harvest_Id__c, Account.Harvest_Id__c, Email, FirstName, LastName, Phone, MobilePhone, Fax from Contact where Id = :contactId];
        params.put('client-id', c.Account.Harvest_Id__c);
        params.put('email', c.Email);
        params.put('first-name', c.FirstName);
        params.put('last-name', c.LastName);
        params.put('phone-office', c.Phone);
        params.put('phone-mobile', c.MobilePhone);
        params.put('fax', c.Fax);               
        Harvest h = new Harvest();
        String response = h.insertClientContact(params);
        c.Harvest_Id__c = response;
        HarvestAsyncControl.inFutureContext = true;
        update c;
    }
    
    @future (callout = true)
    public static void updateClientContactAsync(String contactId) {
        map<String, String> params = new map<String, String>();
        Contact c = [Select Id, Harvest_Id__c, Account.Harvest_Id__c, Email, FirstName, LastName, Phone, MobilePhone, Fax from Contact where Harvest_Id__c = :contactId];
        params.put('client-id', c.Account.Harvest_Id__c);
        params.put('email', c.Email);
        params.put('first-name', c.FirstName);
        params.put('last-name', c.LastName);
        params.put('phone-office', c.Phone);
        params.put('phone-mobile', c.MobilePhone);
        params.put('fax', c.Fax);               
        Harvest h = new Harvest();
        String response = h.updateClientContact(contactId, params);
    }  
        
    @future (callout = true)
    public static void insertProjectAsync(String projectId) {
        Harvest h = new Harvest();
        map<String, String> params = new map<String, String>();
        Harvest_Project__c p = [Select Id, Name, Harvest_Id__c, Account__r.Harvest_Id__c, Bill_by__c, Billable__c, Budget__c, Budget_by__c, Notes__c, Project_Code__c from Harvest_Project__c where Id = :projectId];
        params.put('name', p.Name);
        params.put('billable', String.valueOf(p.Billable__c));
        params.put('bill-by', HarvestUtil.getBillBy(p.Bill_By__c));
        params.put('client-id', p.Account__r.Harvest_Id__c);
        params.put('code', p.Project_Code__c);
        params.put('notes', p.Notes__c);
        params.put('budget', String.valueOf(p.Budget__c));
        params.put('budget-by', HarvestUtil.getBudgetBy(p.Budget_By__c));
        String response = h.insertProject(params);
        p.Harvest_Id__c = response;
        p.Active__c = true;
        HarvestAsyncControl.inFutureContext = true;
        update p;
    }
        
    @future (callout = true)
    public static void updateProjectAsync(String projectId) {
        Harvest h = new Harvest();
        map<String, String> params = new map<String, String>();
        Harvest_Project__c p = [Select Id, Name, Harvest_Id__c, Account__r.Harvest_Id__c, Billable__c, Bill_by__c, Budget__c, Budget_by__c, Notes__c, Project_Code__c from Harvest_Project__c where Harvest_Id__c = :projectId];
        params.put('name', p.Name);
        params.put('billable', String.valueOf(p.Billable__c));
        params.put('bill-by', HarvestUtil.getBillBy(p.Bill_By__c));
        params.put('client-id', p.Account__r.Harvest_Id__c);
        params.put('code', p.Project_Code__c);
        params.put('notes', p.Notes__c);
        params.put('budget', String.valueOf(p.Budget__c));
        params.put('budget-by', HarvestUtil.getBudgetBy(p.Budget_By__c));
        String response = h.updateProject(projectId, params);
    }
    
    @future (callout = true) 
    public static void toggleProjectAsync(String projectId) {       
        Harvest h = new Harvest();
        String response = h.toggleProject(projectId);
    }
    
    @future (callout = true)
    public static void deleteProjectAsync(String projectId) {       
        Harvest h = new Harvest();
        String response = h.deleteProject(projectId);
    }
    
    @future (callout = true)
    public static void insertPersonAsync(String userId) {
        Harvest h = new Harvest();
        map<String, String> params = new map<String, String>();
        Harvest_User__c u = [Select Id, Name, Password__c, Harvest_Id__c, First_Name__c, Last_Name__c, Email__c, Timezone__c, Is_Admin__c, Phone__c from Harvest_User__c where Id = :userId];
        params.put('first_name', u.First_name__c);
        params.put('last_name', u.Last_name__c);
        params.put('email', u.Email__c);
        params.put('password', u.Password__c);
        params.put('password_confirmation', u.Password__c);
        params.put('timezone', u.Timezone__c);
        params.put('is_admin', String.valueOf(u.Is_Admin__c));
        params.put('telephone', u.Phone__c);
        String response = h.insertUser(params);
        u.Harvest_Id__c = response;
        u.Is_Active__c = true;
        HarvestAsyncControl.inFutureContext = true;
        update u;
    }
    
    @future (callout = true)
    public static void updatePersonAsync(String userId) {
        Harvest h = new Harvest();
        map<String, String> params = new map<String, String>();
        Harvest_User__c u = [Select Id, Name, Password__c, Harvest_Id__c, First_Name__c, Last_Name__c, Email__c, Timezone__c, Is_Admin__c, Phone__c from Harvest_User__c where Harvest_Id__c = :userId];
        params.put('first_name', u.First_name__c);
        params.put('last_name', u.Last_name__c);
        params.put('email', u.Email__c);
        params.put('timezone', u.Timezone__c);
        params.put('is_admin', String.valueOf(u.Is_Admin__c));
        params.put('telephone', u.Phone__c);
        String response = h.updateUser(userId, params);
    }
    
    @future (callout = true)
    public static void deletePersonAsync(String userId) {       
        Harvest h = new Harvest();
        String response = h.deleteUser(userId);
    }   
}