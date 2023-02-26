//
//  Security.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/15.
//

import Foundation
import CryptoSwift


enum SecurityException: Error {
    case adminKeyDecryptError
    case userPrivateKeyDecryptError
    case userGroupKeyDecryptError
    case adminKeyNotFound
    case userPrivateKeyNotFound
    case userPkeyEmpty
    case adminRSAEncryptEmpty
}
protocol Security {
    func fetchKeyByGroupId(_ id: String) throws -> String
    func updateKeyByGroupId(_ id: String) throws
    func generateKeyForGroup(with id: String)
    func generateUserRSAPrivateKeyForGroup(with id: String) throws
    func fetchUserRSAPrivateKeyForGroup(with id: String) throws -> Data
    func exchangeGroupkeyAsymmetric(with groupId: String, and userPublicKey: [UInt8]) throws -> [UInt8]
    func decryptAdminSymmetryForUser(with encryptedGroupKey: [UInt8], and groupId: String) throws -> String
}

class SecurityImpl: Security {
    
    private var userDefaults: UserDefaults = .standard
    private var secKey = "user_credentials"
    private var rsaKeys = "user_rsa"
    //holds user's group enc keys
    private var userCredentials: Dictionary<String, String> = [:]
    // holds user's request dec keys
    private var userRSAPrivateKeys: Dictionary<String, String> = [:]
    
    init() {
        loadData()
    }
    
    private func loadData() {
        let dict = userDefaults.dictionary(forKey: secKey) as? [String: String] ?? [:]
        self.userCredentials = dict
        let rsaPrivateKeys = userDefaults.dictionary(forKey: rsaKeys) as? [String: String] ?? [:]
        self.userRSAPrivateKeys = rsaPrivateKeys
    }
    
    //admin
    func generateKeyForGroup(with id: String) {
        if groupCredExists(id: id) {
            return
        }
        let encryptedGroupKey = UUID().uuidString.toBase64()
        userCredentials[id] = encryptedGroupKey
        // save changes to user defaults
        userDefaults.set(userCredentials, forKey: secKey)
    }
    
   private func groupCredExists(id: String) -> Bool {
        return userCredentials.keys.contains(where: {$0 == id})
    }
    
    private func rsaKeyForGroup(id: String) -> Bool {
        return userRSAPrivateKeys.keys.contains(where: {$0 == id})
    }
    
    //only the admin can call this function
    func fetchKeyByGroupId(_ id: String) throws -> String {
        //check if group doesn't exist
        if !groupCredExists(id: id) {
            throw SecurityException.adminKeyNotFound
        }
        let decryptedKey = try getDecryptedKey(for: userCredentials[id]!)
        return decryptedKey
    }
    
    
    private func getDecryptedKey(for key: String) throws -> String {
        guard let decryptedKey = key.fromBase64() else {
            throw SecurityException.adminKeyDecryptError
        }
        return decryptedKey
    }
    
    func updateKeyByGroupId(_ id: String) throws {
        //TODO: make update possible
    }
    
    
    // the symmetric keys will be unique for each group created by admin
    // the symmetric key will also be regenerated when a user joins or leaves the group
    //admin attempts to exchange his group key with the request user via asymmetric encryption
    //for this to be possible, the admin needs the user's public key RSA
    func exchangeGroupkeyAsymmetric(with groupId: String, and userPublicKey: [UInt8]) throws -> [UInt8] {
        if userPublicKey.isEmpty {
            throw SecurityException.userPkeyEmpty
        }
        let adminGroupKey = try fetchKeyByGroupId(groupId)
        let adminImportsOfUserPublicKey = try RSA(rawRepresentation: Data(userPublicKey))
        let encryptedResult = try adminImportsOfUserPublicKey.encrypt(adminGroupKey.bytes)
        return encryptedResult
    }
    
    func generateUserRSAPrivateKeyForGroup(with id: String) throws {
        let userSecretKey = try RSA(keySize: 1024)
        if rsaKeyForGroup(id: id) {
            return
        }
        let encryptedUserSecretKey = try userSecretKey.externalRepresentation().bytes.toBase64()
        userRSAPrivateKeys[id] = encryptedUserSecretKey
        
        // save changes to user defaults
        userDefaults.set(userRSAPrivateKeys, forKey: rsaKeys)
    }
    
    func fetchUserRSAPrivateKeyForGroup(with id: String) throws -> Data {
        if !rsaKeyForGroup(id: id) {
            throw SecurityException.userPrivateKeyNotFound
        }
        let encryptedUserSKey = userRSAPrivateKeys[id]!
        guard let data = Data(base64Encoded: encryptedUserSKey, options: .init(rawValue: 0)) else {
            throw SecurityException.userPrivateKeyDecryptError
        }
        return data
    }
    
    // user attempts to decrypt the admin's symmetric key via his private key RSA
    func decryptAdminSymmetryForUser(with encryptedGroupKey: [UInt8], and groupId: String) throws -> String {
        if encryptedGroupKey.isEmpty {
            throw SecurityException.adminRSAEncryptEmpty
        }
        let userSecretKey = try RSA(rawRepresentation: fetchUserRSAPrivateKeyForGroup(with: groupId))
        let originalDecryptedData = try userSecretKey.decrypt(encryptedGroupKey)
        if let groupSymmetricKey = String(data: Data(originalDecryptedData), encoding: .utf8) {
            return groupSymmetricKey
        }
        throw SecurityException.userGroupKeyDecryptError
    }
}



