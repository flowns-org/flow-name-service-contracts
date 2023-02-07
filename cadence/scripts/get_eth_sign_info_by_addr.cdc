import Flowns from 0xFlowns
import Domains from 0xDomains

 pub fun main(address: Address): String? {
      
    let account = getAccount(address)
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
  
    if collectionCap.check() != true {
      return nil
    }
  
    var defaultDomain: &{Domains.DomainPublic}? = nil
    let collection = collectionCap.borrow()!
    let ids = collection.getIDs()
    defaultDomain = collection.borrowDomain(id: ids[0])!
    for id in ids {
      let domain = collection.borrowDomain(id: id)!
      let isDefault = domain.getText(key: "isDefault")
      if isDefault == "true" {
        defaultDomain = domain
        break
      }
    }

    let ethSigStr = defaultDomain!.getText(key: "_ethSig") ?? ""
  
    return ethSigStr
  }