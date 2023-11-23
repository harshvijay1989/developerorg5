global class EmailResponseToMD implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('envelope==> ' + envelope);
        System.debug('email==> ' + email);
        System.debug('emailText=> ' + email.plainTextBody);
        String plainTextBody = email.plainTextBody;
        System.debug('PlainTextBody: ' + plainTextBody);
        System.debug('Subject: ' + email.Subject);
        System.debug('result==> ' + result);

        String jsonString = null;

        plainTextBody = plainTextBody.replaceAll('\\s', '');
        if (plainTextBody.contains('Approve') || plainTextBody.contains('approve')) {
            jsonString = 'Approve';
        } else if (plainTextBody.contains('Reject') || plainTextBody.contains('reject')) {
            jsonString = 'Reject';
        }
		String msg = '';
        System.debug('JSON value: ' + jsonString);

        if (email.Subject.startsWith('Re: Sandbox: Quote Approval : ')) {
            email.Subject = email.Subject.substringAfter('Re: Sandbox: Quote Approval : ').trim();
        }
        system.debug('email.subject'+email.Subject);
        Quote__c quoteStage = [select id,Name, Status__c, OwnerId,QuoteNumber__c from Quote__c  WHERE QuoteNumber__c = :email.Subject];

        System.debug('quoteStage' + quoteStage);
        System.debug('123' + jsonString + '123');

        String activityMessage = '';
        if (jsonString == 'Approve') {
            if (quoteStage.Status__c == 'Rejected') {
                quoteStage.Status__c = 'Approved';
                activityMessage = 'Approved';
                //sendCustomNotification(quoteStage.OwnerId); // Send a custom notification
            } else {
                msg = 'Your request has been Approved';
                completeTask(quoteStage.id,quoteStage.OwnerId,msg);
                quoteStage.Status__c = 'Approved';
                
                
      
                  
            }
        } else if (jsonString == 'Reject') {
            if (quoteStage.Status__c == 'Approved') {
                quoteStage.Status__c = 'Rejected';
            } else {
                msg = 'Your request has been Rejected';
                completeTask(quoteStage.id,quoteStage.OwnerId,msg);
                quoteStage.Status__c = 'Rejected';
            }
            activityMessage = 'Rejected';
        } else {
            quoteStage.Status__c = 'Draft';
            activityMessage = 'Draft';
        }

        Update quoteStage;

        logActivity(quoteStage.Id, activityMessage);

        //System.debug('quoteStage' + quoteStage);
        return result;
    }

    public void logActivity(Id recordId, String description) {
        Quote__c qu =[Select id,ownerId from Quote__c where id =: recordId];

        Task task = new Task();
       // task.WhatId = recordId;
        task.OwnerId = qu.ownerId;
        task.Subject = 'Approval Status';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        task.Description = description;

        insert task;
    }

   public void completeTask(Id recordId , Id userId,string msg) {
        system.debug('recordID'+recordId);
        system.debug('userId'+userId);

        List<Task> tasksToComplete = [SELECT Id FROM Task WHERE WhatId = :recordId AND Status != 'Completed'];
       system.debug('tasksToComplete'+tasksToComplete);
        for (Task t : tasksToComplete) {
            system.debug('tasks80');
            t.Status = 'Completed';
        }
        update tasksToComplete;
        
         CustomNotificationType notificationType = 
           [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Mail_to_CEO'];
                system.debug('notificationType'+notificationType);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
       				 system.debug('recordID'+recordId);
        			system.debug('userId'+userId);
                notification.setTitle('Response to your Approval Request.');
                notification.setBody(msg);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(recordId);
                notification.send(new set<String>{userId});
        system.debug('notification'+notification);
    }
}