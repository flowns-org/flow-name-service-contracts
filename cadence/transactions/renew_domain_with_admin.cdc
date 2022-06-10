import Flowns from 0xFlowns
import Domains from 0xDomains
import FungibleToken from 0xFungibleToken
import NonFungibleToken from 0xNonFungibleToken

transaction( nameHash: String, duration: UFix64) {
   let client: &Flowns.Admin

  prepare(account: AuthAccount) {
    self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }

  execute {
    self.client.renewDomain(nameHash: nameHash, duration: duration)
  }
}
