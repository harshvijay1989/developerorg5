import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getListUi } from 'lightning/uiListApi';
import insertList from '@salesforce/apex/ListViewController.insertList';
import renameList from '@salesforce/apex/ListViewController.renameList';
import deleteList from '@salesforce/apex/ListViewController.deleteList';
import getListViewRecord from '@salesforce/apex/ListViewController.getListViewRecord';
import getFieldLabels from '@salesforce/apex/ListViewController.getFieldLabels';
import { NavigationMixin } from 'lightning/navigation';
//for prooduct New 
import saveProduct from '@salesforce/apex/demo1.saveProduct';




export default class ListViewConfigure extends NavigationMixin(LightningElement) {
    @api objectApiName = '';
    @api fieldSetName = '';
    title_1 = '';
    titleApiName = '';
    @track titleName = '';
    @track listName = '';
    @track listApiName = '';
    @track record;
    @track showNewPage = false;
    fields = new Set();
    @api recordId;  // record id from record detail page e.g. ''0012v00002WCUdxAAH'
    @api SFDCobjectApiName; //kind of related list object API Name e.g. 'Case'

    @api criteriaFieldAPIName; // This field will be used in WHERE condition e.g.'AccountId'
    @api firstColumnAsRecordHyperLink; //if the first column can be displayed as hyperlink

    @track columns;   //columns for List of fields datatable
    @track tableData;   //data for list of fields datatable

    recordCount; //this displays record count inside the ()
    lblobjectName;
    getData() {
        /*  setTimeout(() => {
              //console.log('this.objectApiName=====>' + this.objectApiName);
              //console.log('this.titleApiName=====>' + this.titleApiName);           
              getListViewRecord({ objectName: this.objectApiName, listApiName: this.titleApiName })
                  .then(result => {
                      console.log('It is successfull');
                      console.log('Result =====>', result);
                      const temp = JSON.parse(result);
                      this.record = temp.map(t => Object.values(t).reverse());
                      this.extractFields(temp);
                  }
                      , 200);
  
          })*/
        let firstTimeEntry = false;
        let firstFieldAPI;

        //make an implicit call to fetch records from database
        getListViewRecord({ objectName: this.objectApiName, listApiName: this.titleApiName })
            .then(data => {
                //get the entire map
                let objStr = JSON.parse(data);
                alert('objStr' + objStr)
                /* retrieve listOfFields from the map,
                 here order is reverse of the way it has been inserted in the map */
                let listOfFields = JSON.parse(Object.values(objStr)[1]);
                alert('listOfFields' + listOfFields)
                //retrieve listOfRecords from the map
                let listOfRecords = JSON.parse(Object.values(objStr)[0]);
                alert('listOfRecords' + listOfRecords)
                let items = []; //local array to prepare columns

                /*if user wants to display first column has hyperlink and clicking on the link it will
                    naviagte to record detail page. Below code prepare the first column with type = url
                */
                listOfFields.map(element => {
                    //it will enter this if-block just once
                    if (this.firstColumnAsRecordHyperLink != null && this.firstColumnAsRecordHyperLink == 'Yes'
                        && firstTimeEntry == false) {
                        firstFieldAPI = element.fieldPath;
                        //perpare first column as hyperlink                                     
                        items = [...items,
                        {
                            label: element.label,
                            fieldName: 'URLField',
                            fixedWidth: 150,
                            type: 'url',
                            typeAttributes: {
                                label: {
                                    fieldName: element.fieldPath
                                },
                                target: '_blank'
                            },
                            sortable: true
                        }
                        ];
                        firstTimeEntry = true;
                    } else {
                        items = [...items, {
                            label: element.label,
                            fieldName: element.fieldPath
                        }];
                    }
                });
                //finally assigns item array to columns
                this.columns = items;
                this.tableData = listOfRecords;
                alert('this.columns' + this.columns);
                alert(this.tableData);
                console.log('listOfRecords', listOfRecords);
                /*if user wants to display first column has hyperlink and clicking on the link it will
                    naviagte to record detail page. Below code prepare the field value of first column
                */
                if (this.firstColumnAsRecordHyperLink != null && this.firstColumnAsRecordHyperLink == 'Yes') {
                    let URLField;
                    //retrieve Id, create URL with Id and push it into the array
                    this.tableData = listOfRecords.map(item => {
                        URLField = '/lightning/r/' + this.SFDCobjectApiName + '/' + item.Id + '/view';
                        return { ...item, URLField };
                    });

                    //now create final array excluding firstFieldAPI
                    this.tableData = this.tableData.filter(item => item.fieldPath != firstFieldAPI);
                }

                //assign values to display Object Name and Record Count on the screen
                this.lblobjectName = this.SFDCobjectApiName;
                this.recordCount = this.tableData.length;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
                this.tableData = undefined;
                this.lblobjectName = this.SFDCobjectApiName;
            })
    }
    extractFields(data) {
        this.fields = new Set();;
        if (Array.isArray(data)) {
            data.forEach(record => {
                Object.keys(record).forEach(field => {
                    this.fields.add(field);
                });
            });
            this.fields = new Set(Array.from(this.fields).reverse());
        } else {
            console.error("Data is not an array.");
        }
    }

