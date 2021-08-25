import Flowns from 0xFlowns

transaction(domainId:UInt64, minRentDuration: UFix64) {
  let client: &Flowns.Admin
  prepare(account: AuthAccount) {
      self.client = account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.setMinRentDuration(domainId:domainId, duration: minRentDuration)
  }
}