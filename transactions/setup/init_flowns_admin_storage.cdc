

// emulator
import NonFungibleToken, Domains, Flowns from 0xf8d6e0586b0a20c7

// playground
// import NonFungibleToken from 0x02
// import Domains from 0x04
// import Flowns from 0x05


transaction() {
    prepare(account: AuthAccount) {
        let admin <- Flowns.createAdminClient()

        // Store the vault in the account storage
        account.save<@Flowns.Admin>(<-admin, to: Flowns.FlownsAdminStoragePath)

        log("Empty admin stored")

        // Create a public Receiver capability to the Vault
        let adminRef = account.link<&Flowns.Admin{Flowns.AdminPublic}>(Flowns.FlownsAdminPublicPath, target: Flowns.FlownsAdminStoragePath)

        log("References created")
    }

}

