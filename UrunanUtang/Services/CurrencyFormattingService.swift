import Foundation

final class CurrencyFormattingService {
    let locale: Locale
    private let formatter: NumberFormatter

    init(locale: Locale) {
        self.locale = locale
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .currency
        f.currencyCode = "IDR"
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        self.formatter = f
    }

    func string(from value: Decimal) -> String {
        let ns = NSDecimalNumber(decimal: value)
        return formatter.string(from: ns) ?? "Rp\(ns.intValue)"
    }

    func decimal(from string: String) -> Decimal? {
        let digits = string.filter { $0.isNumber }
        guard let int = Int(digits) else { return nil }
        return Decimal(int)
    }
}

