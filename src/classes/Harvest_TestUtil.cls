public class Harvest_TestUtil {
    public class HarvestTester extends Harvest {
        public HarvestTester() {
            super();
        } 
        
        public override Harvest__c getSettings() {
        	if (Harvest__c.getInstance() == null)
        		upsert new Harvest__c(SetupOwnerId=UserInfo.getOrganizationId());
			Harvest__c settings = Harvest__c.getOrgDefaults();
   			if (settings.Password__c == 'toolkittesting') {
   				return settings;
   			} else {
	   			settings.Create_Harvest_Project_Automatically__c = true;
	   			settings.Delete_Client_In_Harvest__c = true;
	   			settings.SSL__c = true;
	   			settings.Subdomain__c = 'somesubdomain';
	   			settings.Username__c = 'foo';
	   			settings.Password__c = 'toolkittesting';
		   		upsert settings; 
   			}
	   		return settings;		
        }
                
        public override String getBulkResponseBody(HttpResponse resp, HttpRequest req) {
            super.getResponseBody(resp, req);
            String ep = req.getEndpoint();
            System.debug(LoggingLevel.INFO, '\n\nGET RESPONSE FOR ' + ep + '\n\n');
            String body = '';
            if (ep.contains('harvestapp.com/clients/batch_create')) {
                System.debug(LoggingLevel.INFO, '\n\n BULK CLIENT CREATE VERIFY \n\n');
                body = bulkClientResponse;
            }
            System.debug(LoggingLevel.INFO, '\n\nReturning body: \n' + body + '\n\n');
            return body;
        }
        
        public override Dom.Document getResponseBody(HttpResponse resp, HttpRequest req) {
            super.getResponseBody(resp, req);
            String ep = req.getEndpoint();
            System.debug(LoggingLevel.INFO, '\n\nGET RESPONSE FOR ' + ep + '\n\n');
            String body = '';
            if (ep.contains('harvestapp.com/account/who_am_i')) {
                System.debug(LoggingLevel.INFO, '\n\n LOGIN VERIFY \n\n');
                body = whoAmIResponse;
            } else if (ep.contains('harvestapp.com/tasks')) {
                System.debug(LoggingLevel.INFO, '\n\n GET TASKS VERIFY \n\n');
                if (ep.endsWith('/'))
                	body = getTasksResponse;
            	else
            		body = getTaskResponse;
            } else if (ep.contains('harvestapp.com/clients/') && ep.contains('/contacts/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET CONTACTS VERIFY \n\n');
                body = getContactsForClientResponse;
            } else if (ep.contains('harvestapp.com/clients/unittest')) {
                System.debug(LoggingLevel.INFO, '\n\n GET CLIENT VERIFY \n\n');
                body = getClientResponse;
            } else if (ep.contains('harvestapp.com/contacts/unittest')) {
                System.debug(LoggingLevel.INFO, '\n\n GET CONTACT VERIFY \n\n');
                body = getContactResponse;
            } else if (ep.contains('harvestapp.com/projects/unittest')) {
                System.debug(LoggingLevel.INFO, '\n\n GET PROJECT VERIFY \n\n');
                body = getProjectResponse;
            } else if (ep.contains('harvestapp.com/invoices/unittest')) {
                System.debug(LoggingLevel.INFO, '\n\n GET INVOICE VERIFY \n\n');
                body = getInvoiceResponse;
            } else if (ep.contains('harvestapp.com/people/unittest')) {
                System.debug(LoggingLevel.INFO, '\n\n GET USER VERIFY \n\n');
                body = getUserResponse;
            } else if (ep.contains('harvestapp.com/clients/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET CLIENTS VERIFY \n\n');
                body = getClientsResponse;
            } else if (ep.contains('harvestapp.com/contacts/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET CONTACTS VERIFY \n\n');
                body = getContactsResponse;
            } else if (ep.contains('harvestapp.com/projects/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET PROJECTS VERIFY \n\n');
                body = getProjectsResponse;
            } else if (ep.contains('harvestapp.com/invoices/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET INVOICES VERIFY \n\n');
                body = getInvoicesResponse;
            } else if (ep.contains('harvestapp.com/invoices?client')) {
                System.debug(LoggingLevel.INFO, '\n\n GET INVOICES FOR CLIENT VERIFY \n\n');
                body = getInvoicesForClientResponse;
            } else if (ep.contains('harvestapp.com/projects?client')) {
                System.debug(LoggingLevel.INFO, '\n\n GET PROJECTS FOR CLIENT VERIFY \n\n');
                body = getProjectsForClientResponse;
            } else if (ep.contains('harvestapp.com/people/')) {
                System.debug(LoggingLevel.INFO, '\n\n GET PEOPLE VERIFY \n\n');
                body = getUsersResponse;
            }
            Dom.Document d = new Dom.Document();
            d.load(body);           
            System.debug(LoggingLevel.INFO, '\n\nReturning body: \n' + body + '\n\n');
            return d;
        }
        
        public override HarvestUser parseUser(Dom.XMLNode node) {
            return super.parseUser(node);
        }
        
        public override HttpRequest createRequest(String m, String p) {
            return super.createRequest(m,p);
        }
        
        public override HttpRequest createRequest(String m, String p, Map<String, String> parms) {
            return super.createRequest(m, p, parms);
        }
        
        public override HttpResponse execute(HttpRequest req) {
            HttpResponse r = new HttpResponse();
            return r;
        }
        
        public override String getLocationHeader(HttpResponse resp) {
            return '12345678901234567890';
        }

    }
    
    public static String whoAmIResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<hash>'+
                '<user>'+
                '<admin type="boolean">true</admin>'+
                '<timezone>Central Time (US &amp; Canada)</timezone>'+
                '<timestamp-timers type="boolean">false</timestamp-timers>'+
                '<email>harvest@mavensconsulting.com</email>'+
                '<id type="integer">xx999</id>'+
                '</user>'+
            '</hash>';
        }
    }
    
    public static String getClientsResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<clients type="array">'+
                '<client>'+
                    '<active type="boolean">true</active>'+
                    '<cache-version type="integer">1</cache-version>'+
                    '<currency>United States Dollars - USD</currency>'+
                    '<default-invoice-timeframe>20100201,20100228</default-invoice-timeframe>'+
                    '<details>4445 Boomi Way\nPhiladelphia, PA 19222\nUSA\n(999) 333-6666\n(333) 444-5555\nwww.boomi.com</details>'+
                    '<highrise-id type="integer" nil="true"></highrise-id>'+
                    '<id type="integer">000999</id>'+
                    '<name>Boomi test4</name>'+
                    '<updated-at type="datetime">2010-03-29T20:02:36Z</updated-at>'+
                    '<currency-symbol>$</currency-symbol>'+
                    '</client>'+
                '<client>'+
                    '<active type="boolean">true</active>'+
                    '<cache-version type="integer">3</cache-version>'+
                    '<currency>United States Dollars - USD</currency>'+
                    '<default-invoice-timeframe>20100101,20101231</default-invoice-timeframe>'+
                    '<details></details>'+
                    '<highrise-id type="integer" nil="true"></highrise-id>'+
                    '<id type="integer">vvv111</id>'+
                    '<name>Client Test 3</name>'+
                    '<updated-at type="datetime">2010-02-26T15:41:39Z</updated-at>'+
                    '<currency-symbol>$</currency-symbol>'+
                '</client>'+
                '<client>'+
                    '<active type="boolean">true</active>'+
                    '<cache-version type="integer">3</cache-version>'+
                    '<currency>United States Dollars - USD</currency>'+
                    '<default-invoice-timeframe>20100101,20101231</default-invoice-timeframe>'+
                    '<details></details>'+
                    '<highrise-id type="integer" nil="true"></highrise-id>'+
                    '<id type="integer">unittest</id>'+
                    '<name>unittest</name>'+
                    '<updated-at type="datetime">2010-02-26T15:41:39Z</updated-at>'+
                    '<currency-symbol>$</currency-symbol>'+
                '</client>'+
            '</clients>';
        }
    }
    
    public static String bulkClientResponse { get {
        Account a = new Account();
        a.Name = 'test account';
        insert a;
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<results>'+
              '<result>'+
                '<success type="boolean">true</success>'+
                '<harvest_id>201407</harvest_id>'+
                '<external_id>'+a.Id+'</external_id>'+
             '</result>'+
             '<result>'+
                '<success type="boolean">false</success>'+
                '<failure_reason>Failed to create client due to errors: Name cant be blank.</failure_reason>'+
                '<harvest_id></harvest_id>'+
                '<external_id>'+a.Id+'</external_id>'+
              '</result>'+
            '</results>';
        }
    }
    
    public static String getClientResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
                '<client>'+
                    '<active type="boolean">true</active>'+
                    '<cache-version type="integer">1</cache-version>'+
                    '<currency>United States Dollars - USD</currency>'+
                    '<default-invoice-timeframe>20100201,20100228</default-invoice-timeframe>'+
                    '<details>4445 Boomi Way\nPhiladelphia, PA 19222\nUSA\n(999) 333-6666\n(333) 444-5555\nwww.boomi.com</details>'+
                    '<highrise-id type="integer" nil="true"></highrise-id>'+
                    '<id type="integer">aaa222</id>'+
                    '<name>Boomi test4</name>'+
                    '<updated-at type="datetime">2010-03-29T20:02:36Z</updated-at>'+
                    '<currency-symbol>$</currency-symbol>'+
                '</client>';
        }
    }
    
    public static String getContactsResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<contacts type="array">'+
              '<contact>'+
                '<id type="integer">9</id>'+
                '<client-id type="integer">11072</client-id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<phone-office>555.555.5555</phone-office>'+
                '<phone-mobile>555.555.7777</phone-mobile>'+
                '<fax>555.555.9999</fax>'+
             '</contact>'+
              '<contact>'+
                '<id type="integer">9</id>'+
                '<client-id type="integer">vvv111</client-id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<phone-office>555.555.5555</phone-office>'+
                '<phone-mobile>555.555.7777</phone-mobile>'+
                '<fax>555.555.9999</fax>'+
             '</contact>'+
            '</contacts>';              
        }   
    }
    
    public static String getContactsForClientResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<contacts type="array">'+
              '<contact>'+
                '<id type="integer">12345c</id>'+
                '<client-id type="integer">abab123</client-id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<phone-office>555.555.5555</phone-office>'+
                '<phone-mobile>555.555.7777</phone-mobile>'+
                '<fax>555.555.9999</fax>'+
             '</contact>'+
            '</contacts>';              
        }   
    }
    
    public static String getContactResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
              '<contact>'+
                '<id type="integer">9</id>'+
                '<client-id type="integer">11072</client-id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<phone-office>555.555.5555</phone-office>'+
                '<phone-mobile>555.555.7777</phone-mobile>'+
                '<fax>555.555.9999</fax>'+
             '</contact>';
        }   
    }
    
    public static String getProjectsResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<projects type="array">'+
                '<project>'+
                  '<id type="integer">1</id>'+
                  '<name>SuprGlu</name>'+
                  '<active type="boolean">true</active>'+
                  '<billable type="boolean">false</billable>'+
                  '<bill-by>none</bill-by>'+
                  '<client-id type="integer">2</client-id>'+
                  '<code></code>'+
                  '<notes></notes>'+
                  '<budget-by>none</budget-by>'+
                  '<budget type="decimal"></budget>'+
                  '<fees></fees>'+
                '</project>' + 
            '</projects>';
        }   
    }
    
    public static String getProjectsForClientResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<projects type="array">'+
                '<project>'+
                  '<id type="integer">1</id>'+
                  '<name>SuprGlu</name>'+
                  '<active type="boolean">true</active>'+
                  '<billable type="boolean">false</billable>'+
                  '<bill-by>none</bill-by>'+
                  '<client-id type="integer">2</client-id>'+
                  '<code></code>'+
                  '<notes></notes>'+
                  '<budget-by>none</budget-by>'+
                  '<budget type="decimal"></budget>'+
                  '<fees></fees>'+
                '</project>' + 
            '</projects>';
        }   
    }
    
    public static String getProjectResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
                '<project>'+
                  '<id type="integer">1</id>'+
                  '<name>SuprGlu</name>'+
                  '<active type="boolean">true</active>'+
                  '<billable type="boolean">false</billable>'+
                  '<bill-by>none</bill-by>'+
                  '<client-id type="integer">2</client-id>'+
                  '<code></code>'+
                  '<notes></notes>'+
                  '<budget-by>none</budget-by>'+
                  '<budget type="decimal"></budget>'+
                  '<fees></fees>'+
                '</project>';
        }   
    }
    
    public static String getInvoicesResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<invoices type="array">' +
              '<invoice>' +
                '<id type="integer">8</id>' +
                '<amount type="decimal">1155.0</amount>' +
                '<due-amount type="decimal">0.0</due-amount>' +
                '<due-at type="date">2008-02-06</due-at>' +
                '<due-at-human-format>due upon receipt</due-at-human-format>' +
                '<period-end type="date" nil="true"></period-end>' +
                '<period-start type="date" nil="true"></period-start>' +
                '<client-id type="integer">46066</client-id>' +
                '<currency>United States Dollars - USD</currency>' +
                '<discount>123</discount>' +
                '<estimate-id>123</estimate-id>' +
                '<subject>test subject</subject>' +
                '<discount-amount>2.33</discount-amount>' +
                '<issued-at type="date">2008-02-06</issued-at>' +
                '<notes></notes>' +
                '<number>8008</number>' +
                '<purchase-order></purchase-order>' +
                '<state>paid</state>' +
                '<tax type="decimal" nil="true"></tax>' +
                '<tax2 type="decimal" nil="true"></tax2>' +
                '<tax-amount type="decimal" nil="true"></tax-amount>' +
                '<tax-amount2 type="decimal" nil="true"></tax-amount2>' +
                '<updated-at type="datetime">2008-04-09T12:07:56Z</updated-at>' +
                '<created-at type="datetime">2008-04-09T12:07:56Z</created-at>' +
              '</invoice>' +
            '</invoices>';
        }   
    }
    
    public static String getInvoiceResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
              '<invoice>' +
                '<id type="integer">8</id>' +
                '<amount type="decimal">1155.0</amount>' +
                '<due-amount type="decimal">0.0</due-amount>' +
                '<due-at type="date">2008-02-06</due-at>' +
                '<due-at-human-format>due upon receipt</due-at-human-format>' +
                '<period-end type="date" nil="true"></period-end>' +
                '<period-start type="date" nil="true"></period-start>' +
                '<client-id type="integer">46066</client-id>' +
                '<currency>United States Dollars - USD</currency>' +
                '<discount>123</discount>' +
                '<estimate-id>123</estimate-id>' +
                '<subject>test subject</subject>' +
                '<discount-amount>2.33</discount-amount>' +
                '<issued-at type="date">2008-02-06</issued-at>' +
                '<notes></notes>' +
                '<number>8008</number>' +
                '<purchase-order></purchase-order>' +
                '<state>paid</state>' +
                '<tax type="decimal" nil="true"></tax>' +
                '<tax2 type="decimal" nil="true"></tax2>' +
                '<tax-amount type="decimal" nil="true"></tax-amount>' +
                '<tax-amount2 type="decimal" nil="true"></tax-amount2>' +
                '<updated-at type="datetime">2008-04-09T12:07:56Z</updated-at>' +
                '<created-at type="datetime">2008-04-09T12:07:56Z</created-at>' +
                '<csv-line-items>kind,description,quantity,unit_price,amount,taxed,taxed2,project_id\nService,Security support / Apply upgrades,0.68,80.00,54.4,true,false,3</csv-line-items>'+             
              '</invoice>';
        }   
    }
    
    public static String getInvoicesForClientResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<invoices type="array">' +
              '<invoice>' +
                '<id type="integer">invoice123</id>' +
                '<amount type="decimal">1155.0</amount>' +
                '<due-amount type="decimal">0.0</due-amount>' +
                '<due-at type="date">2008-02-06</due-at>' +
                '<due-at-human-format>due upon receipt</due-at-human-format>' +
                '<period-end type="date" nil="true"></period-end>' +
                '<period-start type="date" nil="true"></period-start>' +
                '<client-id type="integer">abab123</client-id>' +
                '<currency>United States Dollars - USD</currency>' +
                '<discount>123</discount>' +
                '<estimate-id>123</estimate-id>' +
                '<subject>test subject</subject>' +
                '<discount-amount>2.33</discount-amount>' +
                '<issued-at type="date">2008-02-06</issued-at>' +
                '<notes></notes>' +
                '<number>8008</number>' +
                '<purchase-order></purchase-order>' +
                '<state>paid</state>' +
                '<tax type="decimal" nil="true"></tax>' +
                '<tax2 type="decimal" nil="true"></tax2>' +
                '<tax-amount type="decimal" nil="true"></tax-amount>' +
                '<tax-amount2 type="decimal" nil="true"></tax-amount2>' +
                '<updated-at type="datetime">2008-04-09T12:07:56Z</updated-at>' +
                '<created-at type="datetime">2008-04-09T12:07:56Z</created-at>' +
                '<csv-line-items>kind,description,quantity,unit_price,amount,taxed,taxed2,project_id\nService,Security support / Apply upgrades,0.68,80.00,54.4,true,false,3</csv-line-items>'+             
              '</invoice>' +
          '</invoices>';
        }   
    }
    
    public static String getUsersResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<users type="array">'+
              '<user>'+
                '<id type="integer">54234</id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<has-access-to-all-future-projects type="boolean">false</has-access-to-all-future-projects>'+
                '<default-hourly-rate type="decimal">100</default-hourly-rate>'+
                '<is-active type="boolean">true</is-active>'+
                '<is-admin type="boolean">true</is-admin>'+
                '<is-contractor type="boolean">true</is-contractor>'+
                '<telephone></telephone>'+
                '<department></department>'+
                '<timezone>Eastern Time</timezone>'+
               '</user>'+
            '</users>';
        }   
    }
    
    public static String getUserResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
              '<user>'+
                '<id type="integer">54234</id>'+
                '<email>Jane@Doe.com</email>'+
                '<first-name>Jane</first-name>'+
                '<last-name>Doe</last-name>'+
                '<has-access-to-all-future-projects type="boolean">false</has-access-to-all-future-projects>'+
                '<default-hourly-rate type="decimal">100</default-hourly-rate>'+
                '<is-active type="boolean">true</is-active>'+
                '<is-admin type="boolean">true</is-admin>'+
                '<is-contractor type="boolean">true</is-contractor>'+
                '<telephone></telephone>'+
                '<department></department>'+
                '<timezone>Eastern Time</timezone>'+
               '</user>';
        }   
    }
    
    public static String getTasksResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
			'<tasks type="array">' +
				'<task>' +
				  '<billable-by-default type="boolean">true</billable-by-default>' +
				  '<deactivated type="boolean">false</deactivated>' +
				  '<default-hourly-rate type="decimal">120</default-hourly-rate>' +
				  '<id type="integer">1</id>' +
				  '<is-default type="boolean">true</is-default>' +
				  '<name>UI Design</name>' +
				'</task>' +
			'</tasks>';
        }   
    }
    
    public static String getTaskResponse { get {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
			'<task>' +
			  '<billable-by-default type="boolean">true</billable-by-default>' +
			  '<deactivated type="boolean">false</deactivated>' +
			  '<default-hourly-rate type="decimal">120</default-hourly-rate>' +
			  '<id type="integer">1</id>' +
			  '<is-default type="boolean">true</is-default>' +
			  '<name>UI Design</name>' +
			'</task>';
        }   
    }
    
    public static HarvestClient getClient() {
        HarvestClient c = new HarvestClient();
        c.id = '1234';
        c.name = 'unittest';
        c.active = true;
        c.details = 'some details';
        return c;       
    }
    
    public static HarvestContact getContact() {
        HarvestContact c = new HarvestContact();
        c.id = 'ababab123';
        c.clientid = '1234';
        c.firstname = 'michael';
        c.lastname = 'smith';
        c.email = 'some@email.com';
        c.fax = '3334445555';
        c.phone = '4445556666';
        c.mobile = '1112223333';
        return c;       
    }
    
    public static HarvestProject getProject() {
        HarvestProject p = new HarvestProject();
        p.id = '4445555';
        p.active = true;
        p.billable = true;
        p.billBy = 'Person';
        p.budget = '3000';
        p.budgetBy = 'Hours';
        p.clientId = '1234';
        p.code = '333444';
        p.fees = '12345';
        p.name = 'unittest project';
        p.notes = 'some notes';
        return p;
    }
    
    public static HarvestUser getUser() {
        HarvestUser u = new HarvestUser();
        u.defaultHourlyRate = '22';
        u.department = 'test';
        u.email = 'rg@rg.com';
        u.firstName = 'matt';
        u.hasAccessToAllFutureProjects = true;
        u.id = '1112222';
        u.isActive = true;
        u.isAdmin = true;
        u.isContractor = true;
        u.lastName = 'smith';
        u.telephone = '3334445555';
        u.timeZone = 'Eastern';
        return u;
    }
    
    public static HarvestTask getTask() {
        HarvestTask t = new HarvestTask();
		t.name = 'foo';
		t.id = 'bar';
		t.billableByDefault = true;
		t.deactivated = false;
		t.defaultHourlyRate = '10';
		t.isDefault = true;
        return t;
    }
    
    public static HarvestInvoice getInvoice() {
        HarvestInvoice i = new HarvestInvoice();
        i.amount = '1000';
        i.clientId = '1234';
        i.createdAt = '2009-10-10';
        i.currencyName = 'USD';
        i.discount = 'none';
        i.discountAmount = 'none';
        i.dueAmount = '900';
        i.dueAt = '2009-10-10';
        i.estimate = '300';
        i.id = 'inv123';
        i.invoiceNumber = '333222';
        i.issuedAt = 'fdfds';
        i.notes = 'some notes';
        i.state = 'va';
        i.subject = 'a subject line';
        return i;
    }
}