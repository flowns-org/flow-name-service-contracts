import Flowns from 0xFlowns

transaction(ownerAddress: Address) {
    prepare(account: AuthAccount) {
        let owner= getAccount(ownerAddress)
        let client= owner.getCapability<&{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath)
                .borrow() ?? panic("Could not borrow admin client")
        let rootDomainCap=account.getCapability<&Flowns.RootDomainCollection>(Flowns.CollectionPrivatePath)
        
        client.addCapability(rootDomainCap)
        log("Admin server cap inited...")
    }

}
