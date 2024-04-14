//
//  Cache+Extensions.swift
//
//  Created by Сергей Кухарев on 02.04.2024.
//

import Foundation

/*
  Расширение для управления кэшированием структур данных (в ОЗУ и на диске)
 
  Использование:

  1. Структура должна соответствовать протоколам  Codable
 struct TestStruct: Codable {
     var id = UUID()
     let name: String
     
     init (name: String) {
         self.name = name
     }
 }
 
 2. Инициализация и запись в кэш
 let element = TestStruct(name: "test element")
 let cache = Cache<TestStruct.ID, TestStruct>()
 cache[element.id] = element
 
 3. Запись кэша на диск
 try? cache.saveToDisk(withName: "myCache")
 
 4. Загрузка кэша с диска
 let cache = Cache<TestStruct.ID, TestStruct>()
 try cache.loadFromDisk(withName: "myCache")
 // Обработка ошибок
 enum FileErrors: Error {
     case cacheFileNotFound     //Файл кэша не найден на диске
 }

 
 5. Извлечение из кэша
 if let cachedElement = cache[UUID(uuidString: "BEC9F2A2-FA83-43D3-91CF-74D1751581EC")!] {
     print("Элемент \(cachedElement) загружен из кэша")
 }
 
 */

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            return key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
    
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }

    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

/// Класс, реализующий функции записи и чтения данных из стандартного кэша
final class Cache<Key: Hashable, Value> {
    private var wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    
    /// Инициализатор экземпляра класса
    /// - Parameters:
    ///   - dateProvider: Дата, используемая для проверки устаревания записи кэша. По умолчанию, текущая дата
    ///   - entryLifetime: Срок жизни в секундах записи в кэше. По умолчанию, 24 часа
    ///   - maximumEntryCount: Максимальное количество хранимых элементов в кэше до перезаписи
    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 24 * 60 * 60, maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    /// Добавляет элемент в кэш для заданного ключа
    /// - Parameters:
    ///   - value: Добавляемый в кэш элемент - экземпляр структуры или класса
    ///   - key: Идентификатор элемента в кэше - любой хэшируемый тип данных
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    /// Возвращает элемент из кэша по заданному ключу
    /// - Parameter key: Идентификатор элемента в кэше - любой хэшируемый тип данных
    /// - Returns: Элемент из кэша
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    /// Удаляет элемент из кэша по заданному ключу
    /// - Parameter key: Идентификатор элемента в кэше - любой хэшируемый тип данных
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache where Key: Codable, Value: Codable {
    enum FileErrors: Error {
        case cacheFileNotFound
    }
    
    /// Сохраняет кэш в системную папку приложения Library/Caches
    /// - Parameters:
    ///   - name: Имя файла для хранения кэша
    ///   - fileManager: Интерфейс для работы с файловой системой
    func saveToDisk(withName name: String, using fileManager: FileManager = .default) throws {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
    
    /// Статический метод загружает кэш из файла и возвращает экземпляр класса.  
    /// - Parameters:
    ///   - name: Имя файла с хранимым кэшем
    ///   - fileManager: Интерфейс для работы с файловой системой
    static func loadFromDisk(withName name: String, using fileManager: FileManager = .default) throws -> Cache {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            throw FileErrors.cacheFileNotFound
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Cache.self, from: data)
    }
}