    get uniqueFields() {
        return Array.from(this.fields);
    }

    showDropdown = false;
    showNewModal = false;

    toggleDropdown() {
        this.showDropdown = !this.showDropdown;
    }

    @track listViewData;
    showListViewDropdown = false;

    @wire(getListUi, { objectApiName: '$objectApiName' })
    listUi({ error, data }) {
        if (data) {
            console.log('Data@  : ' + JSON.stringify(data));
            this.listViewData = data.lists;
            this.title_1 = this.listViewData[0].label;
            this.titleApiName = this.listViewData[0].apiName;
            console.log('Api name : ' + this.titleApiName);
            this.getData();
        } else if (error) {
            console.error('Error retrieving list view:', error);
        }
    }

    handleNewClick() {
        this.showNewModal = true;
        this.showDropdown = false;
    }
    closeNewModal() {
        this.showNewModal = false;
    }

    handleSwitchListView() {
        this.showListViewDropdown = !this.showListViewDropdown;
    }
    handleListViewClick(event) {
        const listViewApiName = event.target.dataset.value;
        this.title_1 = listViewApiName;
        this.titleApiName = event.target.dataset.name;
        this.showListViewDropdown = false;
        this.getData();
    }

    showRenameModal = false;
    handleRenameClick() {
        this.showRenameModal = true;
        this.showDropdown = false;
    }
    closeRenameModal() {
        this.showRenameModal = false;
    }
    handleRename(event) {
        this.titleName = event.target.value;
    }
    handleRenameSave() {
        this.showRenameModal = false;
        const recId = '';
        console.log('Title : ' + this.title_1);
        for (var i = 0; i < this.listViewData.length; i++) {
            if (this.listViewData[i].label == this.title_1) {
                console.log(this.listViewData[i].label);
                this.recId = this.listViewData[i].id;
                break;
            }
        }
        console.log('Api Name : ' + this.titleApiName);
        console.log('Obj Name : ' + this.objectApiName);
        renameList({ apiName: this.titleApiName, label: this.titleName, objName: this.objectApiName })
            .then(result => {
                console.log('It is successfull');
            })
            .catch(error => {
                console.error('It is an error ====>', JSON.stringify(error));
            })
    }
    handleName(event) {
        this.listName = event.target.value;
        // console.log('List name : '+this.listName);
    }
    handleApiName(event) {
        this.listApiName = event.target.value;
        //console.log('List Api name : '+this.listApiName);
    }
    handleNewSave() {
        console.log('Obj name : ' + this.objectApiName);
        this.showNewModal = false;
        insertList({ name: this.listName, apiName: this.listApiName, objName: this.objectApiName })
            .then(result => {
                console.log('It is successfull');
            })
            .catch(error => {
                console.error('It is an error ====>', JSON.stringify(error));
            })
    }
    @track deleteListModal = false;
    handleDeleteClick() {
        this.showDropdown = false;
        this.deleteListModal = true;
    }
    closeModal() {
        this.deleteListModal = false;
    }
    deleteListView() {
        this.deleteListModal = false;
        deleteList({ apiName: this.titleApiName, objName: this.objectApiName })
            .then(result => {
                console.log('It is successfull');
            })
            .catch(error => {
                console.error('It is an error ====>', JSON.stringify(error));
            })
    }
    showCloneModal = false;
    handleCloneClick() {
        this.showDropdown = false;
        this.showCloneModal = true;
    }
    closeCloneModal() {
        this.showCloneModal = false;
    }
    showFieldsModal = false;
    jsonData = [];
    handleFieldsClick() {
        console.log(this.selectedValues);
        this.showDropdown = false;
        this.showFieldsModal = true;
        // console.log('this.fields', this.fields);
        // console.log(typeof (this.fields));
        getFieldLabels({ objectApiName: this.objectApiName })
            .then(result => {
                console.log('Fields : ' + result);
                console.log(typeof (result));
                this.jsonData = result.map(label => {
                    return { label: label, value: label };
                });
                //console.log('JSON data : ' + this.jsonData);
            })
            .catch(error => {
                console.error('It is an error ====>', JSON.stringify(error));
            })
    }
    selectedValues = [
        { label: 'English', value: 'en' },
        { label: 'Japanese', value: 'ja' },
    ];
    get options() {
        console.log(this.selectedValues);
        return this.jsonData;
    }
    selectedJSON = [];

