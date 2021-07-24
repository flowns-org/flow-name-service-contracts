import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
// import NonFungibleToken from 0x02
// import FungibleToken from 0x01




pub contract Domains: NonFungibleToken {

    pub var totalSupply: UInt64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let CollectionPrivatePath: PrivatePath

    // domain records
    pub let records: {String: Address}
    // expired records
    pub let expired: {String: UFix64}


    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Created(id: UInt64, name:String)
    pub event DomainRecordChanged(name: String, resolver: Address)
    pub event DomainExpiredChanged(name: String, expiredAt: UFix64)
    pub event SubDomainCreated(id: UInt64, hash:String)
    pub event SubDomainRemoved(id: UInt64, hash:String)
    // todo events update



    pub struct SubdomainDetail {
    pub let owner: Address
    pub let name: String
    pub let nameHash: String
    pub let addresses: {UInt64: String}
    pub let texts: {String:String}
    pub let parentName: String
    pub let content: String
    
    init(
      owner: Address,
      name: String,
      nameHash: String, 
      addresses:{UInt64: String},
      texts: {String:String},
      parentName: String,
      content: String
      ) {
        self.owner=owner
        self.name=name
        self.nameHash=nameHash
        self.addresses=addresses
        self.texts=texts
        self.parentName=parentName
        self.content=content
      }
  }

    pub struct DomainDetail {
    pub let owner: Address
    pub let name: String
    pub let nameHash: String
    pub let expiredAt: UFix64
    pub let addresses: {UInt64: String}
    pub let texts: {String:String}
    pub let parentName: String
    pub let subdomainCount: UInt64
    pub let subdomains: [SubdomainDetail]
    pub let content: String

    init(
      owner: Address,
      name: String,
      nameHash: String, 
      expiredAt: UFix64,
      addresses:{UInt64: String},
      texts: {String:String},
      parentName: String,
      subdomainCount:UInt64,
      subdomains:[SubdomainDetail],
      content: String
      ) {
        self.owner=owner
        self.name=name
        self.nameHash=nameHash
        self.expiredAt=expiredAt
        self.addresses=addresses
        self.texts=texts
        self.parentName=parentName
        self.subdomainCount=subdomainCount
        self.subdomains=subdomains
        self.content=content
      }
  }

    pub resource interface DomainPublic {
      pub let id: UInt64
      pub let name: String
      pub let nameHash: String
      pub let addresses:  {UInt64: String}
      pub let texts: {String:String}
      pub let parent: String
      pub var subdomains: @{String:Subdomain}
      pub fun getText(key: String):String
      pub fun getAddress(chainType: UInt64):String
      pub fun getAllTexts():{String:String}
      pub fun getAllAddresses():{UInt64:String}
      pub fun getDomainName():String
      pub fun getDetail(): DomainDetail
      pub fun getSubdomainsDetail(): [SubdomainDetail]
    }

     pub resource interface SubdomainPublic {
      pub let id: UInt64
      pub let name: String
      pub let nameHash: String
      pub let addresses:  {UInt64: String}
      pub let texts: {String:String}
      pub let parent: String
      pub fun getText(key: String):String
      pub fun getAddress(chainType: UInt64):String
      pub fun getAllTexts():{String:String}
      pub fun getAllAddresses():{UInt64:String}
      pub fun getDomainName():String
      pub fun getDetail(): SubdomainDetail
    }

    pub resource interface SubdomainPrivate {
        pub fun setText(key: String, value: String)
        pub fun setAddress(chainType: UInt64, address: String)
        pub fun removeText(key: String)
        pub fun removeAddress(chainType: UInt64)
    }


    pub resource interface DomainPrivate {
        pub fun setText(key: String, value: String)
        pub fun setAddress(chainType: UInt64, address: String)
        pub fun removeText(key: String)
        pub fun removeAddress(chainType: UInt64)
        pub fun createSubDomain(name: String, nameHash: String)
        pub fun removeSubDomain(nameHash: String)
        access(account) fun setRecord(address: Address)
        pub fun setSubdomainText(nameHash:String, key: String, value: String)
        pub fun setSubdomainAddress(nameHash:String, chainType: UInt64, address: String)
        pub fun removeSubdomainText(nameHash:String, key: String)
        pub fun removeSubdomainAddress(nameHash:String, chainType: UInt64)
    }

    pub resource Subdomain: SubdomainPublic, SubdomainPrivate {
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String: String}
        pub let parent: String
        pub let parentNameHash: String
        pub let content:String
        pub let expiredTip: String

        init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
            self.id = id
            self.name=name
            self.nameHash = nameHash
            self.addresses = {}
            self.texts={}
            self.parent=parent
            self.parentNameHash = parentNameHash
            self.content = ""
            self.expiredTip = "Subdomain is expired please renew your parent domain."
        }

        pub fun getDomainName():String {
          let domainName = ""
          return domainName.concat(self.name).concat(".").concat(self.parent)
        }

        pub fun getText(key:String):String {
          pre {
            !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          return self.texts[key]!
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          return self.addresses[chainType]!
        }

        pub fun getAllTexts():{String:String}{
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          return self.addresses
        }

        pub fun getDetail(): SubdomainDetail {
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          let owner = Domains.records[self.parentNameHash]!
          let detail = SubdomainDetail(
            owner:owner,
            name: self.getDomainName(), 
            nameHash: self.nameHash,
            addresses:self.getAllAddresses(),
            texts: self.getAllTexts(),
            parentName: self.parent,
            content:self.content
          )
          return detail
        }


        pub fun setText(key: String, value: String){
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          self.texts[key] = value
        }
        pub fun setAddress(chainType: UInt64, address: String){
           pre {
             !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          self.addresses[chainType] = address
        }
        pub fun removeText(key: String){
           pre {
            !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        pub fun removeAddress(chainType: UInt64){
           pre {
            !Domains.isExpired(self.parentNameHash) : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

    }


    pub resource NFT: DomainPublic, DomainPrivate, NonFungibleToken.INFT{
        pub let id: UInt64
        pub let name: String
        pub let nameHash: String
        pub let addresses:  {UInt64: String}
        pub let texts: {String:String}
        pub var subdomains: @{String: Subdomain}
        pub let expiredTip: String
        pub let parent: String
        pub var subdomainCount:UInt64
        pub var content: String

        init(id: UInt64, name: String, nameHash: String, parent: String) {
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
        

        pub fun getDomainName():String {
          let domainName = ""
          return domainName.concat(self.name).concat(".").concat(self.parent)
        }

        pub fun getText(key:String):String {
          pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          return self.texts[key]!
        }

        pub fun getAddress(chainType:UInt64):String {
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          return self.addresses[chainType]!
        }

        pub fun getAllTexts():{String:String}{
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          return self.texts
        }

        pub fun getAllAddresses():{UInt64:String}{
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          return self.addresses
        }

        pub fun setText(key: String, value: String){
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          self.texts[key] = value
        }
        pub fun setAddress(chainType: UInt64, address: String){
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          self.addresses[chainType] = address
        }
        pub fun removeText(key: String){
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          self.texts.remove(key: key)
        }
        pub fun removeAddress(chainType: UInt64){
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          self.addresses.remove(key: chainType)
        }

          pub fun setSubdomainText(nameHash:String, key: String, value: String){
           pre {
             !Domains.isExpired(self.nameHash) : self.expiredTip
             self.subdomains[nameHash] != nil : "Subdomain not exsit..."
          }
          let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
          subdomain.setText(key: key, value: value)
        }
        pub fun setSubdomainAddress(nameHash:String, chainType: UInt64, address: String){
           pre {
             !Domains.isExpired(self.nameHash) : self.expiredTip
             self.subdomains[nameHash] != nil : "Subdomain not exsit..."
          }
          let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
          subdomain.setAddress(chainType: chainType, address: address)
        }
        pub fun removeSubdomainText(nameHash:String, key: String) {
           pre {
             !Domains.isExpired(self.nameHash) : self.expiredTip
             self.subdomains[nameHash] != nil : "Subdomain not exsit..."
          }
          let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
          subdomain.removeText(key: key)
        }
        pub fun removeSubdomainAddress(nameHash:String, chainType: UInt64) {
           pre {
             !Domains.isExpired(self.nameHash) : self.expiredTip
             self.subdomains[nameHash] != nil : "Subdomain not exsit..."
          }
          let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
          subdomain.removeAddress(chainType: chainType)
        }

        
        pub fun getDetail(): DomainDetail {
           pre {
             !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          let owner = Domains.records[self.nameHash]!
          let expired = Domains.expired[self.nameHash]!
          
          let ids = self.subdomains.keys
          var subdomains:[SubdomainDetail] = []
          for id in ids {
            let subRef = &self.subdomains[id] as! auth &Subdomain
            let detail = subRef.getDetail()
            subdomains.append(detail)
          }

          let detail = DomainDetail(
            owner:owner,
            name: self.getDomainName(), 
            nameHash: self.nameHash,
            expiredAt:expired,
            addresses:self.getAllAddresses(),
            texts: self.getAllTexts(),
            parentName: self.parent,
            subdomainCount: self.subdomainCount,
            subdomains:subdomains,
            content:self.content
          )
          return detail
        }

        pub fun getSubdomainsDetail(): [SubdomainDetail] {
          let ids = self.subdomains.keys
          var subdomains:[SubdomainDetail] = []
          for id in ids {
            let subRef = &self.subdomains[id] as! auth &Subdomain
            let detail = subRef.getDetail()
            subdomains.append(detail)
          }
          return subdomains
        }

        // set domain record
        access(account) fun setRecord(address: Address){
          pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          Domains.records[self.nameHash] = address
          emit DomainRecordChanged(name: self.name, resolver: address)
        }

        // set domain expired
        access(account) fun setExpired(expiredAt: UFix64){
          
          Domains.expired[self.nameHash] = expiredAt
          emit DomainExpiredChanged(name: self.name, expiredAt: expiredAt)
        }

        pub fun createSubDomain(name: String, nameHash: String){
           pre {
            !Domains.isExpired(self.nameHash) : self.expiredTip
          }
          if self.subdomains[nameHash] !=nil {
            panic("Subdomain already existed.")
          }
          let subdomain <- create Subdomain(
            id:self.subdomainCount,
            name:name,
            nameHash:nameHash,
            parent: self.getDomainName(),
            parentNameHash:self.nameHash
          )
          let oldSubdomain <- self.subdomains[nameHash] <- subdomain
          Domains.totalSupply = Domains.totalSupply + (1 as UInt64)
          self.subdomainCount = self.subdomainCount + (1 as UInt64)
          
          emit SubDomainCreated(id:self.subdomainCount, hash:nameHash)
          destroy oldSubdomain
        }

        pub fun removeSubDomain(nameHash: String){
          
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
        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}
    }

     //return the content for this NFT
    pub resource interface CollectionPrivate {
        access(account) fun mintDomain(id: UInt64, name:String, nameHash:String, parentName:String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)
        pub fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT
        // pub fun borrowSubDomainPrivate(id: UInt64, nameHash:String): &Subdomain
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

        pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic} {
          let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
          return ref as! &Domains.NFT
        }

        pub fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT {
          pre {
              self.ownedNFTs[id] != nil:
                  "domain doesn't exist"
          }
          let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
          return ref as! &Domains.NFT
        }

        //  pub fun borrowSubDomainPrivate(id: UInt64, nameHash: String ): &Subdomain {
        //   pre {
        //       self.ownedNFTs[id] != nil:
        //           "domain doesn't exist"
        //   }
        //   let domainRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        //   let domain = domainRef as! &Domains.NFT
        //   let sub = &domain.subdomains[nameHash] as! &Subdomain
        //   return sub
        // }



        access(account) fun mintDomain(id: UInt64, name:String, nameHash:String, parentName:String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
          pre{
            Domains.records[nameHash] == nil : "domain not available"
          }
            let domain <- create Domains.NFT(
              id: id,
              name: name,
              nameHash: nameHash,
              parent: parentName,
            )
            let nft <- domain
            Domains.expired[nameHash] = expiredAt
            // Domains.records[nameHash]= receiver.address
            nft.setRecord(address: receiver.address)
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

    pub fun domainExpiredTime(_ nameHash: String) :UFix64? {
      let expiredTime = Domains.expired[nameHash]
      return expiredTime
    }

    pub fun isExpired(_ nameHash:String): Bool {
      let currentTimestamp = getCurrentBlock().timestamp
      let expiredTime =  Domains.expired[nameHash]
      if expiredTime != nil {
        // make one day buffer 
        return (currentTimestamp - 86400.00) > expiredTime!
      } 
      return false
    }

    pub fun domainRecord(_ nameHash: String) :Address? {
      let address = Domains.records[nameHash]
      return address
    }

    

	init() {
    // Initialize the total supply
    self.totalSupply = 0
    self.CollectionPublicPath=/public/fnsDomainCollection
    self.CollectionStoragePath=/storage/fnsDomainCollection
    self.CollectionPrivatePath=/private/fnsDomainCollection
    
    self.records = {}
    self.expired = {}
    let account =self.account
    account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
    account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
    // account.link<&Domains.Collection>(Domains.CollectionPrivatePath, target: Domains.CollectionStoragePath)
    emit ContractInitialized()
	}
}

