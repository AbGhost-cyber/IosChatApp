import UIKit
import CryptoSwift
//class Security {
//    private var userCredentials: Dictionary<String, BigUInteger> = [:]
//
//    // formula for RSA encryption = PLAINTEXT^PUBLIC KEY MOD PRODUCT
//    // the symmetric keys will be unique for each group created by admin
//    // the symmetric key will also be regenerated when a user joins or leaves the group
//    func exchangeGroupkeyAsymmetric(groupId: String, userPublicKey: [UInt8])-> [UInt8]? {
//        do {
//            if let groupSymmetricKey = try RSA(keySize: 40).d {
//                let adminImportsOfUserPublicKey = try RSA(rawRepresentation: Data(userPublicKey))
//                let encryptedResult = try adminImportsOfUserPublicKey.encrypt(String(groupSymmetricKey).bytes)
//                return encryptedResult
//            }
//            return nil
//        } catch {
//            print("couldn't generate symmetry key: \(error.localizedDescription)")
//        }
//        return nil
//    }
//
//    func decryptAdminSymmetryForUser(encryptedGroupKey: [UInt8], groupId: String) -> BigUInteger? {
//        if encryptedGroupKey.isEmpty { return nil }
//        do {
//            let userSecretKey = try RSA(keySize: 1024)
//            let originalDecryptedData = try userSecretKey.decrypt(encryptedGroupKey)
//           if let stringValue = String(data: Data(originalDecryptedData), encoding: .utf8) {
//               let decryptedValue = BigUInteger(stringValue)
//                userCredentials[groupId] = decryptedValue
//               return decryptedValue
//           }
//            return nil
//        } catch {
//
//        }
//        return nil
//    }
//}

//let userSecretKey = try RSA(keySize: 1024)
//let ss = try userSecretKey.encrypt("1234".bytes)
//let bytess = try userSecretKey.externalRepresentation().bytes.toBase64()
//let mm = try RSA(rawRepresentation: Data(base64Encoded: bytess, options: .init(rawValue: 0))!)
//let dd = try mm.decrypt(ss)
//let result = String(data: Data(dd), encoding: .utf8)
//print(result ?? "none")
//let groupSymmetricKey = "keykeykeykeykeyk"
//let iv = AES.randomIV(AES.blockSize)
//let aes = try AES(key: groupSymmetricKey.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
//let cipheredMessage = try aes.encrypt("hello".bytes)
//let str = Data(cipheredMessage)
//print()
//
//let decrypt = try aes.decrypt(str.bytes)
//print(String(data: Data(decrypt), encoding: .utf8))
//let sec = Security()
//let data  = try RSA(keySize: 1024).publicKeyExternalRepresentation().bytes
//print(data)
//let d = Data(data)
//print("for: \(d.bytes)")
////print(sec.getAdminSymmetricKey(groupId: "12", userPublicKey: data))

