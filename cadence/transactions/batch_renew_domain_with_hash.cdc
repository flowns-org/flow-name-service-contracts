import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction(nameHashs: [String], duration: UFix64, refer: Address) {
  let vaultRef: &FungibleToken.Vault
  let prices: {String:{Int: UFix64}}
  let collectionCap: &{Domains.CollectionPublic}
  prepare(account: AuthAccount) {
    self.collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath).borrow()!

    self.vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner's Vault reference")
    
    // self.vault <- vaultRef.withdraw(amount: amount)

    self.prices = {}
    let roots: {UInt64: Flowns.RootDomainInfo}? = Flowns.getAllRootDomains()
    let keys = roots!.keys
    for key in keys {
      let root = roots![key]!
      self.prices[root.name] = root.prices
    }
  }

  execute {
    var idx = 1
    for nameHash in nameHashs {
      idx = idx + 1
      let id = Domains.getDomainId(nameHash)
      let address = Domains.getRecords(nameHash)!
      let collectionCap = getAccount(address).getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath).borrow()!
      let domain = collectionCap.borrowDomain(id: id!)
      var len = domain.name.length
      if len > 10 {
        len = 10
      }
      let price = self.prices[domain.parent]![len]!
      if idx != nameHashs.length {
        Flowns.renewDomainWithNameHash(nameHash: nameHash, duration: duration, feeTokens: <- self.vaultRef.withdraw(amount: price * duration), refer: refer)
      } else {
        Flowns.renewDomainWithNameHash(nameHash: nameHash, duration: duration, feeTokens: <- self.vaultRef.withdraw(amount: price * duration), refer: refer)
      }
    }
  }
}
 