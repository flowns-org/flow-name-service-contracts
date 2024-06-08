import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import LockedTokens from 0xLockedTokens
pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    let unlockedVault = account
      .getCapability(/public/flowTokenBalance)!
      .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")
    let unlockedBalance = unlockedVault.balance
        
    let lockedAccountInfoCap = account
      .getCapability
      <&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>
      (LockedTokens.LockedAccountInfoPublicPath)
    if lockedAccountInfoCap == nil || !(lockedAccountInfoCap!.check()) {
        return unlockedBalance
    }
    
    let lockedAccountInfoRef = lockedAccountInfoCap!.borrow()!
    let lockedBalance = lockedAccountInfoRef.getLockedAccountBalance()
    
    return lockedBalance + unlockedBalance
}