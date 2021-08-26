import Flowns from 0xFlowns

transaction(domainId:UInt64, rate: UFix64) {
  let client: &Flowns.Admin
  prepare(account: AuthAccount) {
      self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.setCommissionRate(domainId:domainId, rate: rate)
  }
}