//
//  TimerService.swift
//  Test
//
//  Created by Abdulkadir Oruç on 18.05.2025.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol TimerServiceProtocol {
    func saveSession(_ session: SessionModel, userId: String) async throws
    func updateAggregate(for session: SessionModel, userId: String) async throws
    func fetchStatistics(for rangeType: TimeRangeType, from date: Date, userId: String) async throws -> [StatisticModel]
}

final class TimerService {
    private let db = Firestore.firestore()
    let calendar = Calendar.current
}

extension TimerService: TimerServiceProtocol{
    
    func saveSession(_ session: SessionModel, userId: String) async throws {
        let sessionData = try Firestore.Encoder().encode(session)
        
        // 1. Session verisini kaydet
        try await db.collection("users")
            .document(userId)
            .collection("sessions")
            .addDocument(data: sessionData)
    }
    
    func updateAggregate(for session: SessionModel, userId: String) async throws {
        let date = session.timestamp
        
        let dayId = "daily_" + DateFormatter.yyyyMMdd.string(from: date)
        let weekId = "weekly_" + weekKey(for: date)
        let monthId = "monthly_" + monthKey(for: date)
        let yearId = "yearly_" + yearKey(for: date)
        let fiveYearsId = "fiveYears_" + fiveYearsKey(for: date)
        
        let statIds = [dayId, weekId, monthId, yearId, fiveYearsId]
        
        for statId in statIds {
            let ref = db.collection("users").document(userId)
                .collection("statistics")
                .document(statId)
            
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let snapshot = try transaction.getDocument(ref)
                    let existing = snapshot.data() ?? [:]
                    let oldTotal = existing["totalDuration"] as? Int ?? 0
                    let oldCount = existing["sessionCount"] as? Int ?? 0
                    
                    let newTotal = oldTotal + Int(session.duration)
                    let newCount = oldCount + 1
                    let average =  Double(newTotal) / Double(newCount)
                    
                    transaction.setData([
                        "totalDuration": newTotal,
                        "sessionCount": newCount,
                        "averageDuration": average
                    ], forDocument: ref, merge: true)
                } catch let error {
                    errorPointer?.pointee = error as NSError
                }
                
                return nil
            }
        }
    }
    
    func fetchStatistics(for rangeType: TimeRangeType, from date: Date, userId: String) async throws -> [StatisticModel] {
        var ids: [String] = []

        switch rangeType {
        case .week:
            // 7 gün: her gün için "daily_yyyyMMdd"
            ids = (0..<7).map { offset in
                let targetDate = Calendar.current.date(byAdding: .day, value: -offset, to: date)!
                return "daily_" + DateFormatter.yyyyMMdd.string(from: targetDate)
            }

        case .month:
            // 4 hafta: her hafta için "weekly_yyyy-ww"
            ids = (0..<4).map { offset in
                let targetDate = Calendar.current.date(byAdding: .weekOfYear, value: -offset, to: date)!
                return "weekly_" + weekKey(for: targetDate)
            }

        case .year:
            // 12 ay: her ay için "monthly_yyyy-MM"
            ids = (0..<12).map { offset in
                let targetDate = Calendar.current.date(byAdding: .month, value: -offset, to: date)!
                return "monthly_" + monthKey(for: targetDate)
            }

        case .fiveYears:
            // 5 yıl: her yıl için "yearly_yyyy"
            ids = (0..<5).map { offset in
                let targetDate = Calendar.current.date(byAdding: .year, value: -offset, to: date)!
                return "yearly_" + yearKey(for: targetDate)
            }
        }

        var results: [StatisticModel] = []

        for id in ids.reversed() {
            let ref = Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("statistics")
                .document(id)

            let snapshot = try await ref.getDocument()

            if let data = snapshot.data() {
                let stat = try Firestore.Decoder().decode(StatisticModel.self, from: data)
                results.append(stat)
            } else {
                results.append(StatisticModel(
                    totalDuration: 0,
                    sessionCount: 0,
                    averageDuration: 0
                ))
            }
        }

        return results
    }
}

