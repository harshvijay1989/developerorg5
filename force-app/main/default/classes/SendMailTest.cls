@isTest
public class SendMailTest {

    @isTest
    static void testSendEmailWithPDF() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'Test Contact', Email = 'test@test.com', AccountId = testAccount.Id);
        insert testContact;
        
        Opportunity__c testOpportunity = new Opportunity__c(
            Name = 'Test Opportunity',
            Close_Date__c = Date.today(),
            Account_Name__c = testAccount.Id,
            Primary_contact__c = testContact.Id,
            RecordTypeId='0121m000000DsT8AAK'
        );
        insert testOpportunity;

        Quote__c testQuote = new Quote__c(
            Name = 'Test Quote',
            Status__c = 'Draft',
            Account_Name__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id,
            ExpirationDate__c = Date.today(),
            RecordTypeId='0121m000000Dse8AAC'
        );
        insert testQuote;
		Test.setCurrentPage(Page.customQuotePDF);
        
       
        Test.startTest();
        String result = SendMail.sendEmailWithPDF(testQuote.Id);
        Test.stopTest();

        
    }

   /* @isTest
    static void testSendEmailWithPDF_InvalidInput() {
        Test.startTest();
        String result = SendMail.sendEmailWithPDF(null);
        Test.stopTest();
        
    }*/

    @isTest
    static void testSendInvoicesWithPDF() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com', AccountId = testAccount.Id);
        insert testContact;

        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 12,
            CustomerSignedId = testContact.Id
        );
        insert testContract;

        Order__c testOrder = new Order__c(
            Name = 'Test Order',
            ContractId__c = testContract.Id,
            EffectiveDate__c = System.today(),
            AccountId__c = testAccount.Id,
            RecordTypeId='0121m000000DsdoAAC',
            ServiceDate__c = system.today()
            
        );
        insert testOrder;

        Test.startTest();
        String result = SendMail.sendInvoicesWithPdf(testOrder.Id);
        Test.stopTest();

       
    }

    @isTest
    static void testSendInvoicesWithPDF_InvalidInput() {
        Test.startTest();
        String result = SendMail.sendInvoicesWithPdf(null);
        Test.stopTest();
        
    }
}