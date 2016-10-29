public class HarvestUser {
    
    public String id { get; set; }
    public String email { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public Boolean hasAccessToAllFutureProjects { get; set; }
    public String defaultHourlyRate { get; set; }
    public Boolean isActive { get; set; }
    public Boolean isAdmin { get; set; }
    public Boolean isContractor { get; set; }
    public String telephone { get; set; }
    public String department { get; set; }
    public String timeZone { get; set; }
    public Boolean wantsNewsletter { get; set; }
    public Decimal costRate { get; set; }
    public Datetime createdAt { get; set; }
    public Datetime updatedAt { get; set; }
    public String identityAccountId { get; set; }
    public String identityUserId { get; set; }

}