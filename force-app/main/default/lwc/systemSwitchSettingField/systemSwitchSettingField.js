import { LightningElement, api, track } from 'lwc';

export default class SystemSwitchSettingField extends LightningElement {

  @api field;

  @api value;

  _fieldType

  connectedCallback() {
    //if there is no org default setting, will receive json parse error
    //maybe lwc recommend pass primitive type, not object type
    //console.log('before convert field');
    //console.log(JSON.stringify(this.field));
    this.field = JSON.parse(JSON.stringify(this.field));
    //console.log('after convert field');
    //console.log(this.field);
    this.setFieldType();
  }

  setFieldType() {
    if (this.field.soapType.toUpperCase() === "BOOLEAN") {
      this._fieldType = "CHECKBOX";
    } else if (this.field.soapType.toUpperCase() === "STRING") {
      this._fieldType = "STRING";
    }
  }

  get isBooleanType() {
    return this._fieldType.toUpperCase() === "CHECKBOX";
  }

  get isStringType() {
    return this._fieldType.toUpperCase() === "STRING";
  }

  renderedCallback() {
    if (this._fieldType === "CHECKBOX") {
      //IMPORTANT, HOW TO RENDER CHECKBOX IN LIGHTING-INPUT ELEMENT
      const checkboxEl = this.template.querySelector("lightning-input[data-name='fieldValueInput']");
      checkboxEl.checked = JSON.parse(this.field.value);
      checkboxEl.value = JSON.parse(this.field.value);
    }

    this.value = this.field.value;
  }

  @api enabledEdit() {
    const el = this.template.querySelector("[data-name='fieldValueInput']");

    if (this._fieldType === "CHECKBOX") {
      el.disabled = false;
    } else if (this._fieldType === "STRING") {
      el.removeAttribute("disabled", null);
    }
  }

  @api disabledEdit() {
    const el = this.template.querySelector("[data-name='fieldValueInput']");

    if (this._fieldType === "CHECKBOX") {
      el.disabled = true;
    } else if (this._fieldType === "STRING") {
      el.setAttribute("disabled", null);
    }
  }

  //TODO: pop value of all child to parent so it can generate update string and call apex
  handleInputChange(event) {
    if (this._fieldType === "CHECKBOX") {
      this.value = event.target.checked;
    } else if (this._fieldType === "STRING") {
      this.value = event.target.value;
    }
  }

  @api
  getTitle() {
    return this.field.name;
  }
}