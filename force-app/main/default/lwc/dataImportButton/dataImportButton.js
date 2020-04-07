import { LightningElement } from 'lwc';
import sendImportRequest from '@salesforce/apex/PropertyController.sendImportRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/idsUtils';

export default class DataImportButton extends LightningElement {

  handleClick(event) {
    sendImportRequest()
      .then(result => {
        if (result.status === '200') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: result.messages.join(', '),
              variant: 'success'
            })
          );
        } else if (result.status === '404') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Failed importing Property data.',
              message: result.messages.join(', '),
              variant: 'error'
            })
          );
        } else if (result.status === '400') {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Failed importing Property data.',
              message: result.messages.join(', '),
              variant: 'error'
            })
          );
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Unknown error',
              message: result.messages.join(', '),
              variant: 'error'
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Failed importing Property data.',
            message: reduceErrors(error).join(', '),
            variant: 'error'
          })
        );
      });
  }
}