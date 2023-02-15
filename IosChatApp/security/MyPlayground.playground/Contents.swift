import UIKit
import CryptoSwift

class Security {
    private let userCredentials: Dictionary<String, Int> = [:]
    
    // formula for RSA encryption = PLAINTEXT^PUBLIC KEY MOD PRODUCT
    // the symmetric keys will be unique for each group created by admin
    // the symmetric key will also be regenerated when a user joins or leaves the group
    func getAdminSymmetricKey(groupId: String, userPublicKey: Data)-> [UInt8]? {
        do {
            if let groupSymmetricKey = try RSA(keySize: 40).d {
                print("key: \(groupSymmetricKey)")
                let adminImportsOfUserPublicKey = try RSA(rawRepresentation: userPublicKey)
                let encryptedResult = try adminImportsOfUserPublicKey.encrypt(String(groupSymmetricKey).bytes)
                return encryptedResult
            }
            return nil
        } catch {
            print("couldn't generate symmetry key: \(error.localizedDescription)")
        }
        return nil
    }
    
    func decryptAdminSymmetryForUser(encryptedKey: [UInt8], groupId: String) -> BigUInteger? {
        if encryptedKey.isEmpty { return nil }
        do {
            let userSecretKey = try RSA(keySize: 1024)
            let userPublicKey = try userSecretKey.publicKeyExternalRepresentation()
            
            let originalDecryptedData = try userSecretKey.decrypt(encryptedKey)
           if let stringValue = String(data: Data(originalDecryptedData), encoding: .utf8) {
                return BigUInteger(stringValue)
            }
            return nil
        } catch {
            
        }
        return nil
    }
}
let sec = Security()
//let ss = sec.decryptAdminSymmetryForUser(groupId: "12")
//sec.getOrSetAdminSymmetryKey(groupId: "", publicKey: 0)
