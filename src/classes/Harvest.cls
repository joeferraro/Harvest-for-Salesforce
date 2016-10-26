public virtual class Harvest {
	// 
	// Apex Client wrapper for the Harvest API
	//
	// See Harvest REST API documentation
	// http://www.getharvest.com/api
	
	public String loginResponse { get; set; }
	public String username;
	public String password;
	public HarvestUser user;  
    private Harvest__c settings { get; set; }
    
	public virtual class HarvestException extends Exception { }
	
	public Harvest() { 
        this.settings = getSettings();
		this.user = login(settings.Username__c, settings.Password__c);
	}
	
	public virtual Harvest__c getSettings() {
		Harvest__c s = Harvest__c.getOrgDefaults();
		if (s == null) upsert s;
		return s;
	}
		
	public virtual HarvestUser login(String un, String pw) {
		HarvestUser u;
		this.username = un;
		this.password = pw;
		HttpRequest req = createRequest('GET', 'account/who_am_i');
		HttpResponse resp = execute(req);
		system.debug('#### xml response: ' + resp.getBody());
		if (resp.getStatusCode() != 200 && pw != 'toolkittesting') {
			throw new HarvestException('Your login failed, please verify your credentials and SSL support are setup correctly');
			return null;
		}

		Dom.Document doc = this.getResponseBody(resp, req);
		Dom.XMLNode request = doc.getRootElement();
		Dom.XMLNode user = request.getChildElement('user', null);

		if (resp.getStatusCode() == 200 || pw.equals('toolkittesting')) {
			u = parseWhoAmI(user);
		}
		return u;
	}
	
	protected virtual Dom.Document getResponseBody(HttpResponse resp, HttpRequest req) {
		if (resp.getBody() == null)
			return null;
		else
			return resp.getBodyDocument();
	}
	
	protected virtual HttpRequest createRequest(String method, String path) {
    	HttpRequest req = new HttpRequest();
     	req.setHeader('Accept', 'application/xml');
     	req.setHeader('Content-Type', 'application/xml');
     	String endpoint = '';
     	if (this.settings.SSL__c == true) endpoint += 'https://';
     	else endpoint += 'http://';
     	endpoint += this.settings.Subdomain__c + '.harvestapp.com/' + path;
     	req.setEndpoint(endpoint);
     	system.debug('ENDPOINT IS: ' + endpoint);
     	//req.setEndpoint(this.settings.Domain__c + '/' + path);
      	req.setMethod(method == null ? 'GET' : method);      	
      	Blob headerValue = Blob.valueOf(this.username + ':' + this.password);
      	String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
      	req.setHeader('Authorization', authorizationHeader);
      	system.debug('\n\n\n\n\n\n\n\nHEADER\n\n\n\n\nn\n\n\n\n\n' + req.getHeader('Authorization') + '\n\n\n\n\n\nn\n\n\n\n\n\n\n\n\n');
      	return req;
    }
    
	public virtual HttpRequest createRequest(String method, String path, map<String, String> params) {
		String paramString = '';
		for (String key : params.keySet()) {
			if (params.get(key) != null) {
				paramString += '<'+key+'>' + params.get(key) + '</'+key+'>';
			}
		}

		HttpRequest r = createRequest(method, path);
		if (paramString.length() > 0) {
			r.setBody(paramString);
		}
		return r;
	}
	
	public virtual HttpRequest createBulkRequest(String method, String path, List<map<String, String>> paramList) {
		String paramString = '';
		for (Map<String, String> params : paramList) {
			paramString += '<client>';
			for (String key : params.keySet()) {
				if (params.get(key) != null) {
					paramString += '<'+key+'>' + params.get(key) + '</'+key+'>';
				}
			}
			paramString += '</client>';
		}

		HttpRequest r = createRequest(method, path);
		if (paramString.length() > 0) {
			r.setBody(paramString);
		}
		return r;
	}
			
	protected virtual HttpResponse execute(HttpRequest req) {
      	HttpResponse res = new http().send(req);
      	return res;
    }
			
	public HarvestClient getClient(String clientId) {
		HttpRequest req = createRequest('GET', 'clients/'+clientId);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseClient(this.getResponseBody(resp, req).getRootElement());
	}
	
	public HarvestContact getContact(String contactId) {
		HttpRequest req = createRequest('GET', 'contacts/'+contactId);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseContact(this.getResponseBody(resp, req).getRootElement());
	}
	
	public HarvestProject getProject(String projectId) {
		HttpRequest req = createRequest('GET', 'projects/'+projectId);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseProject(this.getResponseBody(resp, req).getRootElement());
	}
		
	public HarvestUser getUser(String userId) {
		HttpRequest req = createRequest('GET', 'people/'+userId);
		HttpResponse resp = execute(req);
		return parseUser(this.getResponseBody(resp, req).getRootElement());
	}
		
	public HarvestInvoice getInvoice(String invoiceId) {
		HttpRequest req = createRequest('GET', 'invoices/'+invoiceId);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseInvoice(this.getResponseBody(resp, req).getRootElement());
	}
	
	public HarvestTask getTask(String taskId) {
		HttpRequest req = createRequest('GET', 'tasks/'+taskId);
		HttpResponse resp = execute(req);
		return parseTask(this.getResponseBody(resp, req).getRootElement());
	}
		
	public List<HarvestClient> getClients() {
		HttpRequest req = createRequest('GET', 'clients/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseClients(this.getResponseBody(resp, req));
	}
	
	public List<HarvestClient> getClientsUpdatedSince(DateTime dt) {
		String dtString = dt.formatGmt('yyyy-MM-dd+hh:mm');
		//dtString = EncodingUtil.urlEncode(dtString, 'UTF-8'); this doesnt seem to be needed
		HttpRequest req = createRequest('GET', 'clients?updated_since='+dtString);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseClients(this.getResponseBody(resp, req));
	}
	
	public List<HarvestContact> getContactsUpdatedSince(DateTime dt) {
		String dtString = dt.formatGmt('yyyy-MM-dd+hh:mm');
		HttpRequest req = createRequest('GET', 'contacts?updated_since='+dtString);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseContacts(this.getResponseBody(resp, req));
	}
	
	public List<HarvestProject> getProjectsUpdatedSince(DateTime dt) {
		String dtString = dt.formatGmt('yyyy-MM-dd+hh:mm');
		HttpRequest req = createRequest('GET', 'projects?updated_since='+dtString);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseProjects(this.getResponseBody(resp, req));
	}
		
	public List<HarvestContact> getContacts() {
		HttpRequest req = createRequest('GET', 'contacts/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseContacts(this.getResponseBody(resp, req));
	}
	
	public List<HarvestContact> getContactsForClient(String clientId) {
		HttpRequest req = createRequest('GET', 'clients/'+clientId+'/contacts/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseContacts(this.getResponseBody(resp, req));
	}
	
	public List<HarvestProject> getProjects() {
		HttpRequest req = createRequest('GET', 'projects/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseProjects(this.getResponseBody(resp, req));
	}
	
	public List<HarvestProject> getProjectsForClient(String clientId) {
		system.debug('getting projects for: ' + clientId);
		HttpRequest req = createRequest('GET', 'projects?client='+clientId);
		HttpResponse resp = execute(req);
		system.debug('projects for that client: \n\n\n\n\n\n\n\n\n\n' + resp.getBody());
		return parseProjects(this.getResponseBody(resp, req));
	}
	
	public List<HarvestInvoiceMessage> getInvoiceMessages(String invoiceId) {
		HttpRequest req = createRequest('GET', 'invoices/'+invoiceId+'/messages');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseInvoiceMessages(this.getResponseBody(resp, req));
	}
	
	public List<HarvestUser> getUsers() {
		HttpRequest req = createRequest('GET', 'people/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseUsers(this.getResponseBody(resp, req));
	}
	
	public List<HarvestTask> getTasks() {
		HttpRequest req = createRequest('GET', 'tasks/');
		HttpResponse resp = execute(req);
		return parseTasks(this.getResponseBody(resp, req));
	}
	
 	public virtual List<HarvestUserAssignment> getUserAssignments(String projectId) {
		HttpRequest req = createRequest('GET', 'projects/'+projectId+'/user_assignments');
		HttpResponse resp = execute(req);
		return parseUserAssignments(this.getResponseBody(resp, req));
	}
	
	public List<HarvestTaskAssignment> getTaskAssignments(String projectId) {
		HttpRequest req = createRequest('GET', 'projects/'+projectId+'/task_assignments');
		HttpResponse resp = execute(req);
		return parseTaskAssignments(this.getResponseBody(resp, req));
	}
			
	public List<HarvestInvoice> getInvoices() {
		HttpRequest req = createRequest('GET', 'invoices/');
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseInvoices(this.getResponseBody(resp, req));
	} 
	
	public List<HarvestInvoice> getInvoicesByPage(Integer i) {
		HttpRequest req = createRequest('GET', 'invoices?page='+i);
		HttpResponse resp = execute(req); 
		system.debug(resp.getBody());
		return parseInvoices(this.getResponseBody(resp, req));
	} 
	
	public List<HarvestInvoice> getInvoicesForClient(String clientId) {
		HttpRequest req = createRequest('GET', 'invoices?client='+clientId);
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		return parseInvoices(this.getResponseBody(resp, req));
	} 
		
	protected virtual HarvestClient parseClient(Dom.XMLNode node) {
		HarvestClient client = null;
		if (node.getName().equalsIgnoreCase('client')) {
			client = new HarvestClient();
			client.id = node.getChildElement('id', null).getText();
			client.name = node.getChildElement('name', null).getText();
			client.active = HarvestUtil.convertBoolean(node.getChildElement('active', null).getText());
			client.details = node.getChildElement('details', null).getText();	
		}	 
		return client;
	}
	
	protected virtual HarvestContact parseContact(Dom.XMLNode node) {
		HarvestContact contact = null;
		if (node.getName().equalsIgnoreCase('contact')) {
    		contact = new HarvestContact();
    		contact.id = node.getChildElement('id', null).getText();
    		contact.clientId = node.getChildElement('client-id', null).getText();
    		contact.email = node.getChildElement('email', null).getText();
    		contact.firstname = node.getChildElement('first-name', null).getText();
    		contact.lastname = node.getChildElement('last-name', null).getText();
    		contact.phone = node.getChildElement('phone-office', null).getText();
    		contact.mobile = node.getChildElement('phone-mobile', null).getText();
    		contact.fax = node.getChildElement('fax', null).getText();
		}	
		return contact;
	}
	
	protected virtual HarvestProject parseProject(Dom.XMLNode node) {
		HarvestProject project = null;
		if (node.getName().equalsIgnoreCase('project')) {
    		project = new HarvestProject();
    		project.id = node.getChildElement('id', null).getText();
    		project.name = node.getChildElement('name', null).getText();
    		project.active = HarvestUtil.convertBoolean(node.getChildElement('active', null).getText());
    		project.billable = HarvestUtil.convertBoolean(node.getChildElement('billable', null).getText());
    		project.billBy = node.getChildElement('bill-by', null).getText();
    		project.clientId = node.getChildElement('client-id', null).getText();
    		project.code = node.getChildElement('code', null).getText();
    		project.notes = node.getChildElement('notes', null).getText();
    		project.budgetBy = node.getChildElement('budget-by', null).getText();
    		project.budget = node.getChildElement('budget', null).getText();
    		//project.fees = node.getChildElement('fees', null).getText(); seems to be off the model
    		project.hourlyRate  = HarvestUtil.convertDecimal(node.getChildElement('hourly-rate', null).getText());
            project.notifyWhenOverBudget  = HarvestUtil.convertBoolean(node.getChildElement('notify-when-over-budget', null).getText());
    		project.overBudgetPercentage  = HarvestUtil.convertDecimal(node.getChildElement('over-budget-notification-percentage', null).getText());
            project.overBudgetNotifiedAt  = node.getChildElement('over-budget-notified-at', null).getText();
    		project.budgetToAll  = HarvestUtil.convertBoolean(node.getChildElement('show-budget-to-all', null).getText());
            project.createdAt  = HarvestUtil.convertDateTime(node.getChildElement('created-at', null).getText());
    		project.updatedAt  = HarvestUtil.convertDateTime(node.getChildElement('updated-at', null).getText());
    		project.endsOn = HarvestUtil.convertDate(node.getChildElement('ends-on', null).getText());
    		project.estimate  = HarvestUtil.convertDecimal(node.getChildElement('estimate', null).getText());
    		project.estimateBy  = node.getChildElement('estimate-by', null).getText();
    		project.hintEarliestRecordAt  = HarvestUtil.convertDate(node.getChildElement('hint-earliest-record-at', null).getText());
    		project.hintLatestRecordAt  = HarvestUtil.convertDate(node.getChildElement('hint-latest-record-at', null).getText());
    		project.costBudget  = node.getChildElement('cost-budget', null).getText();
    		project.costBuddgetIncludeExpenses  = HarvestUtil.convertBoolean(node.getChildElement('cost-budget-include-expenses', null).getText());
    		
		}	
		return project;
	}
	
	protected virtual HarvestUser parseWhoAmI(Dom.XmlNode node) {
		HarvestUser u = null;		
		if (node.getName().equalsIgnoreCase('user')) {
			u = new HarvestUser();
			u.id = node.getChildElement('id', null).getText();
			u.email = node.getChildElement('email', null).getText();
			u.timeZone = node.getChildElement('timezone', null).getText();
			u.isAdmin = HarvestUtil.convertBoolean(node.getChildElement('admin', null).getText());
			
		}
		return u;
	}
	
	protected virtual HarvestUser parseUser(Dom.XMLNode node) {		
		HarvestUser u = null;		
		if (node.getName().equalsIgnoreCase('user')) {
			u = new HarvestUser();
			u.id = node.getChildElement('id', null).getText();
			u.email = node.getChildElement('email', null).getText();
			u.firstname = node.getChildElement('first-name', null).getText();
			u.lastname = node.getChildElement('last-name', null).getText();
			u.hasAccessToAllFutureProjects = HarvestUtil.convertBoolean(node.getChildElement('has-access-to-all-future-projects', null).getText());
			u.defaultHourlyRate = node.getChildElement('default-hourly-rate', null).getText();
			u.isActive = HarvestUtil.convertBoolean(node.getChildElement('is-active', null).getText());
			u.isAdmin = HarvestUtil.convertBoolean(node.getChildElement('is-admin', null).getText());
			u.isContractor = HarvestUtil.convertBoolean(node.getChildElement('is-contractor', null).getText());
			u.telephone = node.getChildElement('telephone', null).getText();
			u.department = node.getChildElement('department', null).getText();
			u.timeZone = node.getChildElement('timezone', null).getText();			
		}
		return u;
	}
	
	protected virtual HarvestInvoiceMessage parseInvoiceMessage(Dom.XMLNode node) {		
		HarvestInvoiceMessage im = null;		
		if (node.getName().equalsIgnoreCase('invoice-message')) {
			im = new HarvestInvoiceMessage();
			im.body = node.getChildElement('body', null).getText();
			im.createdAt = node.getChildElement('created-at', null).getText();
			im.fullRecipientList = node.getChildElement('full-recipient-list', null).getText();
			im.id = node.getChildElement('id', null).getText();
			im.invoiceId = node.getChildElement('invoice-id', null).getText();
			im.sendMeACopy = HarvestUtil.convertBoolean(node.getChildElement('send-me-a-copy', null).getText());
			im.sentBy = node.getChildElement('sent-by', null).getText();
			im.sentByEmail = node.getChildElement('sent-by-email', null).getText();
		}
		return im;
	}
		 	
	protected virtual HarvestInvoice parseInvoice(Dom.XMLNode node) {
		system.debug('INVOICE NODE: ' + node);
		HarvestInvoice invoice = null;
		if (node.getName().equalsIgnoreCase('invoice')) {
    		invoice = new HarvestInvoice();
    		invoice.id = node.getChildElement('id', null).getText();
    		invoice.amount = node.getChildElement('amount', null).getText();
    		if (node.getChildElement('discount', null) != null)
    			invoice.discount = node.getChildElement('discount', null).getText();
    		if (node.getChildElement('discount-amount', null) != null)
    			invoice.discountAmount = node.getChildElement('discount-amount', null).getText();
    		invoice.dueAmount = node.getChildElement('due-amount', null).getText();
    		invoice.dueAt = node.getChildElement('due-at', null).getText();
    		invoice.dueAtHumanFormat = node.getChildElement('due-at-human-format', null).getText();
    		if (node.getChildElement('estimate-id', null) != null)
    			invoice.estimate = node.getChildElement('estimate-id', null).getText();
    		invoice.periodEnd = node.getChildElement('period-end', null).getText();
    		invoice.periodStart = node.getChildElement('period-start', null).getText();
    		invoice.clientId = node.getChildElement('client-id', null).getText();
    		invoice.currencyName = node.getChildElement('currency', null).getText();
    		invoice.issuedAt = node.getChildElement('issued-at', null).getText();
    		invoice.notes = node.getChildElement('notes', null).getText();
    		invoice.invoiceNumber = node.getChildElement('number', null).getText();
    		invoice.purchaseOrder = node.getChildElement('purchase-order', null).getText();
    		invoice.state = node.getChildElement('state', null).getText();
    		if (node.getChildElement('subject', null) != null)
    			invoice.subject = node.getChildElement('subject', null).getText();
    		invoice.tax1 = node.getChildElement('tax', null).getText();
    		invoice.tax2 = node.getChildElement('tax2', null).getText();
    		invoice.taxAmount = node.getChildElement('tax-amount', null).getText();
    		if (node.getChildElement('tax2-amount', null) != null)
    			invoice.taxAmount2 = node.getChildElement('tax2-amount', null).getText();
    		invoice.updatedAt = node.getChildElement('updated-at', null).getText();
    		invoice.createdAt = node.getChildElement('created-at', null).getText();    		
    		if (node.getChildElement('csv-line-items', null)!= null)
    			invoice.invoiceLines = parseInvoiceLines(node.getChildElement('csv-line-items', null).getText());
    		
		}	 
		return invoice;
	}
	
	protected virtual HarvestTask parseTask(Dom.XMLNode node) {
		HarvestTask task = null;
		if (node.getName().equalsIgnoreCase('task')) {
    		task = new HarvestTask(); 
    		task.id = node.getChildElement('id', null).getText();
    		task.billableByDefault = HarvestUtil.convertBoolean(node.getChildElement('billable-by-default', null).getText());
    		task.deactivated = HarvestUtil.convertBoolean(node.getChildElement('deactivated', null).getText());
    		task.defaultHourlyRate = node.getChildElement('default-hourly-rate', null).getText();
    		task.isDefault = HarvestUtil.convertBoolean(node.getChildElement('is-default', null).getText());
    		task.name = node.getChildElement('name', null).getText();
		}	 
		return task;
	}
	
	protected virtual HarvestUserAssignment parseUserAssignment(Dom.XMLNode node) {
		HarvestUserAssignment u = null;
		if (node.getName().equalsIgnoreCase('user-assignment')) {
			u = new HarvestUserAssignment();
			u.id = node.getChildElement('id', null).getText();
			u.userId = node.getChildElement('user-id', null).getText();
			u.projectId = node.getChildElement('project-id', null).getText();
			u.deactivated = HarvestUtil.convertBoolean(node.getChildElement('deactivated', null).getText());
			u.hourlyRate = node.getChildElement('hourly-rate', null).getText();
			u.isProjectManager = HarvestUtil.convertBoolean(node.getChildElement('is-project-manager', null).getText());
		}
		return u;
	}
	
	protected virtual HarvestTaskAssignment parseTaskAssignment(Dom.XMLNode node) {		
		HarvestTaskAssignment t = null;		
		if (node.getName().equalsIgnoreCase('task-assignment')) {
			t = new HarvestTaskAssignment();
			t.id = node.getChildElement('id', null).getText();
			t.projectId = node.getChildElement('project-id', null).getText();
			t.taskId = node.getChildElement('task-id', null).getText();
			t.billable = HarvestUtil.convertBoolean(node.getChildElement('billable', null).getText());
			t.deactivated = HarvestUtil.convertBoolean(node.getChildElement('deactivated', null).getText());
			t.budget = node.getChildElement('budget', null).getText(); 
			t.hourlyRate = node.getChildElement('hourly-rate', null).getText();
		}
		return t;
	}
	
	private List<HarvestTaskAssignment> parseTaskAssignments(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestTaskAssignment> assignments = new List<HarvestTaskAssignment>();
		for(Dom.XMLNode child : request.getChildElements()) {
			assignments.add(parseTaskAssignment(child));
		}		
		return assignments;
	}
	
	private List<HarvestInvoiceLine> parseInvoiceLines(String csvLines) {
		List<HarvestInvoiceLine> invoiceLines = new List<HarvestInvoiceLine>();
		String[] rows = csvLines.split('\n');
		for(String row : rows) {
			String[] cells = row.split(',');
			HarvestInvoiceLine line = new HarvestInvoiceLine();
			for (Integer i=0; i<cells.size(); i++) {
				if (i == 0)
					line.kind = cells[i];
				else if (i == 1)
					line.description = cells[i];
				else if (i == 2)
					line.quantity = cells[i];
				else if (i == 3)
					line.unitPrice = cells[i];
				else if (i == 4)
					line.amount = cells[i];
				else if (i == 5)
					line.taxed = cells[i];
				else if (i == 6)
					line.taxed2 = cells[i];
				else if (i == 7)
					line.projectId = cells[i];
			}
			invoiceLines.add(line);
		}		
		return invoiceLines;
	}
	
	private List<HarvestClient> parseClients(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestClient> clients = new List<HarvestClient>();
		for(Dom.XMLNode child : request.getChildElements()) {
        	clients.add(parseClient(child));
		}		
		return clients;
	}
	
	private List<HarvestContact> parseContacts(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestContact> contacts = new List<HarvestContact>();
		for(Dom.XMLNode child : request.getChildElements()) {
			contacts.add(parseContact(child));
		}		
		return contacts;
	}
	
	private List<HarvestProject> parseProjects(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestProject> projects = new List<HarvestProject>();
		for(Dom.XMLNode child : request.getChildElements()) {
			projects.add(parseProject(child));
		}		
		return projects;
	}
	
	private List<HarvestUser> parseUsers(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestUser> users = new List<HarvestUser>();
		for(Dom.XMLNode child : request.getChildElements()) {
			users.add(parseUser(child));
		}		
		return users;
	}
	
	private virtual List<HarvestTask> parseTasks(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestTask> tasks = new List<HarvestTask>();
		for(Dom.XMLNode child : request.getChildElements()) {
			tasks.add(parseTask(child));
		}		
		return tasks;
	}
	
	private List<HarvestInvoice> parseInvoices(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestInvoice> invoices = new List<HarvestInvoice>();
		for(Dom.XMLNode child : request.getChildElements()) {
			invoices.add(parseInvoice(child));
		}		
		return invoices;
	}
		
	private List<HarvestInvoiceMessage> parseInvoiceMessages(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestInvoiceMessage> messages = new List<HarvestInvoiceMessage>();
		for(Dom.XMLNode child : request.getChildElements()) {
			messages.add(parseInvoiceMessage(child));
		}		
		return messages;
	}
	
 	private List<HarvestUserAssignment> parseUserAssignments(Dom.Document doc) {
		Dom.XMLNode request = doc.getRootElement();
		List<HarvestUserAssignment> assignments = new List<HarvestUserAssignment>();
		for(Dom.XMLNode child : request.getChildElements()) {
			assignments.add(parseUserAssignment(child));
		}
		return assignments;
	}
						
	public String insertClient(map<String, String> params) {
		try {
			HttpRequest req = createRequest('POST', 'clients/', params);
			req.setBody('<client>'+req.getBody()+'</client>');	
			HttpResponse resp = execute(req);
			String loc = this.getLocationHeader(resp);
			loc = loc.substring(loc.lastIndexOf('/') + 1, loc.length());
			return loc;
		} catch(Exception e) { 
			system.debug(e); 
			return null;
		}
	}
	
	public virtual String getLocationHeader(HttpResponse resp) {
		if (resp.getBody() == null)
			return null;
		else {
			return resp.getHeader('Location');
		}
	}
	
	public virtual String getBulkResponseBody(HttpResponse resp, HttpRequest req) {
		if (resp.getBody() == null)
			return null;
		else
			return resp.getBody();
	}
	
	public String insertClients(List<map<String, String>> params) {
		HttpRequest req = createBulkRequest('POST', 'clients/batch_create', params);
		req.setBody('<clients>'+req.getBody()+'</clients>');	
		HttpResponse resp = execute(req);
		system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@: ' + resp.getBody());
		Dom.Document doc = new Dom.Document();
		doc.load(this.getBulkResponseBody(resp, req));
		Dom.XMLNode results = doc.getRootElement();
		List<Account> accounts = new List<Account>();
		Map<Id, String> responseMap = new Map<Id, String>();
		for(Dom.XMLNode child : results.getChildElements()) {
			if (child.getName() == 'result') {
				System.debug('###: ' + child.getChildElement('harvest_id', null).getText());
				String harvestId = child.getChildElement('harvest_id', null).getText();
				String accountId = child.getChildElement('external_id', null).getText();
				responseMap.put(accountId, harvestId);
			}
    	}
    	for (Account a : [Select Id from Account where Id in :responseMap.keySet()]) {
    		a.Harvest_ID__c = responseMap.get(a.Id);
    		a.Sync_to_Harvest__c = true;
    		a.isActiveHarvestClient__c = true;
    		accounts.add(a);
    	}
    	HarvestAsyncControl.inFutureContext = true;
    	update accounts;
		return null;
	}
		
	public String insertClientContact(map<String, String> params) {
		HttpRequest req = createRequest('POST', 'contacts/', params);
		req.setBody('<contact>'+req.getBody()+'</contact>');	
		HttpResponse resp = execute(req);
		String loc = this.getLocationHeader(resp);
		loc = loc.substring(loc.lastIndexOf('/') + 1, loc.length());
		return loc;
	}
			
	public String insertProject(map<String, String> params) {
		HttpRequest req = createRequest('POST', 'projects/', params);
		req.setBody('<project>'+req.getBody()+'</project>');	
		HttpResponse resp = execute(req);
		system.debug('\n\n\nCREATE PROJECT RESPONSE\n\n'+resp+'\n\n\n\n\nEND CREATE PROJECT RESPONSE');
		String loc = this.getLocationHeader(resp);
		loc = loc.substring(loc.lastIndexOf('/') + 1, loc.length());
		return loc;
	}
		
	public String insertUser(map<String, String> params) {
		HttpRequest req = createRequest('POST', 'people/', params);
		req.setBody('<user>'+req.getBody()+'</user>');	
		HttpResponse resp = execute(req);
		system.debug(resp.getBody());
		String loc = this.getLocationHeader(resp);
		loc = loc.substring(loc.lastIndexOf('/') + 1, loc.length());
		return loc;
	}
	
	public String updateClient(String clientId, map<String, String> params) {
		HttpRequest req = createRequest('PUT', 'clients/'+clientId, params);
		req.setBody('<client>'+req.getBody()+'</client>');	
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String updateClientContact(String clientId, map<String, String> params) {
		HttpRequest req = createRequest('PUT', 'contacts/'+clientId, params);
		req.setBody('<contact>'+req.getBody()+'</contact>');	
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String updateProject(String projectId, map<String, String> params) {
		HttpRequest req = createRequest('PUT', 'projects/'+projectId, params);
		req.setBody('<project>'+req.getBody()+'</project>');	
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String updateUser(String userId, map<String, String> params) {
		HttpRequest req = createRequest('PUT', 'people/'+userId, params);
		req.setBody('<user>'+req.getBody()+'</user>');	
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
			
	public String deleteClient(String clientId) {
		HttpRequest req = createRequest('DELETE', 'clients/'+clientId);
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String deleteClientContact(String clientId) {
		HttpRequest req = createRequest('DELETE', 'contacts/'+clientId);
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String deleteProject(String projectId) {
		HttpRequest req = createRequest('DELETE', 'projects/'+projectId);
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String deleteUser(String userId) {
		HttpRequest req = createRequest('DELETE', 'people/'+userId);
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}	
			
	public String toggleClient(String clientId) {
		HttpRequest req = createRequest('POST', 'clients/'+clientId+'/toggle');
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String toggleProject(String projectId) {
		HttpRequest req = createRequest('POST', 'projects/'+projectId+'/toggle');
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
	
	public String toggleUser(String userId) {
		HttpRequest req = createRequest('POST', 'people/'+userId+'/toggle');
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
		
	public String resetUserPassword(String userId) {
		HttpRequest req = createRequest('PUT', 'people/'+userId+'/reset_password');
		HttpResponse resp = execute(req);
		system.debug('#############:   ' + resp.getBody());
		return null;
	}
}