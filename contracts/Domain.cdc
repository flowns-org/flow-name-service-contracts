import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"

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
    pub event DomainRecordChanged(name: String, resovler:Address)
    // todo events update

    pub resource interface DomainPublic {
      pub fun getText(key: String):String
      pub fun getAddress(chainType: UInt64):String
      pub fun getAllText():{String:String}
      pub fun getAllAddresses():{UInt64:String}
      
    }

    pub resource interface DomainPrivate {
        access(account) fun setText(_ key: String, value: String)
        access(account) fun setAddres(_ chainType: UInt64, address: String)
        access(account) fun removeText(_ chainType: UInt64)
        access(account) fun removeAddress(_ chainType: UInt64)
        access(account) fun setRecord(_ address: Address)


    }

    pub resource Subdomain: DomainPublic, DomainPrivate {
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String: String}
        pub let parent: String
        pub let expiredTip: String

        init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addreses = {}
            self.texts={}
            self.parent=parent
            self.parentNameHash = parentNameHash
            self.expiredTip = "Subdomain is expired please renew your parent domain."
        }

        fun checkParentExpired():Bool {
          let currentTimestamp = getCurrentBlock().timestamp
          return currentTimestamp >= Domain.expired[self.nameHash]
        }

        pub fun getText(key:string):String {
          pre {
            checkParentExpired() : self.expiredTip
          }
          return self.texts[key]
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
            checkParentExpired() : self.expiredTip
          }
          return self.addresses[chainType]
        }

        pub fun getAllText():{String:String}{
           pre {
            checkParentExpired() : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
            checkParentExpired() : self.expiredTip
          }
          return self.addresses
        }

        access(account) fun setText(_ key: String, value: String){
           pre {
            checkParentExpired() : self.expiredTip
          }
          self.texts[key] = value
        }
        access(account) fun setAddres(_ chainType: UInt64, address: String){
           pre {
            checkParentExpired() : self.expiredTip
          }
          self.addresses[chainType] = addreses
        }
        access(account) fun removeText(_ key: String){
           pre {
            checkParentExpired() : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        access(account) fun removeAddress(_ chainType: UInt64){
           pre {
            checkParentExpired() : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }
    }

    pub resource Domain : DomainPublic, DomainPrivate{
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String:String}
        pub let subdomains:{String: Sub}
        pub let subdomainCount:UInt64
        pub let expiredAt: UInt64
        pub let expiredTip: String
        access(contract) var content: String

        init(id: UInt64, name: String, nameHash: String, expiredAt:UInt64) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.svg = "" // TODO generate with svg
            self.subdomainCount = 0
            self.expiredAt = expiredAt
            self.subdomains <- {}
            self.expiredTip = "Domain is expired pls renew it"
        }

        pub fun getText(key:string):String {
          pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.texts[key]
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          return self.addresses[chainType]
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

        access(account) fun setText(_ key: String, value: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.texts[key] = value
        }
        access(account) fun setAddres(_ chainType: UInt64, address: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.addresses[chainType] = addreses
        }
        access(account) fun removeText(_ key: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        access(account) fun removeAddress(_ chainType: UInt64){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

        // set domain record
        access(account) fun setRecord(_ address: Address){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          // todo hash string
          Domains.records[self.nameHash] = addreses
          emit DomainRecordChanged(name: self.name, resolver: address)
        }

        access(account) fun createSubDomain(_ name: String, nameHash: String, parent: String){
           pre {
            self.expiredAt >= getCurrentBlock().timestamp : self.expiredTip
          }
          let subdomain <- create Subdomain(
            id:self.subdomainCount,
            name:name,
            nameHash:nameHash,
            parent: self.name,
            parentNameHash:self.nameHash
          )
          let oldSubdomain<- self.subdomains[subdomain.nameHash] <- subdomain
          Domain.totalSupply = Domains.totalSupply + (1 as UInt64)
          self.subdomainCount = self.subdomainCount + (1 as UInt64)
          
          emit CreatedSubDomain(subdomain.id, subdomain.nameHash)
          destroy oldSubdomain
        }

        access(account) fun removeSubDomain(_ nameHash: String){
          
          Domains.totalSupply = Domains.totalSupply - (1 as UInt64)
          self.subdomainCount = self.subdomainCount - (1 as UInt64)
          token <- self.subdomains.remove(key: nameHash)
          destroy token
          emit RemoveSubDomain(subdomain.id, subdomain.nameHash)
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
        pub fun svg(_ id: UInt64): String? 
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

            let id: UInt64 = token.id
            token.setRecord(self.owner?.address)
            // add the new token to the dictionary which removes the old one
            let oldToken <- self.domains[id] <- token

            emit Deposit(id: id, name:token.nameHash, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.domains.keys
        }

        pub fun svg(_ id: UInt64) : String {
            return self.domains[id]?.svg ?? panic("domain svg does not exist")
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowDomain(id: UInt64): &{Art.Public}? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Domains.Domain
            } else {
                return nil
            }
        }

        access(contract) fun createSubdomain(id:UInt64, name:String, nameHash:String){
          pre {
                self.domains[id] == nil:
                    "domain does not exist in this collection"
            }
            let itemRef = &self.domains[id] as &Domain
            itemRef.createSubDomain(name:name, nameHash: nameHash, parent: itemRef.name)
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
    self.register = {}
    self.expired = {}
    let account =self.account
    account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
    account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)

    emit ContractInitialized()
	}
}

