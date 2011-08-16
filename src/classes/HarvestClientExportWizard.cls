public with sharing class HarvestClientExportWizard {
    public Harvest harvestConnection { get; set; }
    public List<AccountWrapper> accounts { get; set; }
    Map<Id, AccountWrapper> selectedAccounts { get; set; }
    public List<AccountWrapper> accountsForExport { get; set; }
    Set<Id> accountIdsForExport = new Set<Id>();
    public String accountName { get; set; }
    public String filterId { get; set; }

    public HarvestClientExportWizard() {
        this.accounts = new List<AccountWrapper>();
        this.accountsForExport = new List<AccountWrapper>();
        this.selectedAccounts = new Map<Id, AccountWrapper>();
    }
    
    public void init() {
        this.harvestConnection = new Harvest();
    }
            
    public class AccountWrapper {
        public Boolean isSelected { get; set; }
        public Account a { get; set; }
        public AccountWrapper(Account acc) {
            this.a = acc;
            this.isSelected = false;
        }
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Harvest_Id__c = null order by name'));
                setCon.setPageSize(10);
            }
            return setCon;
        }
        set;
    }

    
    public List<AccountWrapper> getAccountList() { 
        for (AccountWrapper aw : accounts)
            if (aw.isSelected == true) this.selectedAccounts.put(aw.a.Id, aw);

        accounts = new List<AccountWrapper>();
        for (Account a : (List<Account>)setCon.getRecords()) {
            AccountWrapper aw = new AccountWrapper(a);
            if (this.selectedAccounts.containsKey(a.Id))
                aw.isSelected = true;
            accounts.add(aw);
        }
        return accounts;
    }
        
    public PageReference doExport() {
        List<Map<String, String>> paramMap = new List<Map<String,String>>();
        for (AccountWrapper a : accountsForExport) {
            map<String, String> params = new map<String, String>();
            params.put('name', a.a.Name);
            params.put('external_id', a.a.Id);
            params.put('details', a.a.BillingStreet+'\n'+a.a.BillingCity+', '+a.a.BillingState+' '+a.a.BillingPostalCode+'\n'+a.a.BillingCountry+'\n'+a.a.Phone+'\n'+a.a.Fax+'\n'+a.a.Website);     
            paramMap.add(params); 
        }       
        Harvest h = new Harvest();
        String response = h.insertClients(paramMap);
        return Page.HarvestSetup;
    }
    
    public void doaccountsearch() {
        for (AccountWrapper aw : accounts)
            if (aw.isSelected == true) this.selectedAccounts.put(aw.a.Id, aw);
        
        accounts = new List<AccountWrapper>();
        String soql = '';
        if (this.accountName == '')
            soql = 'Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Harvest_Id__c = null order by name';
        else
            soql = 'Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, Website from Account where Name like \'%'+accountName+'%\' AND Harvest_Id__c = null order by name';

        this.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql)); 
        this.setCon.setPageSize(10);    
 
        for (Account a : (List<Account>)setCon.getRecords()) {
            AccountWrapper aw = new AccountWrapper(a);
            if (this.selectedAccounts.containsKey(a.Id))
                aw.isSelected = true;
            accounts.add(aw);
        }
    }
    
    public void doRemoveFromQueue() {
        List<AccountWrapper> keepList = new List<AccountWrapper>();     
        for (AccountWrapper aw : accountsForExport) {
            if (aw.isSelected == false)
                keepList.add(aw);
        }
        accountsForExport = keepList;
    }
    
    public void putInExportQueue() {
        for (AccountWrapper aw : accounts) {
            if (aw.isSelected == true) {
                AccountWrapper awCopy = new AccountWrapper(aw.a);
                aw.isSelected = false;
                accountIdsForExport.add(aw.a.Id);
                this.accountsForExport.add(awCopy);
            }
        }
    }
        
// indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        setCon.first();
    }
 
    // returns the last page of records
    public void last() {
        setCon.last();
    }
 
    // returns the previous page of records
    public void previous() {
        setCon.previous();
    }
 
    // returns the next page of records
    public void next() {
        setCon.next();
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        setCon.cancel();
    }

}