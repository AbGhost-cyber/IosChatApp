import UIKit
import CryptoSwift

class Security {
    private var userCredentials: Dictionary<String, BigUInteger> = [:]
    
    // formula for RSA encryption = PLAINTEXT^PUBLIC KEY MOD PRODUCT
    // the symmetric keys will be unique for each group created by admin
    // the symmetric key will also be regenerated when a user joins or leaves the group
    func exchangeGroupkeyAsymmetric(groupId: String, userPublicKey: [UInt8])-> [UInt8]? {
        do {
            if let groupSymmetricKey = try RSA(keySize: 40).d {
                let adminImportsOfUserPublicKey = try RSA(rawRepresentation: Data(userPublicKey))
                let encryptedResult = try adminImportsOfUserPublicKey.encrypt(String(groupSymmetricKey).bytes)
                return encryptedResult
            }
            return nil
        } catch {
            print("couldn't generate symmetry key: \(error.localizedDescription)")
        }
        return nil
    }
    
    func decryptAdminSymmetryForUser(encryptedGroupKey: [UInt8], groupId: String) -> BigUInteger? {
        if encryptedGroupKey.isEmpty { return nil }
        do {
            let userSecretKey = try RSA(keySize: 1024)
            let originalDecryptedData = try userSecretKey.decrypt(encryptedGroupKey)
           if let stringValue = String(data: Data(originalDecryptedData), encoding: .utf8) {
               let decryptedValue = BigUInteger(stringValue)
                userCredentials[groupId] = decryptedValue
               return decryptedValue
           }
            return nil
        } catch {
            
        }
        return nil
    }
}

//let authService: AuthService = AuthServiceImpl(baseURL: URL(string: "http://localhost:8081/")!)
//Task {
//    let auth = AuthRequest(username: "Abundance", password: "124")
//    do {
//        let signup = try await authService.login(with: auth)
//        print(signup)
//    } catch {
//        print("error:", error.localizedDescription)
//    }
//}
//let sec = Security()
//let data  = try RSA(keySize: 1024).publicKeyExternalRepresentation().bytes
//print(data)
//let d = Data(data)
//print("for: \(d.bytes)")
////print(sec.getAdminSymmetricKey(groupId: "12", userPublicKey: data))

//let ss = sec.decryptAdminSymmetryForUser(groupId: "12")
//sec.getOrSetAdminSymmetryKey(groupId: "", publicKey: 0)
