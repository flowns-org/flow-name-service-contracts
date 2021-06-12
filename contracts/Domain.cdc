import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"

pub contract Domains {

    pub var totalSupply: UInt64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPrivatePath: PrivatePath

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Created(id: UInt64)




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

    }

    pub resouce Subdomain: DomainPublic, DomainPrivate {
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String: String}
        pub let parent: String

        init(id: UInt64, name: String, nameHash: String, parent: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addreses = {}
            self.texts={}
            self.parent=parent
        }

        pub fun getText(key:string):String {
          return self.texts[key]
        }

        pub fun getAddress(chainType:UInt64):String {
          return self.addresses[chainType]
        }

        pub fun getAllText():{String:String}{
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
          return self.addresses
        }

        access(account) fun setText(_ key: String, value: String){
          self.texts[key] = value
        }
        access(account) fun setAddres(_ chainType: UInt64, address: String){
          self.addresses[chainType] = addreses
        }
        access(account) fun removeText(_ chainType: UInt64){
          self.texts.remove(chainType)
        }
        access(account) fun removeAddress(_ chainType: UInt64){
          self.addresses.remove(chainType)
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

        access(contract) var content: String

        init(id: UInt64, name: String, nameHash: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.svg = "" // TODO generate with svg
            self.subdomainCount = 0
            self.subdomains <- {}
        }


        pub fun getText(key:string):String {
          return self.texts[key]
        }

        pub fun getAddress(chainType:UInt64):String {
          return self.addresses[chainType]
        }

        pub fun getAllText():{String:String}{
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
          return self.addresses
        }

        access(account) fun setText(_ key: String, value: String){
          self.texts[key] = value
        }
        access(account) fun setAddres(_ chainType: UInt64, address: String){
          self.addresses[chainType] = addreses
        }
        access(account) fun removeText(_ chainType: UInt64){
          self.texts.remove(chainType)
        }
        access(account) fun removeAddress(_ chainType: UInt64){
          self.addresses.remove(chainType)
        }

        access(account) fun createSubDomain(name: String, nameHash: String, parent: String){
          let subdomain <- create Subdomain(
            id:self.subdomainCount,
            name:name,
            nameHash:nameHash,
            parent: self.name
          )
          let oldSubdomain<- self.subdomains[subdomain.nameHash] <- subdomain
          self.subdomainCount = self.subdomainCount + (1 as UInt64)

          destroy oldSubdomain
        }

        // TODO remove subdomain

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

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.domains[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

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

        access(account) fun createSubdomain(id:UInt64, name:String){
          pre {
                self.domains[id] != nil:
                    "domain does not exist in this collection"
            }
            let itemRef = &self.domains[id] as &Domain
            itemRef.createSubDomain(name:name, nameHash: itemRef.nameHash, parent: itemRef.name)
        }

        destroy() {
            destroy self.domains
        }
    }

    access(account) fun createEmptyCollection(): @Domains.Collection {
        return <- create Collection()
    }


	init() {
        // Initialize the total supply
        self.totalSupply = 0
        self.CollectionPrivatePath=/private/fnsDomainCollection
        self.CollectionStoragePath=/storage/fnsDomainCollection

        let account =self.account
        account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
        account.link<&Domains.Collection>(Domains.CollectionPrivatePath, target: Domains.CollectionStoragePath)

        emit ContractInitialized()
	}
}
