//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Кухарев on 26.03.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case totalAccuracy, bestGame, gamesCount, correctAnswersCount, totalAmount
    }

    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue) else {
                return GameRecord.init(correct: 0, total: 0, date: Date())
            }
            do {
                let record = try JSONDecoder().decode(GameRecord.self, from: data)
                return record
            } catch {
                print("\(String(String(describing: error)))")
                return GameRecord.init(correct: 0, total: 0, date: Date())
            }
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private var correctAnswersCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.correctAnswersCount.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.correctAnswersCount.rawValue)
        }
    }
    
    private var totalAmount: Int {
        get {
            return userDefaults.integer(forKey: Keys.totalAmount.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalAmount.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswersCount += count
        totalAmount += amount
        totalAccuracy = Double(correctAnswersCount)/Double(totalAmount)
        gamesCount += 1
        if count > bestGame.correct {
            let newBestGame = GameRecord(correct: count, total: amount, date: Date())
            bestGame = newBestGame
        }
    }
}
