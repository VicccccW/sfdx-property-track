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
    const customFields = this.systemConfigFields.filter(el => el.isCustom === true);
    console.log('customFields are ', customFields);
    return customFields;
  }


  //also need a variable to store the id


  //we also need another method to call an apex method to update the custom setting in Salesforce

  //function to control button 
  //if click edit button, which is enabled by default
  //enabled the input tags
  //disabled edit button 

  //if any input field changed
  //enabled save button

  //if click save button 
  //toast to say wheter save success or fail
  //call apex method to save
  //if success ->
  //disable input tags
  //enable edit button
  //if fail ->
  //toast the error message
  //restore value 
  //enable eidt button

  handleEdit(event) {
    this.template.querySelectorAll('button').forEach(element => {
      if (element.name === "Edit") {
        element.setAttribute("disabled", null);
      } else if(element.name === "Save") {
        element.removeAttribute("disabled", null);
      }
    });
    
  }

  handleSave(event) {

  }

}