import { LightningElement, api, track } from 'lwc';
import myResource from '@salesforce/resourceUrl/img';
import getAccountDetails from '@salesforce/apex/leadSucessClass.getAccountDetails';
import getContactDetails from '@salesforce/apex/leadSucessClass.getContactDetails';
import getOpportunityDetails from '@salesforce/apex/leadSucessClass.getOpportunityDetails';



import { NavigationMixin } from 'lightning/navigation';


export default class LeadSucessPage extends NavigationMixin(LightningElement) {
    resourse = myResource;
    @api recordId="0011m00000niuYaAAI";
    @api conId;
    @api oppId;
    @track showComponent = true;
    
    



    @api accountDetails = {};
    @api contactDetails = {};
    @api oppDetails = {};
    @api owner;
    @api accountName;
    @api primaryContact;
    @api showopp = false;

    connectedCallback() {
        
        this.getAccount();
        this.getContact();
        this.getOpp();
    }



    getAccount() {
        if (this.recordId) {
            getAccountDetails({ accountId: this.recordId })
                .then(result => {
                    this.showComponent = true;
                    this.accountDetails = JSON.parse(result);
                    console.log('Account Details:', JSON.stringify((this.accountDetails.Owner.Name)));
                    this.owner = this.accountDetails.Owner.Name;
                })
                .catch(error => {
                    console.error('Error fetching account details:', error);
                });
        }
        else{

        }
    }

    getContact() {
        if (this.recordId) {
            getContactDetails({ contactId: this.conId })
                .then(result => {
                    console.log(result);
                    this.contactDetails = JSON.parse(result);
                    
                    console.log('ContactDetails Details:', JSON.stringify((this.contactDetails)));
                    this.accountName = this.contactDetails.Account.Name;
                })
                .catch(error => {
                    console.error('Error fetching account details:', error);
                });
        }
    }


    getOpp() {
         if(this.oppId!=null && this.oppId!=undefined && this.oppId!=''){
            getOpportunityDetails({ oppId: this.oppId })
                .then(result => {
                    if(result == 'Null'){
                        this.showopp = false;
                    }
                    else{
                        this.showopp = true;
                    }
                   
                    console.log(this.showopp);
                    this.oppDetails = JSON.parse(result);
                    this.primaryContact = this.oppDetails.Primary_contact__r.Name;
                    console.log(JSON.stringify(this.oppDetails));
                })
                .catch(error => {
                    console.error('Error fetching account details:', error);
                });
         }
        
    }

   navigateToNewRecordPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Account",
        recordId:this.recordId,
        actionName: "view",
      },
    });
  }

  handleAccountNav(){
      this.navigateToNewRecordPage();
  }
}