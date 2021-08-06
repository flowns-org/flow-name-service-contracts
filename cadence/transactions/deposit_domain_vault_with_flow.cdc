import Flowns from 0xFlowns
import Domains from 0xDomains
import FlowToken from 0xFlowToken

transaction(domainNameHash: String, amount: UFix64) {
  var domain: &{Domains.DomainPublic}
  var vaultRef: &FlowToken.Vault
  prepare(account: AuthAccount) {
    let address = Domains.records[domainNameHash] ?? panic("Domain not exsit")
    let collectionCap = getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPublic}? = nil

    let ids = collection.getIDs()

    for id in ids {
      var item = collection.borrowDomain(id: id)
      if item.nameHash == domainNameHash {
        domain = item
      } 
    }
    self.domain = domain!
    self.vaultRef = account.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")
  }
  execute {
    let sentVault <- self.vaultRef.withdraw(amount: amount)
    self.domain.depositVault(from: <- sentVault)
  }
}

