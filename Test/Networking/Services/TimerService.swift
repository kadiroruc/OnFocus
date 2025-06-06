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
    func fetchStatistics(for rangeType: FetchTimeRangeType, from date: Date, completion: @escaping (Result<[StatisticModel], Error>) -> Void)
    func fetchAverageDuration(for rangeType: FetchTimeRangeType,
                            from date: Date,
                            completion: @escaping (Result<Double, Error>) -> Void)
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
        let dateKey = DateFormatter.yyyyMMdd.string(from: date)
        
        let dayId = "daily_" + dateKey
        let weekId = "weekly_" + weekKey(for: date)
        let monthId = "monthly_" + monthKey(for: date)
        let yearId = "yearly_" + yearKey(for: date)
        let fiveYearsId = "fiveYears_" + fiveYearsKey(for: date)
        
        //Daily record control for second update (general daily average)
        var isNewDay: Bool = true
        
        let statInfos: [(id: String, divisor: Int?)] = [
            (dayId, nil),            // daily: sadece total tutulur
            (weekId, 7),
            (monthId, daysInMonth(for: date)),
            (yearId, 365),
            (fiveYearsId, 5 * 365)
        ]
        
        // 1. Sessions and statistics(daily, weekly, monthly...)
        for (statId, divisor) in statInfos {
            let ref = db.collection("users").document(userId)
                .collection("statistics")
                .document(statId)
            
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let snapshot = try transaction.getDocument(ref)
                    if statId == dayId {
                        isNewDay = !snapshot.exists
                    }
                    let existing = snapshot.data() ?? [:]
                    let oldTotal = existing["totalDuration"] as? Int ?? 0
                    
                    let newTotal = oldTotal + Int(session.duration)
                    var data: [String: Any] = ["totalDuration": newTotal]
                    
                    if let divisor {
                        let average = Double(newTotal) / Double(divisor)
                        data["averageDuration"] = average
                    }
                    
                    transaction.setData(data, forDocument: ref, merge: true)
                } catch let error {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
        }
        
        //2. Update general average work time of user (total work time / total days)
        let userRef = db.collection("users").document(userId)
        let dailyStatRef = db.collection("users").document(userId)
            .collection("statistics").document(dayId)
        
        try await db.runTransaction { transaction, errorPointer in
            do {
                let userSnapshot = try transaction.getDocument(userRef)
                let userData = userSnapshot.data() ?? [:]
                
                let currentTotalWork = userData["totalWorkTime"] as? Int ?? 0
                let currentDaysWorked = userData["totalDaysWorked"] as? Int ?? 0
                
                let dailySnapshot = try transaction.getDocument(dailyStatRef)
                
                let newTotal = currentTotalWork + Int(session.duration)
                
                let newDays = isNewDay ? (currentDaysWorked + 1) : currentDaysWorked
                let newAverageDaily = newDays > 0 ? Double(newTotal) / Double(newDays) : 0
                
                let updatedData: [String: Any] = [
                    "totalWorkTime": newTotal,
                    "totalDaysWorked": newDays,
                    "averageDailyWorkTime": newAverageDaily
                ]
                
                transaction.setData(updatedData, forDocument: userRef, merge: true)
                
            } catch let error {
                errorPointer?.pointee = error as NSError
            }
            return nil
        }
    }
    
    func fetchStatistics(for rangeType: FetchTimeRangeType,
                         from date: Date,
                         completion: @escaping (Result<[StatisticModel], Error>) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return
        }

        var ids: [String] = []

        switch rangeType {
        case .week:
            ids = (0..<7).map { offset in
                let targetDate = Calendar.current.date(byAdding: .day, value: -offset, to: date)!
                return "daily_" + DateFormatter.yyyyMMdd.string(from: targetDate)
            }

        case .month:
            ids = (0..<4).map { offset in
                let targetDate = Calendar.current.date(byAdding: .weekOfYear, value: -offset, to: date)!
                return "weekly_" + weekKey(for: targetDate)
            }

        case .year:
            ids = (0..<12).map { offset in
                let targetDate = Calendar.current.date(byAdding: .month, value: -offset, to: date)!
                return "monthly_" + monthKey(for: targetDate)
            }

        case .fiveYears:
            ids = (0..<5).map { offset in
                let targetDate = Calendar.current.date(byAdding: .year, value: -offset, to: date)!
                return "yearly_" + yearKey(for: targetDate)
            }
        }

        var results: [StatisticModel] = Array(repeating: StatisticModel(totalDuration: 0, documentName: nil), count: ids.count)
        let group = DispatchGroup()

        for (index, id) in ids.reversed().enumerated() {
            group.enter()

            let ref = Firestore.firestore()
                .collection("users")
                .document(userId)
                .collection("statistics")
                .document(id)

            ref.getDocument { snapshot, error in
                defer { group.leave() }

                if let error = error {
                    print("Document fetch error: \(error)")
                    return
                }

                let totalDuration = snapshot?.data()?["totalDuration"] as? Int ?? 0
                results[index] = StatisticModel(totalDuration: totalDuration, documentName: id)
            }
        }

        group.notify(queue: .main) {
            completion(.success(results))
        }
    }
    
    func fetchAverageDuration(for rangeType: FetchTimeRangeType,
                            from date: Date,
                            completion: @escaping (Result<Double, Error>) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return
        }

        var parentId: String

        switch rangeType {
            case .week:
                parentId = "weekly_" + weekKey(for: date)

            case .month:
                parentId = "monthly_" + monthKey(for: date)
                
            case .year:
                parentId = "yearly_" + yearKey(for: date)
                
            case .fiveYears:
                parentId = "fiveYears_" + fiveYearsKey(for: date)
        }

        let ref = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("statistics")
            .document(parentId)

        ref.getDocument { snapshot, error in
            if let error = error {
                print("Average fetch error: \(error.localizedDescription)")
                
                return
            }
            
            
            let average = snapshot?.data()?["averageDuration"] as? Double ?? 0
            completion(.success(average))
        }
            
    }


}

