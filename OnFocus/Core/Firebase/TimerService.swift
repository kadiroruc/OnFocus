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
    func saveSession(_ session: SessionModel,
                     userId: String) async throws
    
    func updateAggregate(for session: SessionModel,
                         userId: String) async throws
    
    func saveSessionAndUpdateAggregates(_ session: SessionModel,
                                        userId: String) async throws
    
    func fetchStatistics(for rangeType: FetchTimeRangeType,
                         from date: Date,
                         completion: @escaping (Result<[StatisticModel], Error>) -> Void)
    
    func fetchAverageDuration(for rangeType: FetchTimeRangeType,
                            from date: Date,
                            completion: @escaping (Result<Double, Error>) -> Void)
    
    func observeStatistics(for rangeType: FetchTimeRangeType,
                           from date: Date,
                           completion: @escaping (Result<[StatisticModel], Error>) -> Void) -> StatisticsListenerToken
    
    func observeAverageDuration(for rangeType: FetchTimeRangeType,
                                from date: Date,
                                completion: @escaping (Result<Double, Error>) -> Void) -> ListenerRegistration
    
    func fetchWeeklyStatistics(for userId: String,
                               from date: Date,
                               completion: @escaping (Result<Int, Error>) -> Void)
}

final class TimerService {
    private let db = Firestore.firestore()
    private let localStore: OfflineStoreProtocol
    let calendar = Calendar.current

    init(localStore: OfflineStoreProtocol) {
        self.localStore = localStore
    }
}

final class StatisticsListenerToken {
    private let removeHandler: () -> Void
    
    init(removeHandler: @escaping () -> Void) {
        self.removeHandler = removeHandler
    }
    
    func remove() {
        removeHandler()
    }
}

final class DummyListenerRegistration: NSObject, ListenerRegistration {
    func remove() {}
}

extension TimerService: TimerServiceProtocol{
    
    func saveSession(_ session: SessionModel, userId: String) async throws {
        updateLocalAggregates(for: session, userId: userId)

        let payload = SessionPayload(userId: userId, session: session)
        let payloadData = try? JSONEncoder().encode(payload)

        do {
            let sessionData = try Firestore.Encoder().encode(session)
            try await db.collection("users")
                .document(userId)
                .collection("sessions")
                .addDocument(data: sessionData)
            localStore.markClean(id: session.id, type: .session)
        } catch {
            if let payloadData {
                localStore.enqueue(operation: .timerSaveSession, entityType: .session, entityId: session.id, payload: payloadData)
            }
            return
        }
    }
    
