global class HarvestAccountRefresh {
	webservice static void doRefresh(String accountId) {
		HarvestCreateClientController c = new HarvestCreateClientController(accountId);
		c.finish();
	}
}