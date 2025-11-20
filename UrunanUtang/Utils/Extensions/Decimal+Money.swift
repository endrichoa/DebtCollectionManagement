import Foundation

extension Decimal {
    func rounded(toIncrement increment: Decimal) -> Decimal {
        guard increment > 0 else { return self }
        let quotient = (self / increment)
        var q = NSDecimalNumber(decimal: quotient).rounding(accordingToBehavior: nil).decimalValue
        q = q * increment
        return q
    }
}

