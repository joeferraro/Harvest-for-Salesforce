public class HarvestInvoice {

	public String id { get; set; }
	public String amount { get; set; }
	public String discount { get; set; }
	public String discountAmount { get; set; }
	public String dueAmount { get; set; }
	public String dueAt { get; set; }
	public String dueAtHumanFormat { get; set; }
	public String estimate { get; set; }
	public String periodEnd { get; set; }
	public String periodStart { get; set; }
	public String clientId { get; set; }
	public String currencyName { get; set; }
	public String issuedAt { get; set; }
	public String notes { get; set; }
	public String invoiceNumber { get; set; }
	public String purchaseOrder { get; set; }
	public String state { get; set; }
	public String subject { get; set; }
	public String tax1 { get; set; }
	public String tax2 { get; set; }
	public String taxAmount { get; set; }
	public String taxAmount2 { get; set; }
	public String updatedAt { get; set; }
	public String createdAt { get; set; }
	
	public List<HarvestInvoiceLine> invoiceLines { get; set; }
	
}