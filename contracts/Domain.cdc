import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
// import NonFungibleToken from 0x02
// import FungibleToken from 0x01

pub contract Domains {

    pub var totalSupply: UInt64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    // domain records
    pub let records: {String: Address}
    // expired records
    pub let expired: {String: UFix64}


    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, name:String, to: Address?)
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
      pub let expiredAt: {String:String}
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
        pub let expiredAt: UFix64

        init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.parent=parent
            self.parentNameHash = parentNameHash
            self.expiredTip = "Subdomain is expired please renew your parent domain."
            self.expiredAt = 0.0
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

    }

    pub resource Domain : DomainPublic, DomainPrivate, NonFungibleToken.INFT{
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String:String}
        pub let subdomains:@{String: Subdomain}
        pub var subdomainCount:UInt64
        pub let expiredAt: UFix64
        pub let expiredTip: String
        pub let content: String

        init(id: UInt64, name: String, nameHash: String, expiredAt:UFix64) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.content = "" // TODO generate with svg
            self.subdomainCount = 0
            self.expiredAt = expiredAt
            self.subdomains <- {}
            self.expiredTip = "Domain is expired pls renew it"
        }

        pub fun getText(key:String):String {
          pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.texts[key]!
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.addresses[chainType]!
        }

        pub fun getAllText():{String:String}{
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.addresses
        }

        access(account) fun setText(key: String, value: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.texts[key] = value
        }
        access(account) fun setAddress(chainType: UInt64, address: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.addresses[chainType] = address
        }
        access(account) fun removeText(key: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        access(account) fun removeAddress(chainType: UInt64){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

        // set domain record
        access(account) fun setRecord(address: Address){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          // todo hash string
          Domains.records[self.nameHash] = address
          emit DomainRecordChanged(name: self.name, resolver: address)
        }

        access(account) fun createSubDomain(_ name: String, nameHash: String, parent: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
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
    pub resource interface PublicCollection {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    }

    pub resource Collection: PublicCollection, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        pub var domains: @{UInt64: NonFungibleToken.NFT}
        init () {
            self.domains <- {}
        }


        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let domain <- self.domains.remove(key: withdrawID) ?? panic("missing domain")
            
            emit Withdraw(id: domain.id, from: self.owner?.address)

            return <-domain
        }

        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Domains.Domain
            let id: UInt64 = token.id
            let nameHash = token.nameHash
            token.setRecord(address:self.owner?.address!)
            
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.domains[id] <- token as! @NonFungibleToken.NFT

            emit Deposit(id: id, name:nameHash, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.domains.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.domains[id] as &NonFungibleToken.NFT
        }

        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}? {
            if self.domains[id] != nil {
                let ref = &self.domains[id] as auth &NonFungibleToken.NFT
                return ref as! &Domains.Domain
            } else {
                return nil
            }
        }

        destroy() {
            destroy self.domains
        }
    }

    pub fun createEmptyCollection(): @Domains.Collection {
      return <- create Collection()
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

