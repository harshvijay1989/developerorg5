public class LeadTriggerHelper {
    public static void beforeInsert(List<Lead__c> leadList){
        Set<Id> campaignIdSet = new Set<Id>();
        for (Lead__c leadObj : leadList){
            if(leadObj.Campaign__c != null){
                campaignIdSet.add(leadObj.Campaign__c);
            }
        }
        if(!campaignIdSet.isEmpty()){
            List<Campaign> campaignList = [Select id,EndDate,StartDate from Campaign where id in :campaignIdSet];
            Map<Id,Date> CampaignMap = new Map<Id,Date>();
            Map<Id,Date> CampaignMapStart = new Map<Id,Date>();
            for (Campaign campObj : campaignList){
                if(campObj.EndDate != null){
                    CampaignMap.put(campObj.Id,campObj.EndDate);
                }
            }
            for (Campaign campObjStart : campaignList){
                if(campObjStart.StartDate != null){
                    CampaignMapStart.put(campObjStart.Id,campObjStart.StartDate);
                }
            }
            for (Lead__c leadObjs : leadList){
                if(leadObjs.Campaign__c != null){
                    if( leadObjs.CreatedDate < CampaignMapStart.get(leadObjs.Campaign__c)){
                        leadObjs.addError('Campaign is Yet to Start');
                    }else if(leadObjs.CreatedDate > CampaignMap.get(leadObjs.Campaign__c)){
                        leadObjs.addError('Campaign is Already Ended');
                    }
                    
                }
            }
        }
    }
    public static void convertStandardLead(List<Lead__c> leadList,Map<Id,Lead__c>oldMap){
        set<Id> leadIdSet = new Set<Id>();
        for (Lead__c leadObj : leadList){
            if(leadObj.Status__c == 'Converted' && leadObj.Status__c != oldMap.get(leadObj.Id).Status__c){
                leadIdSet.add(leadObj.Id);
            }
        }
        if(!leadIdSet.isEmpty()){
            List<Lead> mainList = [select id,Status,Master_ID__c from Lead where Master_ID__c in : leadIdSet];
            if(!mainList.isEmpty()){
                Map<String,Id> leadMap = new Map<String,Id>();
                for (Lead mainleadObjs : mainList){
                    leadMap.put(mainleadObjs.Master_ID__c,mainleadObjs.Id);
                }
                LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
                List<Database.LeadConvert> updateList = new List<Database.LeadConvert>();
                for (Lead__c leadObjs : leadList){
                    if(leadObjs.Status__c == 'Converted'){
                        Lead leadup = new Lead();
                        leadUp.Id = leadMap.get(leadObjs.Id);
                        Database.LeadConvert LeadConvert=new Database.LeadConvert();
                        LeadConvert.setLeadId(leadUp.Id);
                        LeadConvert.setConvertedStatus(cLeadStatus.MasterLabel);
                        LeadConvert.setDoNotCreateOpportunity(true);
                        updateList.add(LeadConvert);
                        
                    }
                }
                if(!updateList.isEmpty()){
                    List<Database.LeadConvertResult> lcr=Database.convertLead(updateList);
                }
            }
            
        }
    }
}