    closeFieldsModal() {
        this.showFieldsModal = false;
    }

    handleNew() {

        const objectApiName = 'Opportunity__c';
        const recordTypeId = '0121m000000DscMAAS'; // Replace with the actual Record Type Id

        // Use the NavigationMixin to navigate to the create record page with a specific record type
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                recordTypeId: recordTypeId
            }
        });
        
    }

// for New product add

shownewpage2=false;
    PName='';
    isActive=false;
    ProductCode='';
    ProductType='';
    productdes='';
    unitPrice='';
      options = [
        { label: 'Communication Devices', value: 'Communication Devices' },
        { label: 'Colourless to yellowish clear liquid', value: 'Colourless to yellowish clear liquid.' },
        // Add more options as needed
    ];
    handleClick() {
        this.showNewPage = true;

    }

    closeNewModal() {
         this.shownewpage2=false;
    }

    closeModal(){


       this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleClickNEW(){
        this.shownewpage2=true;
    }
  
   handleProductName(event) {
        this.PName = event.target.value;
        console.log("Product name: " + this.PName);
    }

    handleActive(event) {
        this.isActive = event.target.checked;
        console.log("Is Active? " + this.isActive);
    }

    handleProductCode(event){
      this.ProductCode=event.target.value;
      
    }

    handleProductType(event){
        this.ProductType=event.target.value;
    }

    handleproductdes(event){
        this.productdes=event.target.value;

    }
    handleUnitPrice(event){
        this.unitPrice=parseFloat(event.target.value);
        

    }
   
  handleSave() {
    const productData = {
        PName: this.PName,
        isActive: this.isActive,
        ProductCode: this.ProductCode,
        productdes: this.productdes,
        ProductType: this.ProductType
    };

    const productDataJSON = JSON.stringify(productData);

    console.log('JOSN Data=>'+productDataJSON);

    

    this.shownewpage2 = false;
}

  handleSave() {
    const productData = {
        PName: this.PName,
        isActive: this.isActive,
        ProductCode: this.ProductCode,
        productdes: this.productdes,
        ProductType: this.ProductType,
        unitPrice:this.unitPrice
    };

    const productDataJSON = JSON.stringify(productData);

    console.log('JOSN Data=>'+productDataJSON);
          saveProduct({ data1: productDataJSON })
            .then(result => {
                console.log('Product saved:', result);
                this.showToast('success', 'Product Saved', result);
            })
            .catch(error => {
                console.error('Error saving product:', error);
                this.showToast('error', 'Error', 'Error saving product.');
            });

        this.shownewpage2 = false;
    }

    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(event);
    }
    

}