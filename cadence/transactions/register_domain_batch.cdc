import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

  transaction(domainId: UInt64,  names: [String], duration: UFix64, amounts: [UFix64], refer: Address) {
    let collectionCap: Capability<&{NonFungibleToken.Receiver}>
    let vaultRef: &FungibleToken.Vault

    prepare(account: AuthAccount) {
      self.collectionCap = account.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
      let vaultRef = account.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
          ?? panic("Could not borrow owner's Vault reference")
      self.vaultRef = vaultRef
    }

  execute {
    var idx = 0
    while idx < names.length {
      Flowns.registerDomain(domainId: domainId, name: names[idx], duration: duration, feeTokens: <- self.vaultRef.withdraw(amount: amounts[idx]), receiver: self.collectionCap, refer: refer)
      idx = idx + 1
    }
  }
}