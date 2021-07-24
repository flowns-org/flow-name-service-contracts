import Flowns from 0xFlowns
import FungibleToken from 0xFungibleToken

transaction(domainId:UInt64, amount: UFix64) {
  let client: &Flowns.Admin
  let receiver:Capability<&{FungibleToken.Receiver}>
  prepare(account: AuthAccount) {
    self.receiver = account.getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    self.client= account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.withdrawVault(domainId: domainId, receiver: self.receiver, amount: amount)
  }
}
