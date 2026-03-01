import Foundation

enum L10n {
    enum Validation {
        static let invalidEmail = NSLocalizedString("validation.invalid_email", comment: "")
        static let invalidPassword = NSLocalizedString("validation.invalid_password", comment: "")
        static let notLoggedIn = NSLocalizedString("validation.not_logged_in", comment: "")
        static let pleaseStartTimer = NSLocalizedString("validation.please_start_timer", comment: "")
        static let skipSessionConfirmation = NSLocalizedString("validation.skip_session_confirmation", comment: "")
        static let nicknameTaken = NSLocalizedString("validation.nickname_taken", comment: "")
        static let fillAllFields = NSLocalizedString("validation.fill_all_fields", comment: "")
        static let selectImage = NSLocalizedString("validation.select_image", comment: "")
        static let friendRequestSent = NSLocalizedString("validation.friend_request_sent", comment: "")
        static let friendRequestError = NSLocalizedString("validation.friend_request_error", comment: "")
        static let logoutError = NSLocalizedString("validation.logout_error", comment: "")
        static let friendRequestCancelled = NSLocalizedString("validation.friend_request_cancelled", comment: "")
        static let friendRequestCancelledError = NSLocalizedString("validation.friend_request_cancelled_error", comment: "")
        static let profileImageUpdated = NSLocalizedString("validation.profile_image_updated", comment: "")
        static let profileImageUpdateError = NSLocalizedString("validation.profile_image_update_error", comment: "")
        static let resetTimekeeperConfirmation = NSLocalizedString("validation.reset_timekeeper_confirmation", comment: "")
        static let emailVerificationSent = NSLocalizedString("validation.email_verification_sent", comment: "")
        static let sessionSavedOffline = NSLocalizedString("validation.session_saved_offline", comment: "")
        static let sessionSaveFailed = NSLocalizedString("validation.session_save_failed", comment: "")
        static let sessionSaveSynced = NSLocalizedString("validation.session_save_synced", comment: "")
        static let networkOffline = NSLocalizedString("validation.network_offline", comment: "")
        static let timekeeperAutoSaved = NSLocalizedString("validation.timekeeper_auto_saved", comment: "")
    }

    enum Login {
        static let title = NSLocalizedString("login.title", comment: "")
        static let emailPlaceholder = NSLocalizedString("login.email_placeholder", comment: "")
        static let passwordPlaceholder = NSLocalizedString("login.password_placeholder", comment: "")
        static let signIn = NSLocalizedString("login.sign_in", comment: "")
        static let forgotPassword = NSLocalizedString("login.forgot_password", comment: "")
        static let newHere = NSLocalizedString("login.new_here", comment: "")
        static let signUp = NSLocalizedString("login.sign_up", comment: "")
        static let resetEmailSent = NSLocalizedString("login.reset_email_sent", comment: "")
    }

    enum Alert {
        static let ok = NSLocalizedString("alert.ok", comment: "")
        static let errorTitle = NSLocalizedString("alert.error_title", comment: "")
        static let infoTitle = NSLocalizedString("alert.info_title", comment: "")
        static let successTitle = NSLocalizedString("alert.success_title", comment: "")
        static let warningTitle = NSLocalizedString("alert.warning_title", comment: "")
        static let cancel = NSLocalizedString("alert.cancel", comment: "")
    }

    enum Home {
        static let breakLabel = NSLocalizedString("home.break", comment: "")
        static func sessions(count: Int) -> String {
            String(format: NSLocalizedString("home.sessions", comment: ""), count)
        }
        static func onlineCount(_ count: Int) -> String {
            String(format: NSLocalizedString("home.online_count", comment: ""), count)
        }
        static func friendsWorking(online: Int, total: Int) -> String {
            String(format: NSLocalizedString("home.friends_working", comment: ""), online, total)
        }
        static let sessionCompleteTitle = NSLocalizedString("home.session_complete_title", comment: "")
        static let sessionCompleteBody = NSLocalizedString("home.session_complete_body", comment: "")
        static let breakOverTitle = NSLocalizedString("home.break_over_title", comment: "")
        static let breakOverBody = NSLocalizedString("home.break_over_body", comment: "")
    }

    enum FillProfile {
        static let title = NSLocalizedString("fill_profile.title", comment: "")
        static let subtitle = NSLocalizedString("fill_profile.subtitle", comment: "")
        static let fullNamePlaceholder = NSLocalizedString("fill_profile.full_name_placeholder", comment: "")
        static let nicknamePlaceholder = NSLocalizedString("fill_profile.nickname_placeholder", comment: "")
        static let startButton = NSLocalizedString("fill_profile.start_button", comment: "")
        static let errorTitle = NSLocalizedString("fill_profile.error_title", comment: "")
    }

    enum SignUp {
        static let title = NSLocalizedString("sign_up.title", comment: "")
        static let emailPlaceholder = NSLocalizedString("sign_up.email_placeholder", comment: "")
        static let passwordPlaceholder = NSLocalizedString("sign_up.password_placeholder", comment: "")
        static let signUpButton = NSLocalizedString("sign_up.sign_up", comment: "")
        static let haveAccount = NSLocalizedString("sign_up.have_account", comment: "")
        static let signIn = NSLocalizedString("sign_up.sign_in", comment: "")
        static let terms = NSLocalizedString("sign_up.terms", comment: "")
        static let mustAgree = NSLocalizedString("sign_up.must_agree", comment: "")
    }

    enum EULA {
        static let accept = NSLocalizedString("eula.accept", comment: "")
        static let reject = NSLocalizedString("eula.reject", comment: "")
        static let fallbackHtml = NSLocalizedString("eula.fallback_html", comment: "")
    }

