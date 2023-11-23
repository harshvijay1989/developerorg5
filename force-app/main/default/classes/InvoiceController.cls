public class InvoiceController {
    public Order__c ord{get;set;}
    public id orderId{get;set;}
    public Double prodcutTotalAmt{get;set;}
    public list<Order__c> orderitem{get;set;}
    public InvoiceController(){
        orderId = ApexPages.currentPage().getParameters().get('id');
        system.debug('order  id '+orderId);
        ord=[SELECT  AccountId__r.Name,CreatedDate,TotalAmount__c,OrderNumber__c,BillingAddress__PostalCode__s, BillingAddress__City__s, BillingAddress__CountryCode__s,BillingAddress__Street__s,BillingAddress__StateCode__s,ShippingAddress__City__s,ShippingAddress__CountryCode__s,ShippingAddress__Street__s,ShippingAddress__PostalCode__s, ShippingAddress__StateCode__s,Name FROM Order__c Where Id=:orderId];
        orderitem=[select TotalPrice__c,UnitPrice__c,Quantity__c,ListPrice__c,Product2Id__r.Name,CreatedDate from Order__c  where OrderId__c=:orderId and OrderId__c !=null ];
        system.debug('list of quote line item'+orderitem);
        prodcutTotalAmt=0.0;
        for(Order__c orditem:orderitem){
            if(orditem.TotalPrice__c!=null){
                prodcutTotalAmt+=orditem.TotalPrice__c;
            }
            
        }

      
               
    }

}