    func updateAggregate(for session: SessionModel, userId: String) async throws {
        updateLocalAggregates(for: session, userId: userId)

        let payload = SessionPayload(userId: userId, session: session)
        let payloadData = try? JSONEncoder().encode(payload)

        do {
            let date = session.timestamp
            let dateKey = DateFormatter.yyyyMMdd.string(from: date)

            let dayId = "daily_" + dateKey
            let weekId = "weekly_" + weekKey(for: date)
            let monthId = "monthly_" + monthKey(for: date)
            let yearId = "yearly_" + yearKey(for: date)
            let fiveYearsId = "fiveYears_" + fiveYearsKey(for: date)

            let statInfos: [(id: String, divisor: Int?)] = [
                (dayId, nil), // daily: sadece total tutulur
                (weekId, max(1, elapsedDaysInWeek(for: date))),
                (monthId, max(1, elapsedDaysInMonth(for: date))),
                (yearId, max(1, elapsedDaysInYear(for: date))),
                (fiveYearsId, max(1, elapsedDaysInFiveYears(for: date)))
            ]

            // 1. Sessions and statistics(daily, weekly, monthly...)
            for (statId, divisor) in statInfos {
                let ref = db.collection("users").document(userId)
                    .collection("statistics")
                    .document(statId)

                try await db.runTransaction { transaction, errorPointer in
                    do {
                        let snapshot = try transaction.getDocument(ref)

                        let existing = snapshot.data() ?? [:]
                        let oldTotal = existing["totalDuration"] as? Int ?? 0
                        let newTotal = oldTotal + Int(session.duration.rounded())
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

            // 2. Update totalWorkTime field in users collection
            let userRef = db.collection("users").document(userId)

            try await db.runTransaction { transaction, errorPointer in
                do {
                    let userSnapshot = try transaction.getDocument(userRef)
                    let userData = userSnapshot.data() ?? [:]

                    let currentTotalWork = userData["totalWorkTime"] as? Int ?? 0
                    let newTotal = currentTotalWork + Int(session.duration.rounded())
                    transaction.updateData(["totalWorkTime": newTotal], forDocument: userRef)
                } catch let error {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
        } catch {
            if let payloadData {
                localStore.enqueue(operation: .timerSaveSession, entityType: .session, entityId: session.id, payload: payloadData)
            }
            return
        }
    }
    
    func saveSessionAndUpdateAggregates(_ session: SessionModel, userId: String) async throws {
        try await saveSessionAndUpdateAggregatesInternal(session, userId: userId, shouldEnqueueOnFailure: true)
    }

    func saveSessionAndUpdateAggregatesInternal(_ session: SessionModel, userId: String, shouldEnqueueOnFailure: Bool) async throws {
        updateLocalAggregates(for: session, userId: userId)

        let payload = SessionPayload(userId: userId, session: session)
        let payloadData = try? JSONEncoder().encode(payload)

        do {
            let sessionData = try Firestore.Encoder().encode(session)
            let date = session.timestamp
            let dateKey = DateFormatter.yyyyMMdd.string(from: date)

            let dayId = "daily_" + dateKey
            let weekId = "weekly_" + weekKey(for: date)
            let monthId = "monthly_" + monthKey(for: date)
            let yearId = "yearly_" + yearKey(for: date)
            let fiveYearsId = "fiveYears_" + fiveYearsKey(for: date)

            let statInfos: [(id: String, divisor: Int?)] = [
                (dayId, nil), // daily: sadece total tutulur
                (weekId, max(1, elapsedDaysInWeek(for: date))),
                (monthId, max(1, elapsedDaysInMonth(for: date))),
                (yearId, max(1, elapsedDaysInYear(for: date))),
                (fiveYearsId, max(1, elapsedDaysInFiveYears(for: date)))
            ]

            let userRef = db.collection("users").document(userId)
            let sessionRef = userRef.collection("sessions").document(session.id)

            try await db.runTransaction { transaction, errorPointer in
                do {
                    let sessionSnapshot = try transaction.getDocument(sessionRef)
                    if sessionSnapshot.exists {
                        return nil
                    }

                    let userSnapshot = try transaction.getDocument(userRef)

                    var statSnapshots: [(ref: DocumentReference, snapshot: DocumentSnapshot, divisor: Int?)] = []
                    for (statId, divisor) in statInfos {
                        let ref = userRef.collection("statistics").document(statId)
                        let snapshot = try transaction.getDocument(ref)
                        statSnapshots.append((ref: ref, snapshot: snapshot, divisor: divisor))
                    }

                    let userData = userSnapshot.data() ?? [:]
                    let currentTotalWork = userData["totalWorkTime"] as? Int ?? 0
                    let newTotalWork = currentTotalWork + Int(session.duration.rounded())

                    for item in statSnapshots {
                        let existing = item.snapshot.data() ?? [:]
                        let oldTotal = existing["totalDuration"] as? Int ?? 0
                        let newTotal = oldTotal + Int(session.duration.rounded())
                        var data: [String: Any] = ["totalDuration": newTotal]

                        if let divisor = item.divisor {
                            let average = Double(newTotal) / Double(divisor)
                            data["averageDuration"] = average
                        }

                        transaction.setData(data, forDocument: item.ref, merge: true)
                    }

                    transaction.setData(sessionData, forDocument: sessionRef, merge: false)
                    transaction.updateData(["totalWorkTime": newTotalWork], forDocument: userRef)
                } catch let error {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }

            localStore.markClean(id: session.id, type: .session)

        } catch {
            if shouldEnqueueOnFailure, let payloadData {
                localStore.enqueue(operation: .timerSaveSession, entityType: .session, entityId: session.id, payload: payloadData)
                return
            }
            throw error
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
            self.cacheStatistics(results, userId: userId)
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
                let average = self.localAverage(for: rangeType, from: date, userId: userId)
                if average == 0 {
                    print("Average fetch error: \(error.localizedDescription)")
                }
                completion(.success(average))
                return
            }

            let average = snapshot?.data()?["averageDuration"] as? Double ?? 0
            completion(.success(average))
        }
            
    }
    
    func fetchWeeklyStatistics(for userId: String, from date: Date, completion: @escaping (Result<Int, Error>) -> Void) {
        let period = "weekly_" + weekKey(for: date)
        let ref = db.collection("users")
            .document(userId)
            .collection("statistics")
            .document(period)
        
        ref.getDocument { snapshot, error in
            if let error = error {
                let cached = self.localStatistics(for: [period], userId: userId)
                if let stat = cached.first {
                    completion(.success(stat.totalDuration))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            let totalDuration = snapshot?.data()?["totalDuration"] as? Int ?? 0
            completion(.success(totalDuration))
        }
    }
    
    func observeStatistics(for rangeType: FetchTimeRangeType,
                           from date: Date,
                           completion: @escaping (Result<[StatisticModel], Error>) -> Void) -> StatisticsListenerToken {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return StatisticsListenerToken(removeHandler: {})
        }

        if !NetworkMonitor.shared.isOnline {
            let ids = statisticIds(for: rangeType, from: date)
            let cached = localStatistics(for: ids, userId: userId)
            completion(.success(cached))
            return StatisticsListenerToken(removeHandler: {})
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
        
        var listeners: [ListenerRegistration] = []
        var resultsById: [String: StatisticModel] = [:]
        let orderedIds = ids.reversed()
        
        for id in orderedIds {
            let ref = db.collection("users")
                .document(userId)
                .collection("statistics")
                .document(id)
            
            let listener = ref.addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let totalDuration = snapshot?.data()?["totalDuration"] as? Int ?? 0
                resultsById[id] = StatisticModel(totalDuration: totalDuration, documentName: id)
                
                let orderedResults = orderedIds.map { resultsById[$0] ?? StatisticModel(totalDuration: 0, documentName: $0) }
                self.cacheStatistics(orderedResults, userId: userId)
                completion(.success(orderedResults))
            }
            
            listeners.append(listener)
        }
        
        return StatisticsListenerToken {
            listeners.forEach { $0.remove() }
            listeners.removeAll()
        }
    }
    
    func observeAverageDuration(for rangeType: FetchTimeRangeType,
                                from date: Date,
                                completion: @escaping (Result<Double, Error>) -> Void) -> ListenerRegistration {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not authenticated", code: 401, userInfo: nil)))
            return DummyListenerRegistration()
        }

        if !NetworkMonitor.shared.isOnline {
            let average = localAverage(for: rangeType, from: date, userId: userId)
            completion(.success(average))
            return DummyListenerRegistration()
        }
        
        let parentId: String
        
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
        
        let ref = db.collection("users")
            .document(userId)
            .collection("statistics")
            .document(parentId)
        
        return ref.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let average = snapshot?.data()?["averageDuration"] as? Double ?? 0
            completion(.success(average))
        }
    }

    private func updateLocalAggregates(for session: SessionModel, userId: String) {
        localStore.save(entity: session, id: session.id, type: .session, markDirty: true)

        let date = session.timestamp
        let dateKey = DateFormatter.yyyyMMdd.string(from: date)
        let dayId = "daily_" + dateKey
        let weekId = "weekly_" + weekKey(for: date)
        let monthId = "monthly_" + monthKey(for: date)
        let yearId = "yearly_" + yearKey(for: date)
        let fiveYearsId = "fiveYears_" + fiveYearsKey(for: date)

        let statIds = [dayId, weekId, monthId, yearId, fiveYearsId]
        for statId in statIds {
            let cacheId = statCacheId(userId: userId, statId: statId)
            let cached: StatisticModel? = localStore.fetch(id: cacheId, type: .statistic)
            let currentTotal = cached?.totalDuration ?? 0
            let stat = StatisticModel(totalDuration: currentTotal + Int(session.duration.rounded()), documentName: statId)
            localStore.save(entity: stat, id: cacheId, type: .statistic, markDirty: true)
        }

        if var profile: ProfileModel = localStore.fetch(id: userId, type: .profile) {
            let current = profile.totalWorkTime ?? 0
            profile.totalWorkTime = current + Int(session.duration.rounded())
            localStore.save(entity: profile, id: userId, type: .profile, markDirty: true)
        }
    }

    private func statisticIds(for rangeType: FetchTimeRangeType, from date: Date) -> [String] {
        switch rangeType {
        case .week:
            return (0..<7).map { offset in
                let targetDate = Calendar.current.date(byAdding: .day, value: -offset, to: date)!
                return "daily_" + DateFormatter.yyyyMMdd.string(from: targetDate)
            }
        case .month:
            return (0..<4).map { offset in
                let targetDate = Calendar.current.date(byAdding: .weekOfYear, value: -offset, to: date)!
                return "weekly_" + weekKey(for: targetDate)
            }
        case .year:
            return (0..<12).map { offset in
                let targetDate = Calendar.current.date(byAdding: .month, value: -offset, to: date)!
                return "monthly_" + monthKey(for: targetDate)
            }
        case .fiveYears:
            return (0..<5).map { offset in
                let targetDate = Calendar.current.date(byAdding: .year, value: -offset, to: date)!
                return "yearly_" + yearKey(for: targetDate)
            }
        }
    }

    private func localStatistics(for ids: [String], userId: String) -> [StatisticModel] {
        let orderedIds = ids.reversed()
        return orderedIds.map { id in
            let cacheId = statCacheId(userId: userId, statId: id)
            let stat: StatisticModel = localStore.fetch(id: cacheId, type: .statistic) ?? StatisticModel(totalDuration: 0, documentName: id)
            return stat
        }
    }

    private func cacheStatistics(_ stats: [StatisticModel], userId: String) {
        for stat in stats {
            guard let documentName = stat.documentName else { continue }
            let cacheId = statCacheId(userId: userId, statId: documentName)
            localStore.save(entity: stat, id: cacheId, type: .statistic, markDirty: false)
        }
    }

    private func localAverage(for rangeType: FetchTimeRangeType, from date: Date, userId: String) -> Double {
        let parentId: String
        let divisor: Int

        switch rangeType {
        case .week:
            parentId = "weekly_" + weekKey(for: date)
            divisor = max(1, elapsedDaysInWeek(for: date))
        case .month:
            parentId = "monthly_" + monthKey(for: date)
            divisor = max(1, elapsedDaysInMonth(for: date))
        case .year:
            parentId = "yearly_" + yearKey(for: date)
            divisor = max(1, elapsedDaysInYear(for: date))
        case .fiveYears:
            parentId = "fiveYears_" + fiveYearsKey(for: date)
            divisor = max(1, elapsedDaysInFiveYears(for: date))
        }

        let cacheId = statCacheId(userId: userId, statId: parentId)
        let stat: StatisticModel? = localStore.fetch(id: cacheId, type: .statistic)
        let total = stat?.totalDuration ?? 0
        return divisor == 0 ? 0 : Double(total) / Double(divisor)
    }

    private func statCacheId(userId: String, statId: String) -> String {
        return "\(userId)|\(statId)"
    }

}
