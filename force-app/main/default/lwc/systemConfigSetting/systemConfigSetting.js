import { LightningElement, wire, track } from 'lwc';
import getSystemConfigFields from '@salesforce/apex/SystemConfigController.getSystemConfigFields';
import setSystemConfigFields from '@salesforce/apex/SystemConfigController.setSystemConfigFields';
import createRemoteSiteSettings from '@salesforce/apex/RemoteSiteSettingController.createRemoteSiteSettings';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/idsUtils';

export default class systemConfigSetting extends LightningElement {

  //DO NOT mark to @api or @track as we want this property immutable
  //if we want to change the custom setting value, we can create a copy and update that one
  systemConfigFields;

  newSysConfigStr;

  @track hasCustomFields;

  @track customFields;

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
      this.hasCustomFields = false;
    }

    if (this.hasCustomFields) {
      this.customFields = this.systemConfigFields.filter(el => el.isCustom === true);
    }
  }

  checkHasCustomFields() {
    this.hasCustomFields = this.systemConfigFields.some(el => el.isCustom === true);
  }

  handleEdit(event) {
    this.template.querySelectorAll('button').forEach(element => {
      if (element.name === "EditBtn") {
        element.setAttribute("disabled", null);
      } else if (element.name === "SaveBtn") {
        element.removeAttribute("disabled", null);
      }

      this.template.querySelectorAll("input[name='fieldValueInput']").forEach(element => {
        element.removeAttribute("disabled", null)
      });
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

    this.template.querySelectorAll("input[name='fieldValueInput']").forEach(element => {
      element.setAttribute("disabled", null)
    });

    this.buildNewSysConfigStr();

    setSystemConfigFields({ newSysConfigStr: this.newSysConfigStr })
      .then(result => {
        if (result.status === 'Success') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Update SystemConfig setting Successlly!',
              variant: 'success'
            })
          );
        } else if (result.status === 'Error') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error updating SystemConfig setting.',
              message: result.messages.join(', '),
              variant: 'error'
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error updating SystemConfig setting.',
            message: reduceErrors(error).join(', '),
            variant: 'error'
          })
        );
      });

    const remoteSiteUrl = this.template.querySelector("input[title='Property_Backup_Endpoint__c']").value;

    createRemoteSiteSettings({ siteUrl: remoteSiteUrl })
      .then(result => {
        console.log("Updated remote site.");
        console.log(result);
      })
      .catch(error => {
        console.log("Error when create remote site.");
      })
  }

  buildNewSysConfigStr() {
    const newStrObj = {};

    const orgDefaultId = this.systemConfigFields.find(el => el.name === 'Id').value;

    if (orgDefaultId) {
      newStrObj.Id = orgDefaultId;
    }

    this.template.querySelectorAll("input[name='fieldValueInput']").forEach(el => {
      newStrObj[el.title] = el.value;
    });

    console.log('return obj to Apex');
    console.log(newStrObj);

    //format should be '{"Id": "a02N000000JJJ8dIAH", "Property_Backup_Scan_Range_Days__c": "10"}'
    this.newSysConfigStr = JSON.stringify(newStrObj);
  }
}