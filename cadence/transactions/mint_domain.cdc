import Domains from 0xDomains
import Flowns from 0xFlowns
import NonFungibleToken from 0xNonFungibleToken

transaction(domainId: UInt64, name: String, duration: UFix64) {
  let client: &{Flowns.AdminPrivate}
  let receiver: Capability<&{NonFungibleToken.Receiver}>
  prepare(account: AuthAccount) {
    self.receiver = account.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    self.client = account.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.mintDomain(domainId: domainId, name: name, duration: duration, receiver: self.receiver)
  }
}
