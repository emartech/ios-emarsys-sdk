import Foundation

@SdkActor
class RandomProvider: DoubleProvider {
    let range: Range<Double>

    init(in range: Range<Double>) {
        self.range = range
    }

    func provide() -> Double {
        Double.random(in: range)
    }
}
