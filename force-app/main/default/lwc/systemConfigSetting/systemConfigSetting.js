import { LightningElement, wire, track } from 'lwc';
import getSystemConfigFields from '@salesforce/apex/SystemConfigController.getSystemConfigFields';

export default class systemConfigSetting extends LightningElement {

  //DO NOT mark to @api or @track as we want this property immutable
  //if we want to change the custom setting value, we can create a copy and update that one
  systemConfigFields;
  
  @track hasCustomFields;
  
  @track error;

  @wire(getSystemConfigFields)
  wiredSystemConfigFields(result) {
    if (result.data) {
      this.systemConfigFields = result.data;
      this.error = undefined;
      this.checkHasCustomFields();
    } else if (result.error) {
      this.systemConfigFields = undefined;
      this.error = result.error;
    }
  }

  checkHasCustomFields() {
      this.hasCustomFields = this.systemConfigFields.some(el => el.isCustom === true);
  }

  get customFields() {
    const customFields = this.systemConfigFields.filter(el => el.isCustom == true);
    console.log('customFields are ', customFields);
    return customFields;
  }
  
  //after get the data, which is an array
  //use a filter to find out the isCustom = true item
  //also need a variable to store the id
  

  //we also need another method to call an apex method to update the custom setting in Salesforce

}