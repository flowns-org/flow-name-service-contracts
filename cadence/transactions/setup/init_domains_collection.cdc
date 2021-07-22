
import Domains from 0xDomains

transaction() {
    prepare(account: AuthAccount) {
        account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        account.link<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
        account.link<&Domains.Collection>(Domains.CollectionPrivatePath, target: Domains.CollectionStoragePath)
    }
}