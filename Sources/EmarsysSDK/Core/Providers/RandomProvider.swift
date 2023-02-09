import Foundation

@SdkActor
class RandomProvider: DoubleProvider {
    let range: ClosedRange<Double>

    init(in range: ClosedRange<Double>) {
        self.range = range
    }

    func provide() -> Double {
        Double.random(in: range)
    }
}
