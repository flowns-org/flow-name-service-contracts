

// emulator
import Flowns from 0xf8d6e0586b0a20c7

// playground
// import Flowns from 0x05

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
