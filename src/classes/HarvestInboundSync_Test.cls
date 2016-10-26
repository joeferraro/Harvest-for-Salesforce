public class HarvestInboundSync_Test {
    public static Harvest_TestUtil.HarvestTester ht;
    
    static {
        system.debug('$$$CALLING STATIC$$$');
        ht = new Harvest_TestUtil.HarvestTester();
    } 
    
    static testmethod void testInboundSync() {
        HarvestInboundSyncController.sync();
    }
    
    static testmethod void testScheduler() {
        Test.startTest();
        String jobId = System.schedule('testBasicScheduledApex', '0 0 0 3 9 ? 2022', new HarvestInboundSync());
        Test.stopTest();
    }
}