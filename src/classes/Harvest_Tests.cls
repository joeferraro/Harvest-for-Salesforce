@istest
private class Harvest_Tests {
	
	static Harvest_TestUtil.HarvestTester ht;
	
	static { 
		system.debug('$$$CALLING STATIC$$$');
		ht = new Harvest_TestUtil.HarvestTester();
	} 
		
	static testMethod void testGetRequests() {
		ht.getClients(); 
		ht.getContacts();
		ht.getProjects();
		ht.getInvoices();
		ht.getUsers();
		ht.getClient('unittest');
		ht.getContact('unittest');
		ht.getProject('unittest');
		ht.getUser('unittest');
		ht.getInvoice('unittest');
		Harvest_TestUtil.getInvoice();
		ht.getTasks();
		ht.getTask('unittest');
		ht.toggleProject('unittest');
		ht.toggleUser('unittest');
		ht.resetUserPassword('unittest');
    }
    
	static testMethod void testClientOperations() {
        map<String, String> params = new map<String, String>();
        params.put('name', 'unittest');
        params.put('details', 'unittest');     
		ht.insertClient(params);
		ht.updateClient('unittest', params);
		ht.deleteClient('unittest');
		ht.toggleClient('unittest');
		
		List<Map<String, String>> paramMap = new List<Map<String,String>>();
		params.put('external-id', '333');
		paramMap.add(params);
		String response = ht.insertClients(paramMap);
    }
    
	static testMethod void testContactOperations() {
        map<String, String> params = new map<String, String>();
        params.put('name', 'unittest');
		ht.insertClientContact(params);
		ht.updateClientContact('unittest', params);
		ht.deleteClientContact('unittest');
    }
    
	static testMethod void testProjectOperations() {
        map<String, String> params = new map<String, String>();
        params.put('name', 'unittest');
		ht.insertProject(params);
		ht.updateProject('unittest', params);
		ht.deleteProject('unittest');
    }
    
	static testMethod void testUserOperations() {
        map<String, String> params = new map<String, String>();
        params.put('name', 'unittest');
		ht.insertUser(params);
		ht.updateUser('unittest', params);
		ht.deleteUser('unittest');
    }
    
    static testMethod void testHarvestClientImportWizard() {
		Account a = new Account();
		a.Name = 'Client Test 3';
		insert a;
		Account a2 = new Account();
		a2.Name = 'Client Test 3';
		insert a2;
		PageReference clientImportWizard = Page.HarvestClientExportWizard;
		Test.setCurrentPageReference(clientImportWizard);
		HarvestClientImportWizard controller = new HarvestClientImportWizard();
		controller.harvestConnection = ht;
		controller.doGetClients();
		controller.doImport();
		for (integer i = 0; i < controller.clients.size(); i++)
			controller.clients.get(i).isSelected = true;
		controller.doImport();
		ApexPages.currentPage().getParameters().put('id', controller.clients.get(0).client.Id);
		ApexPages.currentPage().getParameters().put('create', controller.clients.get(0).client.Id);
		controller.setAction();
		controller.finishImport();
		System.assertEquals(1, [Select count() from Account where Harvest_Id__c = 'unittest']);		
    }
    
    static testMethod void testHarvestClientExportWizard() {
		Account a = new Account();
		a.Name = 'Unittest Client 1';
		insert a;
		Account a2 = new Account();
		a2.Name = 'Unittest Client 2';
		insert a2;
		PageReference clientExportWizard = Page.HarvestClientExportWizard;
		Test.setCurrentPageReference(clientExportWizard);
		HarvestClientExportWizard controller = new HarvestClientExportWizard();
		controller.getAccountList();
		controller.accountName = 'Unittest Client 1';
		controller.doaccountsearch();
		system.assertEquals(1, controller.accounts.size());
		
		Boolean b = controller.hasNext;
		b = controller.hasPrevious;
		Integer i = controller.pageNumber;
		controller.first();
		controller.last();
		controller.previous();
		controller.next();
		controller.cancel();
		
		controller.accounts.get(0).isSelected = true;
		controller.putInExportQueue();
		system.assertEquals(1, controller.accountsForExport.size());
		controller.accountsForExport.get(0).isSelected = true;
		controller.doRemoveFromQueue();
		system.assertEquals(0, controller.accountsForExport.size());
		controller.accounts.get(0).isSelected = true;
		controller.putInExportQueue();
		controller.doExport();
    }
    
    static testMethod void testProjectOnClosedOpportunity() {
   		//Harvest__c settings = Harvest__c.getInstance();
   		//settings.Create_Harvest_Project_Automatically__c = true;
   		//update settings;
   		
   		Account a = new Account();
   		a.Name = 'unittest';
   		a.Harvest_Id__c = 'xyxy1234';
   		insert a;
   		
   		Opportunity o = new Opportunity();
   		o.Name = 'unittest opp';
   		o.AccountId = a.Id;
   		o.CloseDate = Date.today();
   		o.StageName = 'Closed Won';
   		insert o;
    }
    
    static testMethod void testProjectOnClosedOpportunity_Update() {
   		Account a = new Account();
   		a.Name = 'unittest';
   		a.Harvest_Id__c = 'xyxy1234';
   		insert a;
   		
   		Opportunity o = new Opportunity();
   		o.Name = 'unittest opp';
   		o.AccountId = a.Id;
   		o.CloseDate = Date.today();
   		o.StageName = 'Prospecting';
   		insert o;
   		
   		o.StageName = 'Closed Won';
   		update o;
   		
    }
    
    static testMethod void testHarvestUser() {
		Harvest_User__c u = new Harvest_User__c();
		u.Add_to_all_new_projects_automatically__c = true;
		u.First_name__c = 'Mike';
		u.Last_name__c = 'Smith';
		insert u;
    }
    
    static testMethod void testHarvestUser_update() {
		Harvest_User__c u = new Harvest_User__c();
		u.Add_to_all_new_projects_automatically__c = true;
		u.First_name__c = 'Mike';
		u.Last_name__c = 'Smith';
		insert u;
		
		u.Last_name__c = 'Smythe';
		update u;
    }
    
    static testMethod void testHarvestInvoiceMessage() {
    	HarvestInvoiceMessage m = new HarvestInvoiceMessage();
    	m.body = 'test';
    	m.createdAt = 'test';
    	m.id = 'test';
    	m.invoiceId = 'test';
    	m.sendMeACopy = true;
    	m.sentBy = 'test';
    	m.sentByEmail = 'test';
    	m.fullRecipientList = 'test';
    }
}