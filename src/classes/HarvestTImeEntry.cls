/**
 * Harvest Time Entry
 * @see http://help.getharvest.com/api/timesheets-api/timesheets/adding-updating-time/
 */
public with sharing class HarvestTimeEntry {
	
	public String id;
	public Date spentAt;
	public String userId;
	public String clientId;
	public String projectId;
	public String taskId;
	public Decimal hours;
	public Decimal hoursWithTimer;
	public Decimal hoursWithoutTimer;
	public String notes;
	public Datetime createdAt;
	public Datetime updatedAt;
	public Boolean isBilled;
	public Boolean isClosed;
	public Datetime timerStartedAt;
	public Datetime startedAt;
	public Datetime endedAt;

}