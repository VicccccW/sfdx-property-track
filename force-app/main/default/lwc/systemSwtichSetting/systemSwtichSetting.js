import { LightningElement, wire, track } from 'lwc';
import getSystemSwitchFields from '@salesforce/apex/SystemSwitchController.getSystemSwitchFields';
import setSystemSwitchFields from '@salesforce/apex/SystemSwitchController.setSystemSwitchFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/idsUtils';

export default class systemSwitchSetting extends LightningElement {

  //DO NOT mark to @api or @track as we want this property immutable
  //if we want to change the custom setting value, we can create a copy and update that one
  systemSwitchFields;

  newSysSwitchStr;

  @track hasCustomFields;

  @track customFields;

  @track error;

  @wire(getSystemSwitchFields)
  wiredSystemSwitchFields(result) {
    if (result.data) {
      this.systemSwitchFields = result.data;
      this.error = undefined;
      this.checkHasCustomFields();
    } else if (result.error) {
      this.systemSwitchFields = undefined;
      this.error = result.error;
      this.hasCustomFields = false;
    }

    if (this.hasCustomFields) {
      this.customFields = this.systemSwitchFields.filter(el => el.isCustom === true);
    }
  }

  checkHasCustomFields() {
    this.hasCustomFields = this.systemSwitchFields.some(el => el.isCustom === true);
  }

  handleEdit(event) {
    this.template.querySelectorAll('button').forEach(element => {
      if (element.name === "EditBtn") {
        element.setAttribute("disabled", null);
      } else if (element.name === "SaveBtn") {
        element.removeAttribute("disabled", null);
      }
    });


    this.template.querySelectorAll("c-system-switch-setting-field").forEach(element => {
      element.enabledEdit();
    });
  }

  handleSave(event) {
    this.template.querySelectorAll('button').forEach(element => {
      if (element.name === "EditBtn") {
        element.removeAttribute("disabled", null);
      } else if (element.name === "SaveBtn") {
        element.setAttribute("disabled", null);
      }
    });

    this.template.querySelectorAll("c-system-switch-setting-field").forEach(element => {
      element.disabledEdit();
    });

    this.buildNewSysSwitchStr();

    setSystemSwitchFields({ newSysSwitchStr : this.newSysSwitchStr })
      .then(result => {
        if (result.status === 'Success') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Update SystemSwitch setting Successlly!',
              variant: 'success'
            })
          );
        } else if (result.status === 'Error') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error updating SystemSwitch setting.',
              message: result.messages.join(', '),
              variant: 'error'
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error updating SystemSwitch setting.',
            message: reduceErrors(error).join(', '),
            variant: 'error'
          })
        );
      });
  }

  buildNewSysSwitchStr() {
    const newStrObj = {};

    const orgDefaultId = this.systemSwitchFields.find(el => el.name === 'Id').value;

    if (orgDefaultId) {
      newStrObj.Id = orgDefaultId;
    }

    console.log('123');

    this.template.querySelectorAll("c-system-switch-setting-field").forEach(el => {
      newStrObj[el.getTitle()] = el.value.toString();
    });

    console.log('return obj to Apex');
    console.log(newStrObj);

    //format should be '{"Id": "a02N000000JJJ8dIAH", "xxx": "true"}'
    this.newSysSwitchStr = JSON.stringify(newStrObj);
  }
}