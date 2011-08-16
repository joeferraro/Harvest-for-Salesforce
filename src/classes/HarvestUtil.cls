public class HarvestUtil {
    
    public static Account transformClient(HarvestClient c) {
        Account a = new Account();
        a.Name = c.name;
        a.Harvest_Id__c = c.id;
        a.IsActiveHarvestClient__c = c.active;  
        a.Sync_to_Harvest__c = true;
        return a;
    }
    
    public static Contact transformContact(HarvestContact c, Map<String, Id> accountMap) {
        Contact con = new Contact();
        con.Harvest_Id__c = c.id;
        con.AccountId = accountMap.get(c.clientId); 
        con.FirstName = c.firstname;
        con.LastName = c.lastname;
        con.Email = c.email;
        con.Phone = c.phone;
        con.MobilePhone = c.mobile;
        con.Fax = c.fax;
        con.Sync_to_Harvest__c = true;  
        return con;
    }
    
    public static Harvest_Invoice__c transformInvoice(HarvestInvoice i, Map<String, Id> accountMap) {
        Harvest_Invoice__c hi = new Harvest_Invoice__c();
        hi.Account__c = accountMap.get(i.clientId);
        hi.Amount__c = convertDecimal(i.amount);
        hi.Currency__c = i.currencyName;
        hi.Discount__c = convertDouble(i.discount);
        hi.Discount_Amount__c = convertDecimal(i.discountAmount);
        hi.Due_Amount__c = convertDecimal(i.dueAmount);
        hi.Due_At__c = convertInvoiceDate(i.dueAt);
        hi.Due_At_Human_Format__c = i.dueAtHumanFormat;
        //hi.Estimate__c = i.estimate;
        hi.Harvest_ID__c = i.id;
        hi.Invoice_No__c = i.invoiceNumber;
        hi.Issued_At__c = convertInvoiceDate(i.issuedAt);
        hi.Notes__c = i.notes;
        hi.Period_End__c = convertInvoiceDate(i.periodEnd);
        hi.Period_Start__c = convertInvoiceDate(i.periodStart);
        hi.Purchase_Order__c = i.purchaseOrder;
        hi.State__c = i.state;
        hi.Subject__c = i.subject;
        hi.Tax_2__c = convertDouble(i.tax2);
        hi.Tax_2_Amount__c = convertDecimal(i.taxAmount2);
        hi.Tax__c = convertDouble(i.tax1);
        hi.Tax_Amount__c = convertDecimal(i.taxAmount);
        return hi;
    }

    public static Harvest_Invoice_Message__c transformInvoiceMessage(HarvestInvoiceMessage im, Map<String, Id> invoiceMap) {
        Harvest_Invoice_Message__c him = new Harvest_Invoice_Message__c();
        him.Body__c = im.body;
        him.Created_At__c = convertDateTime(im.createdAt);
        him.Full_Recipient_List__c = im.fullRecipientList;
        him.Harvest_ID__c = im.id;
        him.Invoice__c = invoiceMap.get(im.invoiceId);
        him.Send_me_a_copy__c = im.sendMeACopy; 
        him.Sent_By__c = im.sentBy;
        him.Sent_By_Email__c = im.sentByEmail;
        return him;
    }

    public static Harvest_User__c transformUser(HarvestUser u) {
        Harvest_User__c hu = new Harvest_User__c();
        hu.Name = u.email;
        hu.Default_hourly_rate__c = convertDecimal(u.defaultHourlyRate);
        hu.Department__c = u.department;
        hu.Email__c = u.email;
        hu.First_name__c = u.firstName;
        hu.Harvest_ID__c = u.id;
        hu.Is_Active__c = u.isActive;
        hu.Is_Admin__c = u.isAdmin;
        hu.Is_Contractor__c = u.isContractor;
        hu.Last_name__c = u.lastName;
        hu.Phone__c = u.telephone;
        hu.Timezone__c = u.timeZone;
        return hu;
    }
    
	public static Harvest_Task__c transformTask(HarvestTask t) {
		Harvest_Task__c ht = new Harvest_Task__c();
		ht.Name = t.name;
		ht.Billable_by_default__c = t.billableByDefault;
		ht.Default_hourly_rate__c = convertDouble(t.defaultHourlyRate);
		ht.Harvest_ID__c = t.id;
		ht.Is_default__c = t.isDefault;
		return ht;
	}
    
    public static Harvest_Project__c transformProject(HarvestProject hp, Map<String, Id> accountMap) {
        Harvest_Project__c p = new Harvest_Project__c();
        p.Account__c = accountMap.get(hp.clientId);
        p.Name = hp.name;
        p.Bill_by__c = hp.billBy;
        p.Billable__c = hp.billable;
        if (hp.budget != '') p.Budget__c = Double.valueOf(hp.budget);
        else p.Budget__c = null;    
        p.Budget_by__c = getBudgetBy(hp.budgetBy);
        p.Harvest_ID__c = hp.id;
        p.Notes__c = hp.notes;
        p.Project_Code__c = hp.code;
        p.Active__c = hp.active;
        return p;
    }
    
	public static Harvest_Task_Assignment__c transformTaskAssignment(HarvestTaskAssignment hta, Map<String, Id> projectMap, Map<String, Id> taskMap) {
		Harvest_Task_Assignment__c ta = new Harvest_Task_Assignment__c();
		ta.Billable__c = hta.billable;
		ta.Budget__c = convertDouble(hta.budget);
		ta.Deactivated__c = hta.deactivated;
		ta.Harvest_ID__c = hta.id;
		ta.Hourly_rate__c = convertDouble(hta.hourlyRate);
		ta.Project__c = projectMap.get(hta.projectId);
		ta.Task__c = taskMap.get(hta.taskId);
		return ta;
	}
	
	public static Harvest_User_Assignment__c transformUserAssignment(HarvestUserAssignment hua, Map<String, Id> projectMap, Map<String, Id> userMap) {
		Harvest_User_Assignment__c ua = new Harvest_User_Assignment__c();
		ua.Harvest_ID__c = hua.id;
		ua.Harvest_User__c = userMap.get(hua.userid);
		ua.Hourly_rate__c = convertDecimal(hua.hourlyRate);
		ua.Is_Deactivated__c = hua.deactivated;
		ua.Is_Project_Manager__c = hua.isProjectManager;
		ua.Project__c = projectMap.get(hua.projectId);
		return ua;
	}
    
    public static Double convertDouble(String s) {
        if (s == '' || s == null)
            return null;
        else
            return Double.valueOf(s);
    }
    
    public static Decimal convertDecimal(String s) {
        if (s == '' || s == null)
            return null;
        else
            return Decimal.valueOf(s);
    }
    
    public static String getBudgetBy(String value) {
        if (value == '')
            return 'none';
        else if (value == 'No Budget')
            return 'none';
        else if (value == 'Total Project Hours')
            return 'project';
        else if (value == 'Total Project Fees')
            return 'project_cost';
        else if (value == 'Hours per task')
            return 'task';
        else if (value == 'Hours per person')
            return 'person';
        else if (value == 'none')
            return 'No Budget';
        else if (value == 'project')
            return 'Total Project Hours';
        else if (value == 'project_cost')
            return 'Total Project Fees';
        else if (value == 'task')
            return 'Hours per task';
        else if (value == 'person')
            return 'Hours per person';
        else
            return '';          
    }
    
    public static Map<String, Id> getHarvestAccountMap(set<String> clientIds) {
        Map<String, Id> returnMap = new Map<String, Id>();      
        for (Account a : [Select Id, Harvest_Id__c from Account where Harvest_Id__c in :clientIds]) {
            returnMap.put(a.Harvest_Id__c, a.Id);
        }
        return returnMap;
    }
    
    public static Map<String, Id> getHarvestProjectMap(set<String> projectIds) {
        Map<String, Id> returnMap = new Map<String, Id>();      
        for (Harvest_Project__c p : [Select Id, Harvest_Id__c from Harvest_Project__c where Harvest_Id__c in :projectIds]) {
            returnMap.put(p.Harvest_Id__c, p.Id);
        }
        return returnMap;
    }
            
    public static String getBillBy(String value) {
        if (value == null)
            return 'none';
        else
            return value;
    }
    
    public static Boolean convertBoolean(String bool) {
        if (bool == 'true')
            return true;
        else
            return false;
    }
    
    public static Date convertInvoiceDate(String s) {
        if (s == '' || s == null) {
            return null;
        } else {
            String[] dateArray = s.split('-');
            return Date.newInstance(Integer.valueOf(dateArray[0]), Integer.valueOf(dateArray[1]), Integer.valueOf(dateArray[2]));
        }
    }
    
    public static DateTime convertDateTime(String s) {
        if (s == '' || s == null) {
            return null;
        } else {
            String year = s.substring(0, 4);
            String month = s.substring(5, 7);
            String day = s.substring(8, 10);
            String hours = s.substring(11, 13);
            String minutes = s.substring(14, 16);
            String seconds = s.substring(17, 19);
            return DateTime.newInstanceGmt(
                Integer.valueOf(year), 
                Integer.valueOf(month), 
                Integer.valueOf(day), 
                Integer.valueOf(hours), 
                Integer.valueOf(minutes), 
                Integer.valueOf(seconds)
            );
        }
    }   
        
}