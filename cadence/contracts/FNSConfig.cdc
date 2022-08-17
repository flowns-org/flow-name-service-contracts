
pub contract FNSConfig {

  access(self) let inboxFTWhitelist: {String: Bool}
  access(self) let inboxNFTWhitelist: {String: Bool}

  access(self) let _reservedFields: {String: AnyStruct}

  access(self) let rootDomainConfig: {String: {String: AnyStruct}}



  access(account) fun setFTWhitelist(key: String, flag: Bool) {
    self.inboxFTWhitelist[key] = flag
  }

  access(account) fun setNFTWhitelist(key: String, flag: Bool) {
    self.inboxNFTWhitelist[key] = flag
  }

  pub fun checkFTWhitelist(_ typeIdentifier: String) :Bool {
    return self.inboxFTWhitelist[typeIdentifier] ?? false
  }

   pub fun checkNFTWhitelist(_ typeIdentifier: String) :Bool {
    return self.inboxNFTWhitelist[typeIdentifier] ?? false
  }

  
  pub fun getWhitelist(_ type: String): {String: Bool} {
    if type == "NFT" {
      return self.inboxNFTWhitelist
    }
    return self.inboxFTWhitelist
  }


  init() {
    self.inboxFTWhitelist = {}
    self.inboxNFTWhitelist = {}
    self._reservedFields = {}
    self.rootDomainConfig = {}
  }
}