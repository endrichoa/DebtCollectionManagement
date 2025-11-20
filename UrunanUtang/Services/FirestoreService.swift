import Foundation
import FirebaseFirestore

final class FirestoreService {
    private var db: Firestore {
        Firestore.firestore()
    }

    // MARK: - Upload single person to Firestore
    func uploadPerson(_ person: Person) async throws {
        let data: [String: Any] = [
            "id": person.id.uuidString,
            "name": person.name,
            "isActive": person.isActive,
            "emoji": person.emoji as Any,
            "colorHex": person.colorHex as Any
        ]
        try await setData(collection: "people", document: person.id.uuidString, data: data)
    }

    // MARK: - Upload single expense item to Firestore
    func uploadExpenseItem(_ item: ExpenseItem) async throws {
        let data: [String: Any] = [
            "id": item.id.uuidString,
            "title": item.title,
            "price": NSDecimalNumber(decimal: item.price).doubleValue,
            "date": Timestamp(date: item.date),
            "notes": item.notes,
            "mode": item.mode.rawValue,
            "buyerID": item.buyer?.id.uuidString as Any,
            "participantIDs": item.participants.map { $0.id.uuidString }
        ]
        try await setData(collection: "items", document: item.id.uuidString, data: data)
    }

    // MARK: - Delete single expense item from Firestore
    func deleteExpenseItem(_ item: ExpenseItem) async throws {
        try await deleteDocument(collection: "items", document: item.id.uuidString)
    }

    // MARK: - Delete single person from Firestore
    func deletePerson(_ person: Person) async throws {
        try await deleteDocument(collection: "people", document: person.id.uuidString)
    }

    // MARK: - Helpers
    private func setData(collection: String, document: String, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            db.collection(collection).document(document).setData(data, merge: true) { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }
    }

    private func deleteDocument(collection: String, document: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            db.collection(collection).document(document).delete { error in
                if let error { cont.resume(throwing: error) } else { cont.resume() }
            }
        }
    }
}

