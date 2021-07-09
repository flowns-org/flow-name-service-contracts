

// emulator
import Flowns, Domains, NonFungibleToken from 0xf8d6e0586b0a20c7


//import NonFungibleToken from 0x1d7e57aa55817448
//import Art from 0xd796ff17107bbff6

// import NonFungibleToken from 0x2
// import Domains from 0x4

//This transaction will setup a domain collection
transaction() {
    prepare(account: AuthAccount) {
        // account.save<@NonFungibleToken.Collection>(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        // account.link<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
        account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
    }
}