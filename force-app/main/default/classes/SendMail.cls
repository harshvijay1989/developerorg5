public class SendMail {
    @AuraEnabled(cacheable=true)
    public static String sendEmailWithPDF(String recordId) {
        Quote__c quoteRecord = [SELECT Id, Name,Opportunity__r.Primary_contact__r.Email,Opportunity__r.Name FROM Quote__c WHERE Id = :recordId LIMIT 1];
        //System.debug('quoteRecord'+quoteRecord);
        try {
            // Generate PDF using Visualforce page
            PageReference pageRef = Page.customQuotePDF;
            pageRef.getParameters().put('id', recordId);
            Blob pdfBlob = pageRef.getContentAsPDF();
            System.debug('pdfBlob'+pdfBlob);
            
            // Create an email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Your Quote Details');
            String emailBody = '<p>Please find the attached quote PDF.</p>' +
                '<p>Best regards,<br/>NOVOFLEX</p>';
            email.setHtmlBody(emailBody);
            
            // Attach the PDF blob to the email
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(quoteRecord.Opportunity__r.Name+'-Quote.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            
            // Set recipient email address
            email.setToAddresses(new List<String>{quoteRecord.Opportunity__r.Primary_contact__r.Email});// Add recipient email address
            
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            
            return 'Email sent successfully';
        } catch (Exception e) {
            // Handle exceptions here
            return 'Error sending email: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String sendInvoicesWithPdf(String recordId) {
        System.debug('recordId => ' + recordId);
        try {
            // Generate PDF using Visualforce page
            PageReference pageRef = Page.customInvoicePDF;
            pageRef.getParameters().put('id', recordId);
            Blob pdfBlob = pageRef.getContentAsPDF();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            order__c orderRecord = [SELECT Id,Name, OrderNumber__c, PrimaryQuote__r.Opportunity__r.Primary_contact__r.Email FROM Order__c WHERE Id =: recordId];
            
            String recipientEmail = orderRecord.PrimaryQuote__r.Opportunity__r.Primary_contact__r.Email;
            system.debug('recipientEmail'+recipientEmail);
            if (recipientEmail != null) {
                email.setToAddresses(new List<String>{recipientEmail});
                email.setSubject('Your Order Invoice');
                String emailBody = '<p>Please find the attached Order Invoice PDF.</p>' +
                    '<p>Best regards,<br/>NOVOFLEX</p>';
                email.setHtmlBody(emailBody);
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Invoices.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                //updating order
                    Order__c  ord= new Order__c();
                    ord.Id=recordId;
                    ord.Invoice_Generated__c=true;
                    system.debug('order detail'+ord);
                    if(ord!=null){
                        update ord;
                    } 
                
                return 'Email sent successfully';
              
                    
                
            } else {
                system.debug('Email id is null');	
            }
            return 'Error';
        } catch (Exception e) {
            return 'Error sending email: ' + e.getMessage();
        }
        
        
    }
    
    
}