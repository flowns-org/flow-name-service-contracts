import Flowns from 0xFlowns
import Domains from 0xDomains

transaction(id: UInt64) {
    var client: &Flowns.Admin
    var cap: Capability<&Domains.Collection>
    prepare(account: auth(Storage, BorrowValue) &Account) {
      self.client = account.storage.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath)
      self.cap = account.capabilities.get<&Domains.Collection>(Domains.CollectionPrivatePath)
    }
    execute {
      self.client.addRootDomainCapability(domainId: id, cap: self.cap)
    }
}
