import { LightningElement, track, wire } from 'lwc';
import getMapPropertyList from '@salesforce/apex/PropertyController.getMapPropertyList';
import { NavigationMixin } from 'lightning/navigation';

export default class PropertyMap extends NavigationMixin(LightningElement) {

  center = {
    location: {
      City: 'Epping',
      Country: 'AUS',
      PostalCode: '3076'
    },
    title: 'Epping'
  };

  //center markers title
  markersTitle = 'Epping';

  zoomLevel = 14;

  listView = 'visible';

  showFooter = true;

  @track mapMarkers = [];

  @track error;

  @track selectedMarkerValue;

  constructor() {
    super();
    this.initMap();
  }

  initMap() {
    this.mapMarkers.push(this.center);
  }

  //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_wire_service_about
  //The function is invoked whenever a value is available, which can be before or after the component is connected or rendered.
  @wire(getMapPropertyList)
  wiredPropertyList(result) {
    if (result === undefined) {
      this.mapMarkers = undefined;
      this.error = 'No property available.';
    } else if (result.data) {
      //this.mapMarkers = this.buildMapMarkers(result.data);
      this.buildMapMarkers(result.data);
      this.error = undefined;
    } else if (result.error) {
      this.mapMarkers = undefined;
      this.error = result.error;
    }
  }

  buildMapMarkers(propertyList) {
    propertyList.forEach(element => {
      this.mapMarkers = [...this.mapMarkers,
      {
        location: {
          Street: `${element.No_of_Rooms__c} Rooms, ${element.No_of_Bathrooms__c} Bathrooms.`,
          Latitude: element.Geolocation__Latitude__s,
          Longitude: element.Geolocation__Longitude__s,
        },
        value: element.Id,
        icon: 'standard:home',
        title: element.Name__c,
        description: `${element.No_of_Rooms__c} Rooms, ${element.No_of_Bathrooms__c} Bathrooms.`
          + '</br>'
          + `$${element.Est_Min_Price__c} ~ $${element.Est_Max_Price__c}`
      }]
    });

    // const locationList = [];

    // propertyList.forEach(element => {
    //   const marker = {
    //     location: {}
    //   };
    //   marker.location.Street = element.No_of_Rooms__c + ' Rooms, ' 
    //                           + element.No_of_Bathrooms__c + ' Bathrooms.' 
    //   marker.location.Latitude = element.Geolocation__Latitude__s;
    //   marker.location.Longitude = element.Geolocation__Longitude__s;
    //   marker.icon = 'standard:home';
    //   marker.title = element.Name__c;
    //   marker.description = element.No_of_Rooms__c + ' Rooms, ' 
    //                       + element.No_of_Bathrooms__c + ' Bathrooms.' 
    //                       + '</br>' 
    //                       + '$' + element.Est_Min_Price__c
    //                       + ' ~ '
    //                       + '$' + element.Est_Max_Price__c;

    //   locationList.push(marker);
    // });

    // return locationList;
  }

  //TODO: implement a pop up to ask user if need to redirect to record page in this session
  handleMarkerSelect(event) {
    setTimeout(this.openNewSubTab, 1500, this, event.target.selectedMarkerValue);
  }

  openNewSubTab(that, id) {
    if (id !== undefined && id !== null) {
      that[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: id,
          actionName: 'view'
        }
      });
    }
  }
}