    enum Settings {
        static let title = NSLocalizedString("settings.title", comment: "")
        static let timekeeperMode = NSLocalizedString("settings.timekeeper_mode", comment: "")
        static let deleteAccount = NSLocalizedString("settings.delete_account", comment: "")
        static let deleteData = NSLocalizedString("settings.delete_data", comment: "")
        static let confirmDeleteAccount = NSLocalizedString("settings.confirm_delete_account", comment: "")
        static let accountDeleted = NSLocalizedString("settings.account_deleted", comment: "")
        static let confirmDeleteData = NSLocalizedString("settings.confirm_delete_data", comment: "")
        static let dataDeleted = NSLocalizedString("settings.data_deleted", comment: "")
    }

    enum Notifications {
        static let emptyState = NSLocalizedString("notifications.empty_state", comment: "")
        static func friendRequest(from name: String) -> String {
            String(format: NSLocalizedString("notifications.friend_request", comment: ""), name)
        }
    }

    enum Profile {
        static let menuTitle = NSLocalizedString("profile.menu_title", comment: "")
        static let changePhoto = NSLocalizedString("profile.change_photo", comment: "")
        static let logout = NSLocalizedString("profile.logout", comment: "")
        static let cancel = NSLocalizedString("profile.cancel", comment: "")
        static let friendRequestPendingTitle = NSLocalizedString("profile.friend_request_pending_title", comment: "")
        static let friendRequestPendingMessage = NSLocalizedString("profile.friend_request_pending_message", comment: "")
        static let cancelRequest = NSLocalizedString("profile.cancel_request", comment: "")
        static let removeFriendTitle = NSLocalizedString("profile.remove_friend_title", comment: "")
        static let deleteFriend = NSLocalizedString("profile.delete_friend", comment: "")
        static func totalWorkHour(_ text: String) -> String {
            String(format: NSLocalizedString("profile.total_work_hour", comment: ""), text)
        }
        static func currentStreakDay(_ count: Int) -> String {
            String(format: NSLocalizedString("profile.current_streak_day", comment: ""), count)
        }
    }

    enum Search {
        static let title = NSLocalizedString("search.title", comment: "")
        static let placeholder = NSLocalizedString("search.placeholder", comment: "")
        static let noResults = NSLocalizedString("search.no_results", comment: "")
    }

    enum Leaderboard {
        static let exampleUser = NSLocalizedString("leaderboard.example_user", comment: "")
        static let zeroTime = NSLocalizedString("leaderboard.zero_time", comment: "")
        static func stateLabel(_ percentile: Int) -> String {
            String(format: NSLocalizedString("leaderboard.state_label", comment: ""), percentile)
        }
        static func rankLabel(_ rank: String) -> String {
            String(format: NSLocalizedString("leaderboard.rank_label", comment: ""), rank)
        }
    }

    enum Statistics {
        static let averageLabel = NSLocalizedString("statistics.average_label", comment: "")
        static let progressLabel = NSLocalizedString("statistics.progress_label", comment: "")
        static let averageInfoTitle = NSLocalizedString("statistics.average_info_title", comment: "")
        static let averageInfoMessage = NSLocalizedString("statistics.average_info_message", comment: "")
        static let progressInfoTitle = NSLocalizedString("statistics.progress_info_title", comment: "")
        static let progressInfoMessage = NSLocalizedString("statistics.progress_info_message", comment: "")
        static let chartLabel = NSLocalizedString("statistics.chart_label", comment: "")
        static let rangeOneWeek = NSLocalizedString("statistics.range_one_week", comment: "")
        static let rangeOneMonth = NSLocalizedString("statistics.range_one_month", comment: "")
        static let rangeOneYear = NSLocalizedString("statistics.range_one_year", comment: "")
        static let rangeFiveYears = NSLocalizedString("statistics.range_five_years", comment: "")
    }

    enum TabBar {
        static let leaderboardTitle = NSLocalizedString("tab.leaderboard_title", comment: "")
        static let statisticsTitle = NSLocalizedString("tab.statistics_title", comment: "")
        static let notificationsTitle = NSLocalizedString("tab.notifications_title", comment: "")
        static let profileTitle = NSLocalizedString("tab.profile_title", comment: "")
    }

    enum Auth {
        static let userCreationFailed = NSLocalizedString("auth.user_creation_failed", comment: "")
        static let emailNotVerified = NSLocalizedString("auth.email_not_verified", comment: "")
        static let userNotFound = NSLocalizedString("auth.user_not_found", comment: "")
    }

    enum Errors {
        static let imageUploadFailed = NSLocalizedString("errors.image_upload_failed", comment: "")
        static let documentNotFound = NSLocalizedString("errors.document_not_found", comment: "")
        static let userIdNil = NSLocalizedString("errors.user_id_nil", comment: "")
        static let profileDataNotFound = NSLocalizedString("errors.profile_data_not_found", comment: "")
        static let invalidImageData = NSLocalizedString("errors.invalid_image_data", comment: "")
        static let networkManagerUnavailable = NSLocalizedString("errors.network_manager_unavailable", comment: "")
        static let userNotAuthenticated = NSLocalizedString("errors.user_not_authenticated", comment: "")
        static let versionInfoNotFound = NSLocalizedString("errors.version_info_not_found", comment: "")
    }

    enum Update {
        static let title = NSLocalizedString("update.title", comment: "")
        static let message = NSLocalizedString("update.message", comment: "")
        static let action = NSLocalizedString("update.action", comment: "")
    }
}
