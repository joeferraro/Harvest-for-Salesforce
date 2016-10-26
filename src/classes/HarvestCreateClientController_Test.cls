@istest
private class HarvestCreateClientController_Test {
    
    static Harvest_TestUtil.HarvestTester ht;
    
    static {
        system.debug('$$$CALLING STATIC$$$');
        ht = new Harvest_TestUtil.HarvestTester();
    }
    
    static Account getAccount() {
        Account a = new Account();
        a.name = 'Client Test 3'; 
        a.sync_to_harvest__c = false;
        a.isActiveHarvestClient__c = false;
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
    
    static Contact getContact(Account a) {
        Contact c = new Contact();
        c.FirstName = 'Sally';
        c.LastName = 'Smith';
        c.Email = 'ssmith@testing.com';
        c.AccountId = a.Id;
        return c;
    }
    
    static testMethod void testMergeClientController() {
        Account a = getAccount();
        insert a;
        PageReference testPage = Page.HarvestCreateClient;
        Test.setCurrentPageReference(testPage);
        HarvestCreateClientController controller = new HarvestCreateClientController(new ApexPages.StandardController(a));
        controller.connection = ht;
        controller.init();
        controller.matchingClients.get(0).isSelected = true;
        controller.doMerge();
        controller.a.Harvest_ID__c = 'abab123';
        controller.finish();
    } 
    
    static testMethod void testCreateClientController() {
        Account a = getAccount();
        insert a;
        Contact c = getContact(a);
        insert c;
        PageReference testPage = Page.HarvestCreateClient;
        Test.setCurrentPageReference(testPage);
        HarvestCreateClientController controller = new HarvestCreateClientController(new ApexPages.StandardController(a));
        controller.connection = ht;
        controller.init();
        controller.doCreateClient();
    } 
    
    static testMethod void testOverloadedController() {
        Account a = getAccount();
        insert a;
        Contact c = getContact(a);
        insert c;
        PageReference testPage = Page.HarvestCreateClient;
        Test.setCurrentPageReference(testPage);
        HarvestCreateClientController controller = new HarvestCreateClientController(a.Id);
        controller.connection = ht;
        controller.init();
    } 
}