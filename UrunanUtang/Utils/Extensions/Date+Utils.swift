import Foundation

extension DateFormatter {
    static let dayMonthShort: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM"
        return df
    }()
}

