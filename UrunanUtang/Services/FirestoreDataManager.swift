import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreDataManager: ObservableObject {
    @Published var people: [Person] = []
    @Published var items: [ExpenseItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var db: Firestore {
        Firestore.firestore()
    }
    private var peopleListener: ListenerRegistration?
    private var itemsListener: ListenerRegistration?
    private var peopleByID: [UUID: Person] = [:]

    // MARK: - Initialize and Start Listening
    func startListening() {
        listenToPeople()
        listenToItems()
    }

    func stopListening() {
        peopleListener?.remove()
        itemsListener?.remove()
    }

    // MARK: - Real-time Listeners
    private func listenToPeople() {
        peopleListener = db.collection("people").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    self.error = "Failed to listen to people: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var newPeople: [Person] = []
                var newPeopleByID: [UUID: Person] = [:]

                for doc in documents {
                    let data = doc.data()
                    guard let idStr = data["id"] as? String,
                          let id = UUID(uuidString: idStr) else { continue }

                    let name = (data["name"] as? String) ?? ""
                    let isActive = (data["isActive"] as? Bool) ?? true
                    let emoji = data["emoji"] as? String
                    let colorHex = data["colorHex"] as? String

                    let person = Person(id: id, name: name, isActive: isActive, emoji: emoji, colorHex: colorHex)
                    newPeople.append(person)
                    newPeopleByID[id] = person
                }

                self.people = newPeople
                self.peopleByID = newPeopleByID
            }
        }
    }

    private func listenToItems() {
        itemsListener = db.collection("items").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    self.error = "Failed to listen to items: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var newItems: [ExpenseItem] = []

                for doc in documents {
                    let data = doc.data()
                    guard let idStr = data["id"] as? String,
                          let id = UUID(uuidString: idStr) else { continue }

                    let title = (data["title"] as? String) ?? ""
                    let price = Decimal((data["price"] as? Double) ?? 0)
                    let date: Date
                    if let ts = data["date"] as? Timestamp {
                        date = ts.dateValue()
                    } else {
                        date = .now
                    }
                    let notes = (data["notes"] as? String) ?? ""
                    let mode = ShareMode(rawValue: (data["mode"] as? String) ?? "") ?? .urunan
                    let buyerID = (data["buyerID"] as? String).flatMap { UUID(uuidString: $0) }
                    let participantIDs = (data["participantIDs"] as? [String] ?? []).compactMap { UUID(uuidString: $0) }

                    let buyer = buyerID.flatMap { self.peopleByID[$0] }
                    let participants: [Person] = participantIDs.compactMap { self.peopleByID[$0] }

                    let item = ExpenseItem(id: id, title: title, price: price, buyer: buyer, participants: participants, mode: mode, date: date, notes: notes)
                    newItems.append(item)
                }

                self.items = newItems.sorted(by: { $0.date > $1.date })
            }
        }
    }

    // MARK: - Person CRUD Operations
    func addPerson(name: String) async throws -> Person {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw FirestoreError.invalidData("Name cannot be empty")
        }

        let person = Person(name: name)
        let data: [String: Any] = [
            "id": person.id.uuidString,
            "name": person.name,
            "isActive": person.isActive,
            "emoji": person.emoji as Any,
            "colorHex": person.colorHex as Any
        ]

        try await db.collection("people").document(person.id.uuidString).setData(data)
        return person
    }

    func updatePerson(_ person: Person) async throws {
        let data: [String: Any] = [
            "id": person.id.uuidString,
            "name": person.name,
            "isActive": person.isActive,
            "emoji": person.emoji as Any,
            "colorHex": person.colorHex as Any
        ]

        try await db.collection("people").document(person.id.uuidString).setData(data, merge: true)
    }

    func deletePerson(_ person: Person) async throws {
        try await db.collection("people").document(person.id.uuidString).delete()
    }

    // MARK: - Expense Item CRUD Operations
    func addExpenseItem(title: String, price: Decimal, buyer: Person?, participants: [Person], mode: ShareMode, date: Date, notes: String) async throws -> ExpenseItem {
        let item = ExpenseItem(title: title, price: price, buyer: buyer, participants: participants, mode: mode, date: date, notes: notes)
        try await saveExpenseItem(item)
        return item
    }

    func updateExpenseItem(_ item: ExpenseItem) async throws {
        try await saveExpenseItem(item)
    }

    func deleteExpenseItem(_ item: ExpenseItem) async throws {
        try await db.collection("items").document(item.id.uuidString).delete()
    }

    func duplicateExpenseItem(_ item: ExpenseItem) async throws -> ExpenseItem {
        let copy = ExpenseItem(title: item.title, price: item.price, buyer: item.buyer, participants: item.participants, mode: item.mode, date: item.date, notes: item.notes)
        try await saveExpenseItem(copy)
        return copy
    }

    private func saveExpenseItem(_ item: ExpenseItem) async throws {
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

        try await db.collection("items").document(item.id.uuidString).setData(data)
    }
}

enum FirestoreError: LocalizedError {
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return message
        }
    }
}
