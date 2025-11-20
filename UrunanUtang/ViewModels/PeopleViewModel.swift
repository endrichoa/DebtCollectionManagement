import Foundation

@MainActor
final class PeopleViewModel: ObservableObject {
    private let dataManager: FirestoreDataManager

    init(dataManager: FirestoreDataManager) {
        self.dataManager = dataManager
    }

    func add(name: String) async throws -> Person {
        try await dataManager.addPerson(name: name)
    }

    func update(_ person: Person) async throws {
        try await dataManager.updatePerson(person)
    }

    func delete(_ person: Person) async throws {
        try await dataManager.deletePerson(person)
    }

    func rename(_ person: Person, to newName: String) async throws {
        person.name = newName
        try await dataManager.updatePerson(person)
    }

    func toggleActive(_ person: Person) async throws {
        person.isActive.toggle()
        try await dataManager.updatePerson(person)
    }
}

