import Flowns from 0xFlowns

transaction() {
    prepare(account: AuthAccount) {
        let client = account.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
        let rootDomainCap = account.getCapability<&Flowns.RootDomainCollection>(Flowns.CollectionPrivatePath)
        
        client.addCapability(rootDomainCap)
        log("Admin server cap inited...")
    }

}
 