//let ss = sec.decryptAdminSymmetryForUser(groupId: "12")
//sec.getOrSetAdminSymmetryKey(groupId: "", publicKey: 0)
//enum MError: Error {
//    case invalidURL
//}
//class ChatServiceImpl: ChatService, WebSocketDelegate {
//    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
//        switch event {
//        case .connected(let headers):
//            isConnected = true
//            print("websocket is connected: \(headers)")
//        case .disconnected(let reason, let code):
//            isConnected = false
//            print("websocket is disconnected: \(reason) with code: \(code)")
//        case .text(let string):
//            print("Received text: \(string)")
//        case .binary(let data):
//            print("Received data: \(data.count)")
//        case .ping(_):
//            break
//        case .pong(_):
//            break
//        case .viabilityChanged(_):
//            break
//        case .reconnectSuggested(_):
//            break
//        case .cancelled:
//            isConnected = false
//        case .error(let error):
//            isConnected = false
//            //handleError(error)
//        }
//    }
//    
//    private var socket: WebSocket?
//    private var isConnected = false
//    
//    func connectToServer(token: String) async throws {
////        guard let url = URL(string: EndPoints.InitConnect.url) else {
////            throw MError.invalidURL
////        }
//        var request = URLRequest(url: URL(string: EndPoints.InitConnect.url)!)
//        let authValue = "Bearer \(token)"
//        request.timeoutInterval = 5
//        request.setValue(authValue, forHTTPHeaderField: "Authorization")
//        socket = WebSocket(request: request)
//        socket?.delegate = self
//        socket?.connect()
////        socket?.onEvent = { event in
////            self.didReceive(event: event, client: self.socket!)
////        }
//    }
//    
//    
////    func sendPing(){
////        webSocket?.sendPing(pongReceiveHandler: { error in
////            self.isConnected = error == nil
////            print("error \(error?.localizedDescription)")
////            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
////                print("sent")
////                self.sendPing()
////            }
////        })
////    }
//}
//Task {
//    let service = ChatServiceImpl()
//    do {
//        let value = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJ1c2VycyIsImlzcyI6Imh0dHA6Ly8wLjAuMC4wOjgwODEiLCJleHAiOjE3MDgyNTM3MjYsInVzZXJJZCI6IjYzZjA0ZjJhY2Q0YjVjNWZhNGI2NDhiYSJ9.S5CUpGxjHiiyX3XcviDk-NlnH1YQhz1-v9c-Y67BPEY"
//        try await service.connectToServer(token: value)
//    } catch {
//        print("error occurred: \(error.localizedDescription)")
//    }
//}

func encryptMessage(_ text: String, for groupId: String) throws -> [UInt8] {
    print("trying encryption...")
    let groupSymmetricKey = String(UUID().uuidString.dropLast(4))
    print("fetched group key: \(groupSymmetricKey)")
    let iv = AES.randomIV(AES.blockSize)
    let aes = try AES(key: groupSymmetricKey.bytes, blockMode: CBC(iv: iv), padding: .zeroPadding)
    print("encrypting...")
    let encryptBytes = try aes.encrypt(Array(text.utf8))

    return encryptBytes
//    if let cipherStr = String(data: Data(encrypt), encoding: .utf8) {
//        return cipherStr
//    }
//    throw SecurityException.msgEncryptError
}

func decrypt (bytes: [UInt8]) throws -> String {
    let groupSymmetricKey = "CBE7736D-BB01-4F3F-BF71-1A31677F"
    let iv = AES.randomIV(AES.blockSize)
    let aes = try AES(key: groupSymmetricKey.bytes, blockMode: CBC(iv: iv), padding: .zeroPadding)
    print("decrypting")
    let decrypt = try aes.decrypt(bytes)
//    let decrypted = String(bytes: aesD!, encoding: .utf8)
//     print("AES decrypted: \(decrypted)")
    if let decipherStr = String(bytes: decrypt, encoding: .utf8) {
        return decipherStr
    }
    throw SecurityException.msgDecryptError
}
//print(value)
//let en = try encryptMessage("hi, there", for: "")
//print(en)
////print(Data(base64Encoded: en, options: .init(rawValue: 0))?.bytes)
//print(try decrypt(bytes: en))
//print(String(UUID().uuidString.dropLast(4)))
//print(String(UUID().uuidString.dropLast(4)))
//Data(self.utf8).base64EncodedString()

//let ss = String(UUID().uuidString.dropLast(4)).toBase64()
//let real = ss.fromBase64()!
//print("real: \(real)")
//if let aes = try? AES(key: real, iv: "abdefdsrfjdirogf"),
//    let aesE = try? aes.encrypt(Array("testString".utf8)) {
//    print("AES encrypted: \(aesE.toHexString())")
//
//    let aesD = try? aes.decrypt(Array(hex: aesE.toHexString()))
//    let decrypted = String(bytes: aesD!, encoding: .utf8)
//    print("AES decrypted: \(decrypted ?? "ok")")
//}else{
//    print("error")
//}
let mins = 55 + 52 + 197 + 92 + 30 + 47 + 120 + 132 + 52 + 45
print(mins)
