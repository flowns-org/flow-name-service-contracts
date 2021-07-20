import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(domainId:UInt64, nameHash:String, duration:UFix64, amount: UFix64) {
  // let vault: @FungibleToken.Vault
  // let domainCap:Capability<&{Domains.DomainPublic}>
  prepare(account: AuthAccount) {

    let collectionRef = account.borrow<&{Domains.CollectionPublic}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

    let ids = collectionRef.getIDs()
    log(ids)
    var domain = nil
    for id in ids {
      var item = collectionRef.borrowDomain(id:id)
      log("get info ==========")
      // log(item.name)
      // if item.nameHash == nameHash {
      //   domain = item
      // }
    }
    // domain ?? panic("Could not get domain")
    // self.domainCap = domain
    // let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
    //       ?? panic("Could not borrow owner's Vault reference")
    // self.vault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    // Flowns.renewDomain(domainId: domainId, domainCap: self.domainCap, duration: duration, feeTokens: <- self.vault)
  }
}
