public class HarvestUserAssignment {
	
	public String id { get; set; }
	public String userId { get; set; }
	public String projectId { get; set; }
	public Boolean deactivated { get; set; }
	public String hourlyRate { get; set; }
	public Boolean isProjectManager { get; set; }
	public Decimal budget { get; set; }
	public Decimal estimate { get; set; }
    public Datetime createdAt { get; set; }
    public Datetime updatedAt { get; set; }
	
}