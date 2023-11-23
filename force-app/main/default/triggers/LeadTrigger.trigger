trigger LeadTrigger on Lead__c (After insert,After Update) {
    if(trigger.isInsert){
        LeadTriggerHelper.beforeInsert(trigger.new);
    }
    if(trigger.isUpdate){
        LeadTriggerHelper.convertStandardLead(trigger.new,trigger.oldMap);
    }
}