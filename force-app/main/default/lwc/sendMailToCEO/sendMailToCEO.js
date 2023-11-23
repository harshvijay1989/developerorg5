import { LightningElement, track, api, wire } from 'lwc';
import sendMailToCeo from '@salesforce/apex/SendEmailToCeoController.sendMailToCeo';
//import modal from "@salesforce/resourceUrl/custommodalcss1";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SendMailToCEO extends LightningElement {
 @api recordId;
    vfPageUrllink;





    sendmail() {
       
        sendMailToCeo({ recId: this.recordId })
            .then(result => {
                setTimeout(() => {
                    window.location.reload();
                }, 700);
                this.showToast('Success', 'Email sent successfully', 'success');
                const closeAction = new CloseActionScreenEvent();
                this.dispatchEvent(closeAction);
            })

            .catch(error => {

                this.showToast('Error', 'Error sending email', 'error');
                const closeAction = new CloseActionScreenEvent();
                this.dispatchEvent(closeAction);
            });
    }


        showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }



       renderedCallback() {
        setTimeout(() => {

            this.vfPgaeUrl();

        }, 1000);

    }

    vfPgaeUrl() {
        const recordId = this.recordId;
        console.log("dynamic content version id ", recordId);

        this.vfPageUrllink = `https://3dboost2--dev5.sandbox.lightning.force.com/apex/CustomQuotePDF?id=${recordId}`;
        //alert('vfPageUrl : '+vfPageUrl);
      
    }

}