public class SendEmailToCeoController {
    @AuraEnabled
    public Static String sendMailToCeo(String  recId){
        system.debug('inside the sendMAil ceo');
        Quote__c quoteRecord = [SELECT Id, Name,Opportunity__r.Name,QuoteNumber__c,Account_Name__r.Name,GrandTotal__c FROM Quote__c WHERE Id = :recId];
        System.debug('quoteRecord 6'+quoteRecord);
        try {
            // Generate PDF using Visualforce page
            PageReference pageRef = Page.customQuotePDF;
            pageRef.getParameters().put('id', recId);
            Blob pdfBlob = pageRef.getContentAsPDF();
            System.debug('pdfBlob'+pdfBlob);
            
            String MdEmail = System.Label.Mail_to_CEO;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Quote Approval : '+quoteRecord.QuoteNumber__c);
            email.setReplyTo('novoflex@v-oc10u9afzh3rninpx0h7bipqqlnlekoy7tsah56ec3nde5uir.1e-1oboea2.cs111.apex.sandbox.salesforce.com');
            String emailBody = '<html><head></head><body><p>Dear Sir,</p><p>Request you to approve attached quote. Following are the details:</p><p> Customer Name: '+quoteRecord.Account_Name__r.Name+'</p><p>Amount: '+quoteRecord.GrandTotal__c+'</p><p>Quote Number: '+quoteRecord.QuoteNumber__c+'</p><br/><p>Request you to please responsed as Approved or Reject.</p><b>Best Regards,</b><br/><b>Internal Sales Team <br/>NOVOFLEX.</b></body></html>';
           
            email.setHtmlBody(emailBody);
            
            
            
            // Attach the PDF blob to the email
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(quoteRecord.Opportunity__r.Name+'-Quote.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            
            // Set recipient email address
           email.setToAddresses(new List<String>{MdEmail});// Add recipient email address
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            List<Task> notificationTasks = new List<Task>();
            notificationTasks.add(createNotificationTask(quoteRecord.Id));
            insert notificationTasks;
            
            return 'Email sent successfully';
        } catch (Exception e) {
            // Handle exceptions here
            return 'Error sending email: ' + e.getMessage();
        }
    }
    
    private static Task createNotificationTask(Id quoteId) {
        Quote__c qu =[Select id,ownerId,Status__c from Quote__c where id =: quoteId];
        qu.Status__c = 'In Review';
        update qu;
        User usr =  [SELECT Id,UserRoleId,ProfileId,ManagerId from User where  Id =: qu.ownerId];
        Task notificationTask = new Task();
        notificationTask.WhatId = quoteId;
        //notificationTask.OwnerId = usr.ManagerId;
        notificationTask.Subject = 'Approval Request';
        notificationTask.ActivityDate = Date.today();
        notificationTask.Status = 'Not Started';
        notificationTask.Priority = 'Normal';
        notificationTask.Description = 'Your process is currently underway';
        
        return notificationTask;
    }
}