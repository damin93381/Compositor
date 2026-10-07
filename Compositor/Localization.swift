import Foundation

extension String {
    nonisolated var localized: String { NSLocalizedString(self, comment: "") }
}
