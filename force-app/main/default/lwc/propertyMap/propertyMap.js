import { LightningElement, track, wire } from 'lwc';
import getMapPropertyList from '@salesforce/apex/PropertyController.getMapPropertyList';


export default class PropertyMap extends LightningElement {

  center = {
    location: {
      City: 'Epping',
      Country: 'AUS',
      PostalCode: '3076'
    }
  };

  //center markers title
  markersTitle = 'Epping';

  zoomLevel = 14;

  listView = 'visible';

  showFooter = true;

  @track mapMarkers = [];

  @track error;

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
      this.mapMarkers = this.buildMapMarkers(result.data);
      this.error = undefined;
    } else if (result.error) {
      this.mapMarkers = undefined;
      this.error = result.error;
    }
  }

  buildMapMarkers(propertyList) {
    const locationList = [];

    propertyList.forEach(element => {
      const marker = {
        location: {}
      };
      marker.location.Street = element.No_of_Rooms__c + ' Rooms, ' 
                              + element.No_of_Bathrooms__c + ' Bathrooms.' 
      marker.location.Latitude = element.Geolocation__Latitude__s;
      marker.location.Longitude = element.Geolocation__Longitude__s;
      marker.icon = 'standard:home';
      marker.title = element.Name__c;
      marker.description = element.No_of_Rooms__c + ' Rooms, ' 
                          + element.No_of_Bathrooms__c + ' Bathrooms.' 
                          + '</br>' 
                          + '$' + element.Est_Min_Price__c
                          + ' ~ '
                          + '$' + element.Est_Max_Price__c;
                          
      locationList.push(marker);
    });

    return locationList;
  }  
}
