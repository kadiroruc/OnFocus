//
//  Constants.swift
//  Test
//
//  Created by Abdulkadir Oruç on 9.03.2025.
//

import Foundation

struct Constants {
    
    struct SegueIdentifiers {
        static let loginToHome = "loginToHome"
        static let homeToSettings = "homeToSettings"
        static let signUpToFill = "signUpToFill"
    }
    
    struct Icons{
        static let eyeSlash = "eye.slash"
        static let person = "person"
        static let personFill = "person.fill"
        static let clockArrowCirclepath = "clock.arrow.circlepath"
        static let clockFill = "clock.fill"
        static let person2Fill = "person.2.fill"
        static let person2 = "person.2"
        static let chartLineUptrendXyaxis = "chart.line.uptrend.xyaxis"
        static let chartFill = "chart.fill"
        static let bell = "bell"
        static let bellFill = "bell.fill"
        static let ellipsis = "ellipsis"
        static let personBadgePlus = "person.badge.plus"
        static let eye = "eye"
        static let play = "play"
        static let playCircle = "play.circle"
        static let personCircle = "person.circle"
        static let xmarkCircle = "xmark.circle"
        static let gear = "gear"
        static let pause = "pause"
        static let pauseCircle = "pause.circle"
        static let deskClock = "deskclock"
        static let arrowCirclePath = "arrow.circlepath"
        static let speakerWave2 = "speaker.wave.2"
        static let envelopeFill = "envelope.fill"
        static let lockFill = "lock.fill"
        static let square = "square"
        static let checkmarkSquareFill = "checkmark.square.fill"
        static let personCropCircleFill = "person.crop.circle.fill"
        static let squareAndPencilCircleFill = "square.and.pencil.circle.fill"
        static let magnifyingglassCircleFill = "magnifyingglass.circle.fill"
        static let xmark = "xmark"
        static let checkmark = "checkmark"
        static let personBadgeClockFill = "person.badge.clock.fill"
        static let personFillCheckmark = "person.fill.checkmark"
        static let stopCircle = "stop.circle"
        static let xmarkBin = "xmark.bin"
        static let xmarkIcloud = "xmark.icloud"
        static let timer = "timer"
    }
    
    struct CellIdentifiers{
        static let personCell = "personCell"
    }
    
    struct ValidationMessages{
        static var invalidEmail: String { L10n.Validation.invalidEmail }
        static var invalidPassword: String { L10n.Validation.invalidPassword }
        static var notLoggedIn: String { L10n.Validation.notLoggedIn }
        static var pleaseStartTimer: String { L10n.Validation.pleaseStartTimer }
        static var skipSessionConfirmation: String { L10n.Validation.skipSessionConfirmation }
        static var nicknameTaken: String { L10n.Validation.nicknameTaken }
        static var fillAllFields: String { L10n.Validation.fillAllFields }
        static var selectImage: String { L10n.Validation.selectImage }
        static var friendRequestSent: String { L10n.Validation.friendRequestSent }
        static var friendRequestError: String { L10n.Validation.friendRequestError }
        static var logoutError: String { L10n.Validation.logoutError }
        static var friendRequestCancelled: String { L10n.Validation.friendRequestCancelled }
        static var friendRequestCancelledError: String { L10n.Validation.friendRequestCancelledError }
        static var profileImageUpdated: String { L10n.Validation.profileImageUpdated }
        static var profileImageUpdateError: String { L10n.Validation.profileImageUpdateError }
        static var resetTimeKeeperConfirmation: String { L10n.Validation.resetTimekeeperConfirmation }
        static var emailVerificationSent: String { L10n.Validation.emailVerificationSent }
    }
    
    struct Colors{
        static let darkGray = "#333333"
        static let mediumDarkGray = "#444444"
        static let softOrange = "#FF8A5C"
        static let lightPeach = "#FEF6F0"
        static let mintGreen = "#70C1B3"
        static let lightOrange = "#FFB570"
        static let lightGray = "#A5A5A5"
        static let babyBlue = "#A9DEF9"
        static let palePeach = "#FBE2C8"
    }
    
    struct Firebase{
        static let pending = "pending"
        static let accepted = "accepted"
        static let rejected = "rejected"

    }
}
