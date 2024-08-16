

import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken

transaction(recipient: Address, amount: UFix64) {
    let tokenAdmin: &FlowToken.Administrator
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: auth(Storage, BorrowValue) &Account) {

        self.tokenAdmin = signer.storage
            .borrow<&FlowToken.Administrator>(from: /storage/flowTokenAdmin)!

        self.tokenReceiver = getAccount(recipient)
            .capabilities
            .borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)!

    }

    execute {
        let minter <- self.tokenAdmin.createNewMinter(allowedAmount: amount)
        let mintedVault <- minter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)

        destroy minter
    }
}