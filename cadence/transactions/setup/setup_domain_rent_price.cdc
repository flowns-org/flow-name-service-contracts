import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(id: UInt64, len: Int, price: UFix64) {
  let client: &Flowns.Admin
  prepare(account: AuthAccount) {
    self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.setRentPrice(domainId: id, len: len, price: price)
  }
}