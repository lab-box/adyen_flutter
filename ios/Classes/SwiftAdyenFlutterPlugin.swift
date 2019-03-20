import Flutter
import UIKit
import Adyen

public class SwiftAdyenFlutterPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "adyen_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAdyenFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func encryptedToken(_ arguments: NSDictionary,completion: @escaping Completion<String>) {
        let publicKeyToken = arguments["publicKeyToken"] as? String
        let cardNumber = arguments["cardNumber"] as? String
        let cardSecurityCode = arguments["cardSecurityCode"] as? String
        let cardExpiryMonth = arguments["cardExpiryMonth"] as? String
        let cardExpiryYear = arguments["cardExpiryYear"] as? String
        let card = CardEncryptor.Card.init(number: cardNumber, securityCode: cardSecurityCode, expiryMonth: cardExpiryMonth, expiryYear: cardExpiryYear)
        let environmentString = arguments["environment"] as? String
        let env = environmentString=="TEST" ? CardEncryptor.Environment.test : CardEncryptor.Environment.live
        let holderName = arguments["holderName"] as? String
        let generationDateString = arguments["generationDate"] as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let generationDate = dateFormatter.date(from: generationDateString!)
        
        
        CardEncryptor.encryptedToken(for: card, holderName: holderName, publicKeyToken: publicKeyToken!, generationDate: generationDate!, environment: env) { (resultToken) in
            switch resultToken {
            case .success(let token):
                completion(token)
            case .failure(let error):
                completion("error")
            }
        }
    }
    
    private func encryptedCard(_ arguments: NSDictionary,completion: @escaping Completion<NSDictionary>) {
        let publicKeyToken = arguments["publicKeyToken"] as? String
        let cardNumber = arguments["cardNumber"] as? String
        let cardSecurityCode = arguments["cardSecurityCode"] as? String
        let cardExpiryMonth = arguments["cardExpiryMonth"] as? String
        let cardExpiryYear = arguments["cardExpiryYear"] as? String
        let card = CardEncryptor.Card.init(number: cardNumber, securityCode: cardSecurityCode, expiryMonth: cardExpiryMonth, expiryYear: cardExpiryYear)
        let environmentString = arguments["environment"] as? String
        let environment = environmentString=="TEST" ? CardEncryptor.Environment.test : CardEncryptor.Environment.live
        let generationDateString = arguments["generationDate"] as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        let generationDate = dateFormatter.date(from: generationDateString!)
        
        CardEncryptor.encryptedCard(for: card
            , publicKeyToken: publicKeyToken!
            , generationDate: generationDate!
        , environment: environment) { (resultEncryptedCard) in
            switch resultEncryptedCard {
            case .success(let encryptedCard):
                let dict = [
                    "encryptedNumber":encryptedCard.number,
                    "encryptedSecurityCode":encryptedCard.securityCode,
                    "encryptedExpiryMonth":encryptedCard.expiryMonth,
                    "encryptedExpiryYear":encryptedCard.expiryYear
                ]
                completion(dict as NSDictionary)
            case .failure(let error):
                completion([:] as NSDictionary)
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch (call.method) {
        case "encryptedToken":
            encryptedToken(arguments!) { (encryptedToken) in
                result(encryptedToken)
            }
        case "encryptedCard":
            encryptedCard(arguments!) { (encryptedCard) in
                result(encryptedCard)
            }
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
}
