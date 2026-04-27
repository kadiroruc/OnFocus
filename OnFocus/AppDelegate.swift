//
//  AppDelegate.swift
//  OnFocusMac
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct OnFocusMacApp: App {
    @NSApplicationDelegateAdaptor(OnFocusMacDelegate.self) private var appDelegate
    @StateObject private var timerEngine = MacTimerEngine()

    var body: some Scene {
        WindowGroup("OnFocusMac") {
            MacMainView()
                .environmentObject(timerEngine)
                .frame(minWidth: 760, minHeight: 560)
        }

        MenuBarExtra {
            MacMenuBarView()
                .environmentObject(timerEngine)
                .frame(width: 340)
        } label: {
            if timerEngine.isRunning {
                Text(timerEngine.displayTime)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            } else {
                Label(timerEngine.menuBarTitle, systemImage: timerEngine.menuBarSymbol)
            }
        }
        .menuBarExtraStyle(.window)
    }
}

final class OnFocusMacDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@MainActor
final class MacTimerEngine: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable, Codable {
        case pomodoro
        case timekeeper

        var id: String { rawValue }

        var title: String {
            switch self {
            case .pomodoro: return "Pomodoro"
            case .timekeeper: return "Kronometre"
            }
        }
    }

    enum PomodoroPhase: String, Codable {
        case focus
        case shortBreak
        case longBreak

        var title: String {
            switch self {
            case .focus: return "Odak"
            case .shortBreak: return "Kisa Mola"
            case .longBreak: return "Uzun Mola"
            }
        }

        var symbol: String {
            switch self {
            case .focus: return "bolt.fill"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "bed.double.fill"
            }
        }

        var defaultDuration: Int {
            switch self {
            case .focus: return 25 * 60
            case .shortBreak: return 5 * 60
            case .longBreak: return 15 * 60
            }
        }
    }

    struct SavedSession: Identifiable, Codable {
        let id: String
        let duration: Int
        let timestamp: Date
        let mode: Mode
        let phase: PomodoroPhase?
    }

    @Published var mode: Mode
    @Published var pomodoroPhase: PomodoroPhase = .focus
    @Published var isRunning = false
    @Published var isPaused = true
    @Published var remainingSeconds: Int = PomodoroPhase.focus.defaultDuration
    @Published var elapsedSeconds: Int = 0
    @Published var completedFocusSessions = 0
    @Published var recentSessions: [SavedSession] = []
    @Published var bannerMessage: String?

    private var timer: Timer?
    private var sessionStartedAt: Date?
    private var accumulatedElapsed: TimeInterval = 0
    private let localStore = MacSessionStore()
    private let userDefaults = UserDefaults.standard
    private let modeKey = "isTimeKeeperModeOn"

    init() {
        self.mode = userDefaults.bool(forKey: modeKey) ? .timekeeper : .pomodoro
        self.recentSessions = localStore.load()

        if mode == .timekeeper {
            remainingSeconds = 0
        }
    }

    var windowTitle: String {
        switch mode {
        case .pomodoro:
            return "\(pomodoroPhase.title) • \(displayTime)"
        case .timekeeper:
            return "Kronometre • \(displayTime)"
        }
    }

    var menuBarTitle: String {
        if isRunning {
            return displayTime
        }
        return mode == .pomodoro ? pomodoroPhase.title : "Krono"
    }

    var menuBarSymbol: String {
        if isRunning {
            return mode == .pomodoro ? pomodoroPhase.symbol : "stopwatch.fill"
        }
        return mode == .pomodoro ? "timer" : "stopwatch"
    }

    var displayTime: String {
        let source = mode == .pomodoro ? remainingSeconds : elapsedSeconds
        let hours = source / 3600
        let minutes = (source % 3600) / 60
        let seconds = source % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var primaryButtonTitle: String {
        if isRunning { return "Durdur" }
        if isPaused && currentTrackValue > 0 { return "Devam Et" }
        return "Baslat"
    }

    var currentTrackValue: Int {
        mode == .pomodoro ? pomodoroElapsedSeconds : elapsedSeconds
    }

    var pomodoroElapsedSeconds: Int {
        max(0, pomodoroPhase.defaultDuration - remainingSeconds)
    }

    var canSave: Bool {
        switch mode {
        case .pomodoro:
            return pomodoroPhase == .focus && pomodoroElapsedSeconds > 0
        case .timekeeper:
            return elapsedSeconds > 0
        }
    }

    var canCancel: Bool {
        switch mode {
        case .pomodoro:
            return pomodoroPhase == .focus ? pomodoroElapsedSeconds > 0 : true
        case .timekeeper:
            return elapsedSeconds > 0 || isRunning
        }
    }

    var phaseDescription: String {
        switch mode {
        case .pomodoro:
            let nextBreak = ((completedFocusSessions + 1) % 4 == 0) ? "Uzun mola" : "Kisa mola"
            switch pomodoroPhase {
            case .focus:
                return "Odak oturumu \(currentPomodoroIndex)/4 • Sonraki: \(nextBreak)"
            case .shortBreak, .longBreak:
                return "Mola sonrasi yeni odak oturumu hazir olacak"
            }
        case .timekeeper:
            return "Serbest sure takibi. Baslat, durdur, kaydet veya iptal et."
        }
    }

    var currentPomodoroIndex: Int {
        (completedFocusSessions % 4) + 1
    }

    func setMode(_ newMode: Mode) {
        guard mode != newMode else { return }
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = true
        sessionStartedAt = nil
        accumulatedElapsed = 0
        mode = newMode
        userDefaults.set(newMode == .timekeeper, forKey: modeKey)

        switch newMode {
        case .pomodoro:
            pomodoroPhase = .focus
            remainingSeconds = PomodoroPhase.focus.defaultDuration
            elapsedSeconds = 0
        case .timekeeper:
            elapsedSeconds = 0
            remainingSeconds = 0
        }
    }

    func togglePrimaryAction() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        sessionStartedAt = Date()
        isRunning = true
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func pause() {
        timer?.invalidate()
        timer = nil

        if mode == .timekeeper, let sessionStartedAt {
            accumulatedElapsed += Date().timeIntervalSince(sessionStartedAt)
            elapsedSeconds = Int(accumulatedElapsed.rounded())
        }

        sessionStartedAt = nil
        isRunning = false
        isPaused = true
    }

    func cancelCurrentSession() {
        pause()

        switch mode {
        case .pomodoro:
            if pomodoroPhase == .focus {
                remainingSeconds = PomodoroPhase.focus.defaultDuration
            } else {
                pomodoroPhase = .focus
                remainingSeconds = PomodoroPhase.focus.defaultDuration
            }
            bannerMessage = "Pomodoro oturumu sifirlandi."
        case .timekeeper:
            accumulatedElapsed = 0
            elapsedSeconds = 0
            bannerMessage = "Kronometre sifirlandi."
        }
    }

    func saveCurrentSession() {
        let duration: Int
        let phase: PomodoroPhase?

        switch mode {
        case .pomodoro:
            guard pomodoroPhase == .focus else {
                bannerMessage = "Molada kayit alinmaz."
                return
            }
            duration = pomodoroElapsedSeconds
            phase = .focus
        case .timekeeper:
            if isRunning, let sessionStartedAt {
                elapsedSeconds = Int((accumulatedElapsed + Date().timeIntervalSince(sessionStartedAt)).rounded())
            }
            duration = elapsedSeconds
            phase = nil
        }

        guard duration > 0 else {
            bannerMessage = "Kayit icin once sure baslatilmali."
            return
        }

        let saved = SavedSession(
            id: UUID().uuidString,
            duration: duration,
            timestamp: Date(),
            mode: mode,
            phase: phase
        )

        localStore.append(saved)
        recentSessions = localStore.load()
        bannerMessage = "Oturum kaydedildi."

        Task {
            await syncSessionToRemote(saved)
        }

        switch mode {
        case .pomodoro:
            pause()
            remainingSeconds = PomodoroPhase.focus.defaultDuration
        case .timekeeper:
            pause()
            accumulatedElapsed = 0
            elapsedSeconds = 0
        }
    }

    func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let mainWindow = NSApp.windows.first(where: { $0.title == "OnFocusMac" }) {
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }

    private func tick() {
        guard let sessionStartedAt else { return }

        switch mode {
        case .pomodoro:
            remainingSeconds = max(0, remainingSeconds - 1)
            if remainingSeconds == 0 {
                handlePomodoroCompletion()
            }
        case .timekeeper:
            elapsedSeconds = Int((accumulatedElapsed + Date().timeIntervalSince(sessionStartedAt)).rounded())
        }
    }

    private func handlePomodoroCompletion() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = true
        sessionStartedAt = nil

        if pomodoroPhase == .focus {
            let completed = SavedSession(
                id: UUID().uuidString,
                duration: PomodoroPhase.focus.defaultDuration,
                timestamp: Date(),
                mode: .pomodoro,
                phase: .focus
            )
            localStore.append(completed)
            recentSessions = localStore.load()
            Task {
                await syncSessionToRemote(completed)
            }

            completedFocusSessions += 1
            pomodoroPhase = completedFocusSessions % 4 == 0 ? .longBreak : .shortBreak
            remainingSeconds = pomodoroPhase.defaultDuration
            bannerMessage = "Odak oturumu bitti. \(pomodoroPhase.title) hazir."
        } else {
            pomodoroPhase = .focus
            remainingSeconds = PomodoroPhase.focus.defaultDuration
            bannerMessage = "Mola bitti. Yeni odak oturumu hazir."
        }
    }

    private func syncSessionToRemote(_ session: SavedSession) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        let sessionRef = userRef.collection("sessions").document(session.id)
        let date = session.timestamp
        let roundedDuration = session.duration

        let statInfos: [(id: String, divisor: Int?)] = [
            ("daily_\(Self.dayKey(for: date))", nil),
            ("weekly_\(Self.weekKey(for: date))", max(1, Self.elapsedDaysInWeek(for: date))),
            ("monthly_\(Self.monthKey(for: date))", max(1, Self.elapsedDaysInMonth(for: date))),
            ("yearly_\(Self.yearKey(for: date))", max(1, Self.elapsedDaysInYear(for: date))),
            ("fiveYears_\(Self.fiveYearsKey(for: date))", max(1, Self.elapsedDaysInFiveYears(for: date))),
        ]

        let sessionData: [String: Any] = [
            "id": session.id,
            "duration": TimeInterval(session.duration),
            "timestamp": Timestamp(date: session.timestamp),
        ]

        do {
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let sessionSnapshot = try transaction.getDocument(sessionRef)
                    if sessionSnapshot.exists {
                        return nil
                    }

                    let userSnapshot = try transaction.getDocument(userRef)
                    let userData = userSnapshot.data() ?? [:]
                    let currentTotalWork = userData["totalWorkTime"] as? Int ?? 0

                    transaction.setData(sessionData, forDocument: sessionRef, merge: false)
                    transaction.updateData(["totalWorkTime": currentTotalWork + roundedDuration], forDocument: userRef)

                    for statInfo in statInfos {
                        let statRef = userRef.collection("statistics").document(statInfo.id)
                        let snapshot = try transaction.getDocument(statRef)
                        let existing = snapshot.data() ?? [:]
                        let total = (existing["totalDuration"] as? Int ?? 0) + roundedDuration
                        var data: [String: Any] = ["totalDuration": total]

                        if let divisor = statInfo.divisor {
                            data["averageDuration"] = Double(total) / Double(divisor)
                        }

                        transaction.setData(data, forDocument: statRef, merge: true)
                    }
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
        } catch {
            bannerMessage = "Uzak kayit senkronize edilemedi, lokal kayit korundu."
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private static func weekKey(for date: Date) -> String {
        let calendar = Calendar.current
        return "\(calendar.component(.yearForWeekOfYear, from: date))-W\(calendar.component(.weekOfYear, from: date))"
    }

    private static func monthKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 1)
    }

    private static func yearKey(for date: Date) -> String {
        String(Calendar.current.component(.year, from: date))
    }

    private static func fiveYearsKey(for date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        return "\(year - 4)-\(year)"
    }

    private static func elapsedDaysInWeek(for date: Date) -> Int {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: date) else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: interval.start, to: Calendar.current.startOfDay(for: date)).day ?? 0
        return min(7, max(1, days + 1))
    }

    private static func elapsedDaysInMonth(for date: Date) -> Int {
        max(1, Calendar.current.component(.day, from: date))
    }

    private static func elapsedDaysInYear(for date: Date) -> Int {
        max(1, Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1)
    }

    private static func elapsedDaysInFiveYears(for date: Date) -> Int {
        let currentYear = Calendar.current.component(.year, from: date)
        let startYear = currentYear - 4
        var total = 0
        for year in startYear..<currentYear {
            var components = DateComponents()
            components.year = year
            let baseDate = Calendar.current.date(from: components) ?? date
            total += Calendar.current.range(of: .day, in: .year, for: baseDate)?.count ?? 365
        }
        total += elapsedDaysInYear(for: date)
        return max(1, total)
    }
}

