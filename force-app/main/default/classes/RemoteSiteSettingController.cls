public class RemoteSiteSettingController {
    
  @AuraEnabled
  public static boolean createRemoteSiteSettings(String siteUrl){
    boolean isSucessful = false;

        if (String.isBlank(siteUrl)) return isSucessful;

          Map<string, string> RemoteSiteMap = new Map<string, string>();
          
          //specify the remote site name and url in RemoteSiteMap
          RemoteSiteMap.put('localhost_remote_site_' + String.valueOf(System.today()).replace('-', '_') + '_' + Integer.valueof((Math.random() * 10)), siteUrl);

          List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
          
          for(string site : RemoteSiteMap.keyset()){
              MetadataService.RemoteSiteSetting remoteSiteDetails = new MetadataService.RemoteSiteSetting();
              remoteSiteDetails.fullName = site;
              remoteSiteDetails.description = site + ' - created through apex.';
              remoteSiteDetails.disableProtocolSecurity = false;
              remoteSiteDetails.isActive = true;
              remoteSiteDetails.url = RemoteSiteMap.get(site);
              allMetadataList.add(remoteSiteDetails);
          }  

          if (allMetadataList.size() > 0){
              system.debug('****RemoteSiteSettings allMetadataList: ' + allMetadataList);
              MetadataService.MetadataPort service = createService();
              List<MetadataService.UpsertResult> results = service.upsertMetadata(allMetadataList);
              
              for(MetadataService.UpsertResult result : results){
                  if (result.success){
                      system.debug('added remote site setting success = ' + result);
                      isSucessful = true;
                  } else {
                      system.debug('****error while adding remote site settings: ' + result.errors[0].message);
                  }
              }
          }

          return isSucessful;
      }  
    
      private static MetadataService.MetadataPort createService(){ 
          MetadataService.MetadataPort service = new MetadataService.MetadataPort();
          service.SessionHeader = new MetadataService.SessionHeader_element();
          //service.SessionHeader.sessionId = UserInfo.getSessionId();
          service.SessionHeader.sessionId = GlobalUtility.getSessionIdFromVFPage(Page.SessionId);
          
          return service;     
      }
  }