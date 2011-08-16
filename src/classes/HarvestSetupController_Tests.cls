@istest
private class HarvestSetupController_Tests {
    
    public static Harvest_TestUtil.HarvestTester ht;
    
    static {
        system.debug('$$$CALLING STATIC$$$');
        ht = new Harvest_TestUtil.HarvestTester();
    } 
    
    private static Account getAccount() {
        Account a = new Account();
        a.name = 'ut harvest account'; 
        a.sync_to_harvest__c = true;
        a.isActiveHarvestClient__c = true;
        a.billingstreet = '1234 main st';
        a.billingcity = 'new york';
        a.billingstate = 'ny';
        a.billingpostalcode = '12345';
        a.billingcountry = 'usa';
        a.website = 'www.ut-harvest-test.com';
        a.phone = '4445556666';
        a.fax = '3332221111';
        return a;
    }
    
    private static Contact getContact() {
        Contact c = new Contact();
        c.FirstName = 'Billy';
        c.LastName = 'Harvest Contact';
        c.Phone = '1112223333';
        c.Email = 'harvesttest@test.com';
        c.Sync_to_Harvest__c = true;
        return c;
    }
    
    private static testMethod void testSetupController() {
        Account a = getAccount();
        Contact c = getContact();
        try {
        PageReference setupPage = Page.HarvestSetup;
        Test.setCurrentPageReference(setupPage);
        HarvestSetupController setup = new HarvestSetupController();
        setup.harvestConnection = ht;
        setup.init();
        setup.clientId = 'aaa222';
        setup.contactId = '11072';
        setup.projectId = '1';
        setup.userId = '54234';
        //setup.doGetClient();
        //setup.doGetContact();
        //setup.doGetProject();
        //setup.doGetUser();
        setup.doGetClients();
        setup.doGetContacts();
        setup.doGetProjects();
        setup.doGetUsers();
        setup.doImportClients();
        setup.doImportContacts();
        setup.save();
        setup.cancel();
        setup.goToClientExportWizard();     
        setup.goToClientImportWizard();
        setup.goToSetupInboundIntegration();
        setup.testConnection();
        } catch(Exception e) {
        	system.debug(e);
        }
    }
}