private struct MacMainView: View {
    @EnvironmentObject private var timerEngine: MacTimerEngine

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        timerCard
                        controls
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    recentSessions
                        .frame(width: 280)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 18)

                windowTabBar
            }
            .navigationTitle(timerEngine.windowTitle)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.97, blue: 0.94),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OnFocus")
                .font(.system(size: 34, weight: .bold))

            Text("Pencere deneyimi artık normal uygulamadaki gibi butonlu sekmelerle ilerler.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            if let bannerMessage = timerEngine.bannerMessage {
                Text(bannerMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(
                    timerEngine.mode == .pomodoro ? timerEngine.pomodoroPhase.title : "Kronometre",
                    systemImage: timerEngine.mode == .pomodoro ? timerEngine.pomodoroPhase.symbol : "stopwatch.fill"
                )
                .font(.system(size: 15, weight: .semibold))

                Spacer()

                Text(timerEngine.isRunning ? "Aktif" : "Hazır")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(timerEngine.isRunning ? Color.green.opacity(0.16) : Color.gray.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(timerEngine.displayTime)
                .font(.system(size: 82, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(timerEngine.phaseDescription)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.74, blue: 0.47),
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Kontroller")
                .font(.system(size: 18, weight: .semibold))

            HStack(spacing: 12) {
                Button(timerEngine.primaryButtonTitle) {
                    timerEngine.togglePrimaryAction()
                }
                .buttonStyle(.borderedProminent)

                Button("Kaydet") {
                    timerEngine.saveCurrentSession()
                }
                .buttonStyle(.bordered)
                .disabled(!timerEngine.canSave)

                Button("Iptal Et") {
                    timerEngine.cancelCurrentSession()
                }
                .buttonStyle(.bordered)
                .disabled(!timerEngine.canCancel)
            }

            Group {
                if timerEngine.mode == .pomodoro {
                    Text("Pomodoro modunda odak ve mola akışları ayrıdır. Odak tamamlanınca oturum kaydedilir, mola ise sonraki döngüye hazırlık sağlar.")
                } else {
                    Text("Kronometre modunda süre serbest akar. Durdurup devam edebilir, istediğin an kaydedebilir veya sıfırlayabilirsin.")
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
        }
    }

    private var recentSessions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Kayıtlar")
                .font(.system(size: 18, weight: .semibold))

            if timerEngine.recentSessions.isEmpty {
                Text("Henüz kayıt yok.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(timerEngine.recentSessions.prefix(12)) { session in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(session.mode == .pomodoro ? "Pomodoro Kaydı" : "Kronometre Kaydı")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                Text("\(formatDuration(session.duration))")
                                    .font(.system(size: 12))
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.88))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var windowTabBar: some View {
        HStack(spacing: 12) {
            tabBarButton(
                title: "Pomodoro",
                subtitle: timerEngine.mode == .pomodoro ? timerEngine.pomodoroPhase.title : "Odak döngüsü",
                systemImage: "timer",
                isSelected: timerEngine.mode == .pomodoro
            ) {
                timerEngine.setMode(.pomodoro)
            }

            tabBarButton(
                title: "Kronometre",
                subtitle: timerEngine.isRunning && timerEngine.mode == .timekeeper ? timerEngine.displayTime : "Serbest sayaç",
                systemImage: "stopwatch",
                isSelected: timerEngine.mode == .timekeeper
            ) {
                timerEngine.setMode(.timekeeper)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func tabBarButton(
        title: String,
        subtitle: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(isSelected ? Color.white.opacity(0.22) : Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.84) : Color.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        isSelected
                        ? LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.48, blue: 0.27),
                                Color(red: 0.99, green: 0.67, blue: 0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.94), Color.white.opacity(0.84)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.clear : Color.black.opacity(0.06), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private func formatDuration(_ duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours > 0 {
            return "\(hours)s \(minutes)dk \(seconds)sn"
        }
        return "\(minutes)dk \(seconds)sn"
    }
}

private struct MacMenuBarView: View {
    @EnvironmentObject private var timerEngine: MacTimerEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            heroCard
            quickModeSwitcher
            actionGrid
            footerRow
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.95),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("OnFocus")
                        .font(.system(size: 20, weight: .bold))
                    Text(timerEngine.mode == .pomodoro ? timerEngine.pomodoroPhase.title : "Kronometre Modu")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.65))
                }

                Spacer()

                if timerEngine.isRunning {
                    liveTimerBadge
                } else {
                    statusBadge(title: "Hazır", systemImage: "sparkles")
                }
            }

            Text(timerEngine.displayTime)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.black.opacity(0.88))

            Text(timerEngine.phaseDescription)
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.62))
                .lineLimit(2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.84, blue: 0.69),
                    Color(red: 0.99, green: 0.93, blue: 0.85),
                    Color.white.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var quickModeSwitcher: some View {
        HStack(spacing: 10) {
            compactModeButton(title: "Pomodoro", systemImage: "timer", mode: .pomodoro)
            compactModeButton(title: "Kronometre", systemImage: "stopwatch", mode: .timekeeper)
        }
    }

    private func compactModeButton(title: String, systemImage: String, mode: MacTimerEngine.Mode) -> some View {
        let isSelected = timerEngine.mode == mode

        return Button {
            timerEngine.setMode(mode)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.black.opacity(0.88) : Color.white.opacity(0.78))
            )
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(isSelected ? 0.0 : 0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var actionGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton(
                    title: timerEngine.primaryButtonTitle,
                    systemImage: timerEngine.isRunning ? "pause.fill" : "play.fill",
                    prominent: true,
                    action: timerEngine.togglePrimaryAction
                )

                actionButton(
                    title: "Kaydet",
                    systemImage: "tray.and.arrow.down.fill",
                    prominent: false,
                    isDisabled: !timerEngine.canSave,
                    action: timerEngine.saveCurrentSession
                )
            }

            HStack(spacing: 10) {
                actionButton(
                    title: "İptal Et",
                    systemImage: "arrow.counterclockwise",
                    prominent: false,
                    isDisabled: !timerEngine.canCancel,
                    action: timerEngine.cancelCurrentSession
                )

                actionButton(
                    title: "Uygulamayı Aç",
                    systemImage: "macwindow",
                    prominent: false,
                    action: timerEngine.showMainWindow
                )
            }
        }
    }

    private func actionButton(
        title: String,
        systemImage: String,
        prominent: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        prominent
                        ? LinearGradient(
                            colors: [
                                Color(red: 0.95, green: 0.49, blue: 0.29),
                                Color(red: 0.98, green: 0.68, blue: 0.39)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.94), Color.white.opacity(0.84)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black.opacity(prominent ? 0.0 : 0.07), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
    }

    private var footerRow: some View {
        HStack(spacing: 8) {
            footerPill(title: timerEngine.mode.title, systemImage: timerEngine.mode == .pomodoro ? "timer" : "stopwatch")

            if timerEngine.isRunning {
                Text(timerEngine.displayTime)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(red: 0.14, green: 0.16, blue: 0.18))
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
            } else {
                footerPill(title: "Beklemede", systemImage: "pause.fill")
            }
        }
    }

    private var liveTimerBadge: some View {
        Text(timerEngine.displayTime)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .monospacedDigit()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.84))
            .foregroundStyle(Color.white)
            .clipShape(Capsule())
    }

    private func statusBadge(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.6))
            .clipShape(Capsule())
    }

    private func footerPill(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.gray.opacity(0.09))
            .clipShape(Capsule())
    }
}

private struct MacSessionStore {
    private let key = "mac.saved.sessions"

    func load() -> [MacTimerEngine.SavedSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([MacTimerEngine.SavedSession].self, from: data) else {
            return []
        }

        return sessions.sorted { $0.timestamp > $1.timestamp }
    }

    func append(_ session: MacTimerEngine.SavedSession) {
        var sessions = load()
        sessions.insert(session, at: 0)
        sessions = Array(sessions.prefix(50))
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
