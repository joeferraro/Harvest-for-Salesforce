public with sharing class HarvestOutboundSync_Tests {
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
    
    private static Harvest_Project__c getProject() {
        Harvest_Project__c p = new Harvest_Project__c();
        p.Name = 'unittest project';
        return p;
    }
    
    @istest
    private static void testHarvestClientSyncInsert() {
        Account a = getAccount();
        test.startTest();
        system.debug('\n\n\nTESTING ACCOUNT INSERT\n\n\n');
        insert a;
        test.stopTest();
        //a.Name = 'a new name for my account';
        //update a;
        //delete a;
    }
    
    @istest
    private static void testHarvestClientSyncUpdate_Name() {
        Account a = getAccount();
        insert a;
        test.startTest();
        system.debug('\n\n\nTESTING ACCOUNT UPDATE\n\n\n');
        a.Name = 'a new name for my account';
        a.Harvest_ID__c = 'test123';
        update a;
        test.stopTest();
    }

    @istest
    private static void testHarvestClientSyncUpdate_BillingStreet() {
        Account a = getAccount();
        insert a;
        a.BillingStreet = '333 Main Street';
        a.Harvest_ID__c = 'test123';
        test.startTest();
        update a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestClientSyncUpdate_BillingCity() {
        Account a = getAccount();
        insert a;
        a.BillingCity = 'Springfield';
        a.Harvest_ID__c = 'test123';
        test.startTest();
        update a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestClientSyncUpdate_BillingState() {
        Account a = getAccount();
        insert a;
        a.BillingState = 'VA';
        a.Harvest_ID__c = 'test123';
        test.startTest();
        update a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestClientSyncUpdate_Website() {
        Account a = getAccount();
        insert a;
        a.Website = 'www.newwebsite.com';
        a.Harvest_ID__c = 'test123';
        test.startTest();
        update a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestClientSyncUpdate_ToggleSync() {
        Account a = getAccount();
        insert a;
        a.Sync_To_Harvest__c = false;
        a.Harvest_ID__c = 'test123';
        test.startTest();
        update a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestClientSyncDelete() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        test.startTest();
        delete a;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestContactSyncInsert() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Contact c = getContact();
        c.AccountId = a.Id;
        test.startTest();
        insert c;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestContactSyncUpdate_LastName() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Contact c = getContact();
        c.AccountId = a.Id;
        c.Harvest_Id__c = '767676';
        insert c;
        c.LastName = 'Smith';
        test.startTest();
        update c;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestContactSyncUpdate_FirstName() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Contact c = getContact();
        c.AccountId = a.Id;
        c.Harvest_Id__c = '767676';
        insert c;
        c.FirstName = 'Jimmy';
        test.startTest();
        update c;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestContactSyncUpdate_Email() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Contact c = getContact();
        c.AccountId = a.Id;
        c.Harvest_Id__c = '767676';
        insert c;
        c.Email = 'Jimmy@gmail.com';
        test.startTest();
        update c;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestContactSyncDelete() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Contact c = getContact();
        c.AccountId = a.Id;
        c.Harvest_Id__c = '767676';
        insert c;
        test.startTest();
        delete c;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestProjectSyncInsert() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Harvest_Project__c p = getProject();
        p.Account__c = a.Id;
        test.startTest();
        insert p;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestProjectSyncUpdate() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Harvest_Project__c p = getProject();
        p.Account__c = a.Id;
        insert p;
        test.startTest();
        p.Name = 'unittest new name';
        update p;
        test.stopTest();
    }
    
    @istest
    private static void testHarvestProjectSyncDelete() {
        Account a = getAccount();
        a.Harvest_ID__c = 'test123';
        insert a;
        Harvest_Project__c p = getProject();
        p.Account__c = a.Id;
        insert p;
        test.startTest();
        delete p;
        test.stopTest();
    }
}