import Foundation


/// URI Safe base64 encode
func base64encode(input:NSData) -> String {
  let data = input.base64EncodedData(NSDataBase64EncodingOptions(rawValue: 0))
  let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
  return string
    .replacingOccurrences(of: "+", with: "-", options: NSStringCompareOptions(rawValue: 0), range: nil)
    .replacingOccurrences(of: "/", with: "_", options: NSStringCompareOptions(rawValue: 0), range: nil)
    .replacingOccurrences(of: "=", with: "", options: NSStringCompareOptions(rawValue: 0), range: nil)
}

/// URI Safe base64 decode
func base64decode(input:String) -> NSData? {
  let rem = input.characters.count % 4

  var ending = ""
  if rem > 0 {
    let amount = 4 - rem
    ending = String(repeating: Character("="), count: amount)
  }

    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
    .replacingOccurrences(of: "_", with: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending

  return NSData(base64Encoded: base64, options: NSDataBase64DecodingOptions(rawValue: 0))
}
