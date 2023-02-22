import UIKit
import CryptoSwift
import Starscream

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


//print(value)
