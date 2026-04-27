import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var controller: MenuBarTimerController
    private let contentWidth: CGFloat = 308

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            timerCard
            controlRow
            openAppButton
        }
        .frame(width: contentWidth, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.96, blue: 0.92),
                    Color(red: 1.0, green: 0.99, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("OnFocus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.92))

                Spacer()

                modeBadge
            }

            Text(controller.state.displayTime)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .allowsTightening(true)
                .frame(width: contentWidth - 36, alignment: .leading)
                .foregroundStyle(Color.black.opacity(0.9))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.99, green: 0.93, blue: 0.86)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.orange.opacity(0.12), radius: 18, y: 8)
    }

    private var controlRow: some View {
        HStack(spacing: 10) {
            primaryControlButton

            if controller.state.mode == .timekeeper {
                squareControlButton
            }

            Spacer(minLength: 0)

            cancelControlButton
        }
        .padding(.horizontal, 4)
    }

    private var openAppButton: some View {
        Button(action: controller.openMainApp) {
            HStack(spacing: 8) {
                Image(systemName: "macwindow")
                Text("Open OnFocus")
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(width: contentWidth)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.97, green: 0.95, blue: 0.93)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(Color.black.opacity(0.88))
        }
        .buttonStyle(.plain)
    }

    private var primaryControlButton: some View {
        circleButton(
            systemImage: controller.state.isRunning ? "pause.fill" : "play.fill",
            size: 48,
            fill: LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.48, blue: 0.27),
                    Color(red: 1.0, green: 0.69, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            foreground: .white,
            imageOffsetX: controller.state.isRunning ? 0 : 2,
            action: controller.triggerPrimaryAction
        )
    }

    private var squareControlButton: some View {
        circleButton(
            systemImage: "stop.fill",
            size: 48,
            fill: LinearGradient(
                colors: [
                    Color(red: 0.19, green: 0.22, blue: 0.26),
                    Color(red: 0.31, green: 0.34, blue: 0.39)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            foreground: .white,
            isDisabled: !controller.state.canSave,
            action: controller.saveSession
        )
    }

    private var cancelControlButton: some View {
        circleButton(
            systemImage: "xmark",
            size: 48,
            fill: LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.95, green: 0.95, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            foreground: Color(red: 0.2, green: 0.22, blue: 0.25),
            showsBorder: true,
            isDisabled: !controller.state.canCancel,
            action: controller.cancelSession
        )
    }

    private var modeBadge: some View {
        Label(
            controller.state.mode == .pomodoro ? "Pomodoro" : "Timekeeper",
            systemImage: controller.state.mode == .pomodoro ? "timer" : "stopwatch"
        )
        .font(.system(size: 11, weight: .bold))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.orange.opacity(0.14))
        .foregroundStyle(Color(red: 0.77, green: 0.34, blue: 0.12))
        .clipShape(Capsule())
    }

    private func circleButton(
        systemImage: String,
        size: CGFloat,
        fill: LinearGradient,
        foreground: Color,
        showsBorder: Bool = false,
        imageOffsetX: CGFloat = 0,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(fill)
                    .opacity(isDisabled ? 0.85 : 1)

                Image(systemName: systemImage)
                    .font(.system(size: size * 0.32, weight: .bold))
                    .foregroundStyle(foreground)
                    .opacity(isDisabled ? 0.75 : 1)
                    .offset(x: imageOffsetX)
            }
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(
                        Color.black.opacity(showsBorder ? (isDisabled ? 0.12 : 0.08) : 0.0),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
