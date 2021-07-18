
import Domains from 0xDomains

transaction() {
    prepare(account: AuthAccount) {
        account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
    }
}