import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
// key will be 'A.0ae53cb6e3f42a79.FlowToken.Vault' for flowtoken
transaction(nameHash: String, key: String, amount: UFix64) {
  var domain: &{Domains.DomainPrivate}
  var vaultRef: &FlowToken.Vault
  prepare(account: AuthAccount) {
    let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPrivate}? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = collection.getIDs()

    for id in ids {
      var item = collection.borrowDomain(id: id)
      if item.nameHash == nameHash {
        domain = collectionPrivate.borrowDomainPrivate(id)
      } 
    }
    self.domain = domain!
    self.vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
    ?? panic("Could not borrow reference to the owner's Vault!")
  }
  execute {
    self.vaultRef.deposit(from: <- self.domain.withdrawVault(key: key, amount: amount))
  }
}
