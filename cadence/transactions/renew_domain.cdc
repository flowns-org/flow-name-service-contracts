import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(domainId:UInt64, nameHash:String, duration:UFix64, amount: UFix64) {
  let vault: @FungibleToken.Vault
  // let domainCap:Capability<&{Domains.DomainPublic}>
  var domain: &Domains.NFT
  prepare(account: AuthAccount) {
    let collectionRef = account.borrow<&{Domains.CollectionPublic}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    var domain: &Domains.NFT? = nil
    let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
    
    let ids = collectionRef.getIDs()
    for id in ids {
      let item = collectionRef.borrowDomain(id:id)
      if item.nameHash == nameHash {
        domain = collectionPrivate.borrowDomainPrivate(id)
      } 
    }
    self.domain = domain!
    let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner's Vault reference")
    
    self.vault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    Flowns.renewDomain(domainId: domainId, domain: self.domain, duration: duration, feeTokens: <- self.vault)
  }
}
