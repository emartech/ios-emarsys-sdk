import Foundation

@SdkActor
protocol Crypto {

    func verify(content: Data, signature: Data) -> Bool

}