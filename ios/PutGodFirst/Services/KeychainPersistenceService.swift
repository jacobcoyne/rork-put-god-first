import Foundation
import Security

final class KeychainPersistenceService {
    static let shared = KeychainPersistenceService()
    private let service = "com.rork.god-first-app.persistence"

    private init() {}

    func save(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func saveInt(_ value: Int, forKey key: String) {
        let data = withUnsafeBytes(of: value) { Data($0) }
        save(data, forKey: key)
    }

    func loadInt(forKey key: String) -> Int? {
        guard let data = load(forKey: key), data.count == MemoryLayout<Int>.size else { return nil }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }

    func saveBool(_ value: Bool, forKey key: String) {
        saveInt(value ? 1 : 0, forKey: key)
    }

    func loadBool(forKey key: String) -> Bool? {
        guard let val = loadInt(forKey: key) else { return nil }
        return val == 1
    }

    func saveString(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(data, forKey: key)
    }

    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func saveDate(_ value: Date, forKey key: String) {
        let interval = value.timeIntervalSince1970
        let data = withUnsafeBytes(of: interval) { Data($0) }
        save(data, forKey: key)
    }

    func loadDate(forKey key: String) -> Date? {
        guard let data = load(forKey: key), data.count == MemoryLayout<Double>.size else { return nil }
        let interval = data.withUnsafeBytes { $0.load(as: Double.self) }
        guard interval > 0 else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    func saveCodable<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        save(data, forKey: key)
    }

    func loadCodable<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = load(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
