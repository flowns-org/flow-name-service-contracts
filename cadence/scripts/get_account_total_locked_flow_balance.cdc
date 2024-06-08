import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import LockedTokens from 0xLockedTokens

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)

    let lockedAccountInfoCap = account
      .getCapability
      <&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>
      (LockedTokens.LockedAccountInfoPublicPath)
    if lockedAccountInfoCap == nil || !(lockedAccountInfoCap!.check()) {
        return UFix64(0)
    }
    
    let lockedAccountInfoRef = lockedAccountInfoCap!.borrow()!
    let lockedBalance = lockedAccountInfoRef.getLockedAccountBalance()
    
    return lockedBalance
}