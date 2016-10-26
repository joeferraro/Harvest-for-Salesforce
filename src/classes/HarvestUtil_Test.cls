public class HarvestUtil_Test {
    static testMethod void runTests() {
        HarvestUtil.convertBoolean('true');
        HarvestUtil.convertDateTime('10101010101010110101010101010101010');
        HarvestUtil.convertDecimal('123.45');
        HarvestUtil.convertDouble('33');
        HarvestUtil.convertInvoiceDate('2008-11-04');
        HarvestUtil.transformClient(Harvest_TestUtil.getClient());
        Map<String, Id> accountMap = new Map<String, Id> { '1234' => '0018000000fxnYD' };
        HarvestUtil.transformContact(Harvest_TestUtil.getContact(), accountMap);
        HarvestUtil.transformProject(Harvest_TestUtil.getProject(), accountMap);
        HarvestUtil.transformUser(Harvest_TestUtil.getUser());
        HarvestUtil.transformTask(Harvest_TestUtil.getTask());
        HarvestUtil.getBillBy('hours'); 
        HarvestUtil.getBudgetBy('No Budget');
        HarvestUtil.getBudgetBy('Total Project Hours');
        HarvestUtil.getBudgetBy('Total Project Fees');
        HarvestUtil.getBudgetBy('Hours per Task');
        HarvestUtil.getBudgetBy('Hours per Person');
        HarvestUtil.getBudgetBy('none');
        HarvestUtil.getBudgetBy('project');
        HarvestUtil.getBudgetBy('project_cost');
        HarvestUtil.getBudgetBy('task');
        HarvestUtil.getBudgetBy('person');       
        
        Account a = new Account();
        a.Name = 'unittest account';
        a.Harvest_ID__c = '999888';
        insert a;
        HarvestUtil.getHarvestAccountMap(new Set<String>{ '999888' });
        
        Harvest_Project__c p = new Harvest_Project__c();
        p.Name = 'unittest';
        p.Harvest_Id__c = '222333';
        insert p;
        HarvestUtil.getHarvestProjectMap(new Set<String>{ '222333' });
    }
}