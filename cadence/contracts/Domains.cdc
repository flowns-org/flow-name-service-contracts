import NonFungibleToken from "./standard/NonFungibleToken.cdc"
import FungibleToken from "./standard/FungibleToken.cdc"
import FlowToken from "./tokens/FlowToken.cdc"
// Domains define the domain and sub domain resource
// Use records and expired to store domain's owner and expiredTime
pub contract Domains: NonFungibleToken {
  // Sum the domain number with domain and subdomain
  pub var totalSupply: UInt64

  // Paths
  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let CollectionPrivatePath: PrivatePath

  // Domain records to store the owner of Domains.Domain resource
  // When domain resource transfer to another user, the records will be update in the deposite func
  pub let records: {String: Address}

  // Expired records for Domains to check the domain's validity, will change at register and renew
  pub let expired: {String: UFix64}


  // Events
  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
  pub event Created(id: UInt64, name: String)
  pub event DomainRecordChanged(name: String, resolver: Address)
  pub event DomainExpiredChanged(name: String, expiredAt: UFix64)
  pub event SubDomainCreated(id: UInt64, hash: String)
  pub event SubDomainRemoved(id: UInt64, hash: String)
  pub event SubdmoainTextChanged(nameHash: String, key: String, value: String)
  pub event SubdmoainTextRemoved(nameHash: String, key: String)
  pub event SubdmoainAddressChanged(nameHash: String, chainType: UInt64, address: String)
  pub event SubdmoainAddressRemoved(nameHash: String, chainType: UInt64)
  pub event DmoainAddressRemoved(nameHash: String, chainType: UInt64)
  pub event DmoainTextRemoved(nameHash: String, key: String)
  pub event DmoainAddressChanged(nameHash: String, chainType: UInt64, address: String)
  pub event DmoainTextChanged(nameHash: String, key: String, value: String)
  pub event DomainMinted(id: UInt64, name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Address)
  pub event DomainVaultDeposited(vaultType: String, amount: UFix64, to: Address?)
  pub event DomainVaultWithdrawn(vaultType: String, amount: UFix64, from: String)


  // Subdomain detail
  pub struct SubdomainDetail {
  pub let owner: Address
  pub let name: String
  pub let nameHash: String
  pub let addresses: {UInt64: String}
  pub let texts: {String: String}
  pub let parentName: String
  
  init(
    owner: Address,
    name: String,
    nameHash: String, 
    addresses:{UInt64: String},
    texts: {String: String},
    parentName: String,
    ) {
      self.owner = owner
      self.name = name
      self.nameHash = nameHash
      self.addresses = addresses
      self.texts = texts
      self.parentName = parentName
    }
  }
  
  // Domain detail
  pub struct DomainDetail {
    pub let owner: Address
    pub let name: String
    pub let nameHash: String
    pub let expiredAt: UFix64
    pub let addresses: {UInt64: String}
    pub let texts: {String: String}
    pub let parentName: String
    pub let subdomainCount: UInt64
    pub let subdomains: {String: SubdomainDetail}
    pub let vaultBalances: {String: UFix64}


    init(
      owner: Address,
      name: String,
      nameHash: String, 
      expiredAt: UFix64,
      addresses: {UInt64: String},
      texts: {String: String},
      parentName: String,
      subdomainCount: UInt64,
      subdomains: {String: SubdomainDetail},
      vaultBalances: {String: UFix64}

    ) {

      self.owner = owner
      self.name = name
      self.nameHash = nameHash
      self.expiredAt = expiredAt
      self.addresses = addresses
      self.texts = texts
      self.parentName = parentName
      self.subdomainCount = subdomainCount
      self.subdomains = subdomains
      self.vaultBalances = vaultBalances
    } 
  }

  pub resource interface DomainPublic {

    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let addresses:  {UInt64: String}
    pub let texts: {String: String}
    pub let parent: String
    pub var subdomains: @{String: Subdomain}

    pub fun getText(key: String): String

    pub fun getAddress(chainType: UInt64): String

    pub fun getAllTexts():{String: String}

    pub fun getAllAddresses():{UInt64: String}

    pub fun getDomainName(): String

    pub fun getDetail(): DomainDetail

    pub fun getSubdomainsDetail(): [SubdomainDetail]

    pub fun depositVault(from: @FungibleToken.Vault)
  }

  pub resource interface SubdomainPublic {
    
    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let addresses:  {UInt64: String}
    pub let texts: {String: String}
    pub let parent: String

    pub fun getText(key: String): String

    pub fun getAddress(chainType: UInt64): String

    pub fun getAllTexts():{String: String}

    pub fun getAllAddresses():{UInt64: String}

    pub fun getDomainName(): String

    pub fun getDetail(): SubdomainDetail
  }

  pub resource interface SubdomainPrivate {

    pub fun setText(key: String, value: String)

    pub fun setAddress(chainType: UInt64, address: String)

    pub fun removeText(key: String)

    pub fun removeAddress(chainType: UInt64)
  }

  // Domain private for Domain resource owner manage domain and subdomain
  pub resource interface DomainPrivate {

    pub fun setText(key: String, value: String)

    pub fun setAddress(chainType: UInt64, address: String)

    pub fun removeText(key: String)

    pub fun removeAddress(chainType: UInt64)

    pub fun createSubDomain(name: String, nameHash: String)

    pub fun removeSubDomain(nameHash: String)

    access(account) fun setRecord(address: Address)
    
    pub fun setSubdomainText(nameHash: String, key: String, value: String)

    pub fun setSubdomainAddress(nameHash: String, chainType: UInt64, address: String)

    pub fun removeSubdomainText(nameHash: String, key: String)

    pub fun removeSubdomainAddress(nameHash: String, chainType: UInt64)

    pub var vaults: @{String: FungibleToken.Vault}

    pub fun withdrawVault(key: String, amount: UFix64): @FungibleToken.Vault

  }

  // Subdomain resource belongs Domain.NFT
  pub resource Subdomain: SubdomainPublic, SubdomainPrivate {

    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let addresses:  {UInt64: String}
    pub let texts: {String: String}
    pub let parent: String
    pub let parentNameHash: String
    pub let content: String
    pub let expiredTip: String

    init(id: UInt64, name: String, nameHash: String, parent: String, parentNameHash: String) {
      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.addresses = {}
      self.texts ={}
      self.parent = parent
      self.parentNameHash = parentNameHash
      self.content = ""
      self.expiredTip = "Subdomain is expired please renew your parent domain."
    }

    // Get subdomain full name with parent name
    pub fun getDomainName(): String {
      let domainName = ""
      return domainName.concat(self.name).concat(".").concat(self.parent)
    }

    // Get subdomain property
    pub fun getText(key: String): String {
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      return self.texts[key]!
    }

    // Get address of subdomain
    pub fun getAddress(chainType: UInt64): String {
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      return self.addresses[chainType]!
    }

    // get all texts
    pub fun getAllTexts():{String: String}{
        pre {
          !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      return self.texts
    }

    // get all texts
    pub fun getAllAddresses():{UInt64: String}{
        pre {
          !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      return self.addresses
    }

    // get subdomain detail
    pub fun getDetail(): SubdomainDetail {
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }

      let owner = Domains.records[self.parentNameHash]!

      let detail = SubdomainDetail(
        owner: owner,
        name: self.getDomainName(), 
        nameHash: self.nameHash,
        addresses: self.getAllAddresses(),
        texts: self.getAllTexts(),
        parentName: self.parent,
      )
      return detail
    }


    pub fun setText(key: String, value: String){
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      self.texts[key] = value

      emit SubdmoainTextChanged(nameHash: self.nameHash, key: key, value: value)
    }

    pub fun setAddress(chainType: UInt64, address: String){
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      self.addresses[chainType] = address

      emit SubdmoainAddressChanged(nameHash: self.nameHash, chainType: chainType, address: address)

    }

    pub fun removeText(key: String){
      pre {
      !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      self.texts.remove(key: key)

      emit SubdmoainTextRemoved(nameHash: self.nameHash, key: key)

    }

    pub fun removeAddress(chainType: UInt64){
      pre {
        !Domains.isExpired(self.parentNameHash) : self.expiredTip
      }
      self.addresses.remove(key: chainType)

      emit SubdmoainAddressRemoved(nameHash: self.nameHash, chainType: chainType)

    }

  }

  // Domain resource for NFT standard
  pub resource NFT: DomainPublic, DomainPrivate, NonFungibleToken.INFT{

    pub let id: UInt64
    pub let name: String
    pub let nameHash: String
    pub let addresses:  {UInt64: String}
    pub let texts: {String: String}
    pub var subdomains: @{String: Subdomain}
    pub let expiredTip: String
    // parent domain name
    pub let parent: String
    pub var subdomainCount: UInt64
    pub var vaults: @{String: FungibleToken.Vault}

    init(id: UInt64, name: String, nameHash: String, parent: String) {

      self.id = id
      self.name = name
      self.nameHash = nameHash
      self.addresses = {}
      self.texts = {}
      self.subdomainCount = 0
      self.subdomains <- {}
      self.parent = parent
      self.expiredTip = "Domain is expired pls renew it"
      self.vaults <- {}
    }
    
    // get domain full name with root domain
    pub fun getDomainName(): String {

      let domainName = ""
      return domainName.concat(self.name).concat(".").concat(self.parent)
    }

    pub fun getText(key: String): String {
      pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }
      return self.texts[key]!
    }

    pub fun getAddress(chainType: UInt64): String {
        pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }
      return self.addresses[chainType]!
    }

    pub fun getAllTexts():{String: String}{
        pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }
      return self.texts
    }

    pub fun getAllAddresses():{UInt64: String}{
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

      emit DmoainTextChanged(nameHash: self.nameHash, key: key, value: value)
    }

    pub fun setAddress(chainType: UInt64, address: String){
        pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }
      self.addresses[chainType] = address

      emit DmoainAddressChanged(nameHash: self.nameHash, chainType: chainType, address: address)

    }

    pub fun removeText(key: String){
        pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }

      self.texts.remove(key: key)
      
      emit DmoainTextRemoved(nameHash: self.nameHash, key: key)
    }

    pub fun removeAddress(chainType: UInt64){
        pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }

      self.addresses.remove(key: chainType)

      emit DmoainAddressRemoved(nameHash: self.nameHash, chainType: chainType)
    }

    pub fun setSubdomainText(nameHash: String, key: String, value: String){
      pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }

      let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
      subdomain.setText(key: key, value: value)
    }

    pub fun setSubdomainAddress(nameHash: String, chainType: UInt64, address: String){
      pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }

      let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
      subdomain.setAddress(chainType: chainType, address: address)
    }

    pub fun removeSubdomainText(nameHash: String, key: String) {
      pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
        self.subdomains[nameHash] != nil : "Subdomain not exsit..."
      }
      let subdomain = &self.subdomains[nameHash] as &{SubdomainPrivate}
      subdomain.removeText(key: key)
    }

    pub fun removeSubdomainAddress(nameHash: String, chainType: UInt64) {
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
      var subdomains:{String: SubdomainDetail} = {}
      for id in ids {
        let subRef = &self.subdomains[id] as! auth &Subdomain
        let detail = subRef.getDetail()
        subdomains[id] = detail
      }

      var vaultBalances:{String: UFix64} = {}
      let keys = self.vaults.keys
      for key in keys {
        let balRef = &self.vaults[key] as! &FungibleToken.Vault
        let balance = balRef.balance
        vaultBalances[key] = balance
      }

      let detail = DomainDetail(
        owner: owner,
        name: self.getDomainName(), 
        nameHash: self.nameHash,
        expiredAt: expired,
        addresses: self.getAllAddresses(),
        texts: self.getAllTexts(),
        parentName: self.parent,
        subdomainCount: self.subdomainCount,
        subdomains: subdomains,
        vaultBalances:vaultBalances
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

    // create subdomain with domain
    pub fun createSubDomain(name: String, nameHash: String){
      pre {
        !Domains.isExpired(self.nameHash) : self.expiredTip
      }
      
      if self.subdomains[nameHash] != nil {
        panic("Subdomain already existed.")
      }
      let subdomain <- create Subdomain(
        id: self.subdomainCount,
        name: name,
        nameHash: nameHash,
        parent: self.getDomainName(),
        parentNameHash: self.nameHash
      )

      let oldSubdomain <- self.subdomains[nameHash] <- subdomain
      Domains.totalSupply = Domains.totalSupply + (1 as UInt64)
      self.subdomainCount = self.subdomainCount + (1 as UInt64)
      
      emit SubDomainCreated(id: self.subdomainCount, hash: nameHash)

      destroy oldSubdomain
    }

    pub fun removeSubDomain(nameHash: String){
      
      Domains.totalSupply = Domains.totalSupply - (1 as UInt64)
      self.subdomainCount = self.subdomainCount - (1 as UInt64)
      let oldToken <- self.subdomains.remove(key: nameHash) ?? panic("missing subdomain")

      emit SubDomainRemoved(id: oldToken.id, hash: nameHash)

      destroy oldToken

    }

    pub fun depositVault(from: @FungibleToken.Vault) {
      let typeKey = from.getType().identifier
      let amount = from.balance
      let owner = from.owner?.address
      if self.vaults[typeKey] == nil {
        self.vaults[typeKey] <-! from
      } else {
        let vaultRef = &self.vaults[typeKey] as! auth &FungibleToken.Vault
        vaultRef.deposit(from: <- from)
      }
      emit DomainVaultDeposited(vaultType: typeKey, amount: amount, to: owner )

    }

    pub fun withdrawVault(key: String, amount: UFix64): @FungibleToken.Vault {
      pre {
        self.vaults[key] != nil : "Vault not exsit..."
      }
      let vaultRef = &self.vaults[key] as! auth &FungibleToken.Vault
      let balance = vaultRef.balance
      var withdrawAmount = amount
      if amount == 0.0 {
        withdrawAmount = balance
      }
      emit DomainVaultWithdrawn(vaultType: key, amount: balance, from: self.getDomainName())
      return <- vaultRef.withdraw(amount: withdrawAmount)
    }


    destroy() {
      destroy self.subdomains
      destroy self.vaults
    }
  }

  pub resource interface CollectionPublic {

    pub fun deposit(token: @NonFungibleToken.NFT)

    pub fun getIDs(): [UInt64]

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT

    pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic}
  }

  // return the content for this NFT
  pub resource interface CollectionPrivate {

    access(account) fun mintDomain(id: UInt64, name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>)

    pub fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT

  }


  // NFT collection 
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

    pub fun deposit(token: @NonFungibleToken.NFT) {

      let token <- token as! @Domains.NFT
      let id: UInt64 = token.id
      let nameHash = token.nameHash

      // update the owner record for new domain owner
      token.setRecord(address: self.owner?.address!)
      
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
    
    // Borrow domain for public use
    pub fun borrowDomain(id: UInt64): &{Domains.DomainPublic} {
      let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      return ref as! &Domains.NFT
    }

    // Borrow domain for domain owner 
    pub fun borrowDomainPrivate(_ id: UInt64): &Domains.NFT {
      pre {
        self.ownedNFTs[id] != nil: "domain doesn't exist"
      }
      let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      return ref as! &Domains.NFT
    }

    access(account) fun mintDomain(id: UInt64, name: String, nameHash: String, parentName: String, expiredAt: UFix64, receiver: Capability<&{NonFungibleToken.Receiver}>){
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

      // set records for new domain
      nft.setRecord(address: receiver.address)
      Domains.totalSupply = Domains.totalSupply + 1 as UInt64
      receiver.borrow()!.deposit(token: <- nft)

      emit DomainMinted(id: id, name: name, nameHash: nameHash, parentName: parentName, expiredAt: expiredAt, receiver: receiver.address)

    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {

    let collection <- create Collection()
    return <- collection
  }

  // Get domain's expired time in timestamp 
  pub fun domainExpiredTime(_ nameHash: String) : UFix64? {

    let expiredTime = Domains.expired[nameHash]
    return expiredTime
  }

  // Get domain's expired statu
  pub fun isExpired(_ nameHash: String): Bool {
    let currentTimestamp = getCurrentBlock().timestamp
    let expiredTime =  Domains.expired[nameHash]
    if expiredTime != nil {
      // make one day buffer 
      return (currentTimestamp - 86400.00) > expiredTime!
    } 
    return false
  }

  // Get domain's owner address
  pub fun domainRecord(_ nameHash: String) : Address? {
    let address = Domains.records[nameHash]
    return address
  }

  // update records in case domain name not match hash
  access(account) fun updateRecords(nameHash: String, address: Address?) {
    if Domains.records[nameHash] == nil {
      panic("name hash not exist ...")
    }
    Domains.records[nameHash] = address
    Domains.expired[nameHash] = nil
  }

	init() {

    self.totalSupply = 0
    self.CollectionPublicPath =/public/fnsDomainCollection
    self.CollectionStoragePath =/storage/fnsDomainCollection
    self.CollectionPrivatePath =/private/fnsDomainCollection
    
    self.records = {}
    self.expired = {}
    let account = self.account
    account.save(<- Domains.createEmptyCollection(), to: Domains.CollectionStoragePath)
    account.link<&Domains.Collection>(Domains.CollectionPublicPath, target: Domains.CollectionStoragePath)
    emit ContractInitialized()
	}
}

 