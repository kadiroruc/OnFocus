//
//  DIContainer.swift
//  Test
//
//  Created by Abdulkadir Oruç on 10.06.2025.
//

final class DIContainer {
    static let shared = DIContainer()
    
    private var factories: [String: () -> Any] = [:]
    
    private init() {}

    func register<T>(_ factory: @escaping () -> T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }

    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = factories[key], let instance = factory() as? T else {
            fatalError("'\(key)' için kayıtlı factory bulunamadı.")
        }
        return instance
    }
}
