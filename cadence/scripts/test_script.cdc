import Flowns from 0xFlowns
import Domains from 0xDomains

 pub fun main(address: Address): String? {
      
        let account = getAccount(address)
        let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
     
        if collectionCap.check() != true {
          return nil
        }
     
        var flownsName = ""
        let collection = collectionCap.borrow()!
        let ids = collection.getIDs()
        
        for id in ids {
          let domain = collection.borrowDomain(id: id)!
          let isDefault = domain.getText(key: "isDefault")
          flownsName = domain.getDomainName()
          if isDefault == "true" {
            break
          }
        }
     
        return flownsName
      }