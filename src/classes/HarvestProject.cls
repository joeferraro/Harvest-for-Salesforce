public class HarvestProject {
 
    public String id { get; set; }
    public String name { get; set; }
    public Boolean active { get; set; }
    public Boolean billable { get; set; }
    public String billBy { get; set; }
    public String clientId { get; set; }
    public String code { get; set; }
    public String notes { get; set; }
    public String budgetBy { get; set; }
    public String budget { get; set; }
    public String fees { get; set; }
    //new attributes
    public Decimal hourlyRate { get; set; }
    public Boolean notifyWhenOverBudget { get; set; }
    public Decimal overBudgetPercentage { get; set; }
    public String overBudgetNotifiedAt { get; set; }
    public Boolean budgetToAll { get; set; }
    public DateTime createdAt { get; set; }
    public DateTime updatedAt { get; set; }
    public Date endsOn { get; set; }
    public Decimal estimate { get; set; }
    public String estimateBy { get; set; }
    public Date hintEarliestRecordAt { get; set; }
    public Date hintLatestRecordAt { get; set; }
    public String costBudget { get; set; }
    public Boolean costBuddgetIncludeExpenses { get; set; }
}