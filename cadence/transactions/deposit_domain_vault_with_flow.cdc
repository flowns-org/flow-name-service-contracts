import Flowns from 0xFlowns
import Domains from 0xDomains
import FlowToken from 0xFlowToken

transaction(domainNameHash: String, amount: UFix64) {
  var domain: &{Domains.DomainPublic}
  var vaultRef: &FlowToken.Vault
  prepare(account: AuthAccount) {
    let address = Domains.getRecords(domainNameHash) ?? panic("Domain not exsit")
    let collectionCap = getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath) 
    let collection = collectionCap.borrow()!
    var domain: &{Domains.DomainPublic}? = nil

   
    let id = Domains.getDomainId(domainNameHash)
    if id != nil && !Domains.isDeprecated(nameHash: domainNameHash, domainId: id!) {
      domain = collection.borrowDomain(id: id!)
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

