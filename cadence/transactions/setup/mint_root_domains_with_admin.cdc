

// emulator
import Flowns from 0xf8d6e0586b0a20c7

// playground
// import Flowns from 0x05

//This transaction will create flow root domain
transaction() {

    let client: &Flowns.Admin

    prepare(account: AuthAccount) {

        self.client= account.borrow<&Flowns.Admin>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
        
        self.client.createRootDomain(name: "flow", nameHash: "0x9f1a2c1ae3169a570d1045fe9fc6cb93e68bcc86c545e8dda83ee4aeda090469")

        log("Root domain created")
    }

}
