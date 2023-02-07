  pub fun main(): Bool {
    let message = "\u{19}Ethereum Signed Message:\n180x179b6b1cb6755e31"
    let hexPublicKey = "a34b99f22c790c4e36b2b3c2c35a36db06226e41c692fc82b8b56ac1c540c5bd5b8dec5235a0fa8722476c7709c02559e3aa73aa03918ba2d492eea75abea235"
    let hexSignature = "727b958012620a3543b500d4411a7f0fac551bc4285382501cf298e49c6621430148a590b23a1301c319f82a386c97fff9f2cc583bb441572939e83de51488b7"
    let publicKey = PublicKey(
        publicKey: hexPublicKey.decodeHex(),
        signatureAlgorithm: SignatureAlgorithm.ECDSA_secp256k1
    )
    let isValid = publicKey.verify(
        signature: hexSignature.decodeHex(),
        signedData: message.utf8,
        domainSeparationTag: "",
        hashAlgorithm: HashAlgorithm.KECCAK_256
    )
    return isValid
}