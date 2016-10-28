public class HarvestTaskAssignment {
	
	public String id { get; set; }
	public String projectId { get; set; }
	public String taskId { get; set; }
	public Boolean billable { get; set; }
	public Boolean deactivated { get; set; }
	public String budget { get; set; }
	public String hourlyRate { get; set; }
	public Datetime createdAt { get; set; }
	public Datetime updatedAt { get; set; }
	public Decimal estimate { get; set; }

}