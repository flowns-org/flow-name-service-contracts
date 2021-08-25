import Flowns from 0xFlowns

transaction(chars: String) {
  let client: &{Flowns.AdminPrivate}
  prepare(account: AuthAccount) {
    self.client = account.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.setDomainForbidChars(chars)
  }
}
