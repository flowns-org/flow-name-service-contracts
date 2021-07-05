import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
// import NonFungibleToken from 0x02
// import FungibleToken from 0x01



pub contract Domains: NonFungibleToken {

    pub var totalSupply: UInt64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // domain records
    pub let records: {String: Address}
    // expired records
    pub let expired: {String: UFix64}


    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Created(id: UInt64, name:String)
    pub event DomainRecordChanged(name: String, resolver:Address)
    pub event SubDomainCreated(id: UInt64, hash:String)
    pub event SubDomainRemoved(id: UInt64, hash:String)
    // todo events update

    pub resource interface DomainPublic {
      pub let id: UInt64
      pub let name: String
      pub let nameHash: String
      pub let addresses:  {UInt64: String}
      pub let texts: {String:String}
      pub let parent: String
      pub fun getText(key: String):String
      pub fun getAddress(chainType: UInt64):String
      pub fun getAllText():{String:String}
      pub fun getAllAddresses():{UInt64:String}
    }

    pub resource interface DomainPrivate {
        access(account) fun setText(key: String, value: String)
        access(account) fun setAddress(chainType: UInt64, address: String)
        access(account) fun removeText(key: String)
        access(account) fun removeAddress(chainType: UInt64)
        access(account) fun setRecord(address: Address)
    }

    pub resource Subdomain: DomainPublic, DomainPrivate {
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String: String}
        pub let parent: String
        pub let parentNameHash: String
        pub let expiredTip: String

        init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.parent=parent
            self.parentNameHash = parentNameHash
            self.expiredTip = "Subdomain is expired please renew your parent domain."
        }

        pub fun checkParentExpired():Bool {
          let currentTimestamp = getCurrentBlock().timestamp
          return currentTimestamp >= Domains.expired[self.parentNameHash]!
        }

        pub fun getText(key:String):String {
          pre {
            self.checkParentExpired() : self.expiredTip
          }
          return self.texts[key]!
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
             self.checkParentExpired() : self.expiredTip
          }
          return self.addresses[chainType]!
        }

        pub fun getAllText():{String:String}{
           pre {
             self.checkParentExpired() : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
             self.checkParentExpired() : self.expiredTip
          }
          return self.addresses
        }

        access(account) fun setText(key: String, value: String){
           pre {
             self.checkParentExpired() : self.expiredTip
          }
          self.texts[key] = value
        }
        access(account) fun setAddress(chainType: UInt64, address: String){
           pre {
             self.checkParentExpired() : self.expiredTip
          }
          self.addresses[chainType] = address
        }
        access(account) fun removeText(key: String){
           pre {
            self.checkParentExpired() : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        access(account) fun removeAddress(chainType: UInt64){
           pre {
            self.checkParentExpired() : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

        access(account) fun setRecord(address: Address){
           pre {
            self.checkParentExpired() : self.expiredTip
          }
        }

        access(account) fun setExpire(_ expiredAt: UFix64){
          pre {
            self.checkParentExpired() : self.expiredTip
          }
        }

    }

    pub resource NFT: DomainPublic, DomainPrivate, NonFungibleToken.INFT{
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String:String}
        pub let subdomains:@{String: Subdomain}
        pub let expiredTip: String
        pub let parent: String
        pub var subdomainCount:UInt64
        pub var content: String

        init(id: UInt64, name: String, nameHash: String, parent: String, expiredAt:UFix64) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.content = "" // TODO generate with svg
            self.subdomainCount = 0
            self.subdomains <- {}
            self.parent = parent
            self.expiredTip = "Domain is expired pls renew it"
        }
        pub fun checkExpired():Bool {
          let currentTimestamp = getCurrentBlock().timestamp
          return currentTimestamp >= Domains.expired[self.nameHash]!
        }

        pub fun getText(key:String):String {
          pre {
            self.checkExpired() : self.expiredTip
          }
          return self.texts[key]!
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
            self.checkExpired() : self.expiredTip
          }
          return self.addresses[chainType]!
        }

        pub fun getAllText():{String:String}{
           pre {
            self.checkExpired() : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
            self.checkExpired() : self.expiredTip
          }
          return self.addresses
        }

        access(account) fun setText(key: String, value: String){
           pre {
            self.checkExpired() : self.expiredTip
          }
          self.texts[key] = value
        }
        access(account) fun setAddress(chainType: UInt64, address: String){
           pre {
            self.checkExpired() : self.expiredTip
          }
          self.addresses[chainType] = address
        }
        access(account) fun removeText(key: String){
           pre {
            self.checkExpired() : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        access(account) fun removeAddress(chainType: UInt64){
           pre {
            self.checkExpired() : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

        // set domain record
        access(account) fun setRecord(address: Address){
           pre {
            self.checkExpired() : self.expiredTip
          }
          // todo hash string
          Domains.records[self.nameHash] = address
          emit DomainRecordChanged(name: self.name, resolver: address)
        }

        access(account) fun createSubDomain(_ name: String, nameHash: String, parent: String){
           pre {
            self.checkExpired() : self.expiredTip
          }
          if self.subdomains[nameHash] !=nil{
            panic("Subdomain already existed.")
          }
          let subdomain <- create Subdomain(
            id:self.subdomainCount,
            name:name,
            nameHash:nameHash,
            parent: self.name,
            parentNameHash:self.nameHash
          )
          let oldSubdomain <- self.subdomains[nameHash] <- subdomain
          Domains.totalSupply = Domains.totalSupply + (1 as UInt64)
          self.subdomainCount = self.subdomainCount + (1 as UInt64)
          
          emit SubDomainCreated(id:self.subdomainCount, hash:nameHash)
          destroy oldSubdomain
        }

        access(account) fun removeSubDomain(nameHash: String){
          
          Domains.totalSupply = Domains.totalSupply - (1 as UInt64)
          self.subdomainCount = self.subdomainCount - (1 as UInt64)
          let oldToken <- self.subdomains.remove(key: nameHash) ?? panic("missing subdomain")
          emit SubDomainRemoved(id:oldToken.id, hash: nameHash)
          destroy oldToken

        }

         destroy() {
            destroy self.subdomains
        }
    }

    //return the content for this NFT
    pub resource interface CollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}?

    }

     //return the content for this NFT
    pub resource interface CollectionPrivate {
        pub fun mintDomain(id: UInt64, name:String, nameHash:String, parentName:String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)
    }


    pub resource Collection: CollectionPublic, CollectionPrivate, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        init () {
            self.ownedNFTs <- {}
        }


        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let domain <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing domain")
            
            emit Withdraw(id: domain.id, from: self.owner?.address)

            return <-domain
        }

        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Domains.NFT
            let id: UInt64 = token.id
            let nameHash = token.nameHash
            token.setRecord(address:self.owner?.address!)
            
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id,to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Domains.NFT
            } else {
                return nil
            }
        }

        pub fun mintDomain(id: UInt64, name:String, nameHash:String, parentName:String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
            let domain <- create Domains.NFT(
              id: id,
              name: name,
              nameHash: nameHash,
              parent: parentName,
              expiredAt:expiredAt
            )
            let nft <- domain
            Domains.expired[nameHash] = expiredAt
            Domains.records[nameHash]= receiver.address
            Domains.totalSupply = Domains.totalSupply + 1 as UInt64
            receiver.borrow()!.deposit(token: <- nft)
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
      let collection <- create Collection()
      return <- collection
    }


	init() {
    // Initialize the total supply
    self.totalSupply = 0
    self.CollectionPublicPath=/public/fnsDomainCollection
    self.CollectionStoragePath=/storage/fnsDomainCollection
    self.records = {}
    self.expired = {}
    let account =self.account
    account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
    account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)

    emit ContractInitialized()
	}
}

