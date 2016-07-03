import Foundation
import C7
import CryptoEssentials


/// URI Safe base64 encode
func base64encode(input: Data) -> String {
    let string = Base64.encode(input.bytes)
    
    return string
        .replacingOccurrences(of: "+", with: "-", options: NSStringCompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "/", with: "_", options: NSStringCompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "=", with: "", options: NSStringCompareOptions(rawValue: 0), range: nil)
}

/// URI Safe base64 decode
func base64decode(input:String) -> Data? {    
    let rem = input.characters.count % 4
    
    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: Character("="), count: amount)
    }
    
    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "_", with: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending

    guard let bytes = try? Base64.decode(base64) else {
        return nil
    }
    
    return Data(bytes)
}
