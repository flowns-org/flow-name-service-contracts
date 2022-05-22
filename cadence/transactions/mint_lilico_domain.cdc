import Domains from 0xDomains
import Flowns from 0xFlowns
import NonFungibleToken from 0xNonFungibleToken
import FungibleToken from 0xFungibleToken

transaction(name: String) {
  let client: &{Flowns.AdminPrivate}
  let receiver: Capability<&{NonFungibleToken.Receiver}>
  prepare(user: AuthAccount, lilico: AuthAccount, flowns: AuthAccount) {
    let userAcc = getAccount(user.address)
     // check user balance
    let userBalRef = userAcc.getCapability(/public/flowTokenBalance).borrow<&{FungibleToken.Balance}>()
    if userBalRef.balance < 0.001 {
      let balanceRef = flowns.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)
      let userReceiverRef =  userAcc.getCapability(/public/flowTokenReceiver).borrow<&{FungibleToken.Receiver}>()
      userReceiverRef.deposit(from: <- vaultRef.withdraw(amount: 0.001))
    }
  
    // init user's domain collection
    if user.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath).check() == false {
      if user.borrow<&Domains.Collection>(from: Domains.CollectionStoragePath) != nil {
        user.unlink(Domains.CollectionPublicPath)
        user.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
      } else {
        user.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        user.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic}>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
      }
    }

    self.receiver = userAcc.getCapability<&{NonFungibleToken.Receiver}>(Domains.CollectionPublicPath)
    
    self.client = flowns.borrow<&{Flowns.AdminPrivate}>(from: Flowns.FlownsAdminStoragePath) ?? panic("Could not borrow admin client")
  }
  execute {
    self.client.mintDomain(domainId: 1, name: name, duration: 3153600000.00, receiver: self.receiver)
  }
}
