//
//  Constants.swift
//  ios-pwa-wrapper
//
//  Created by Martin Kainzbauer on 29/10/2017.
//  Copyright © 2017 Martin Kainzbauer. All rights reserved.
//

//import Foundation
import UIKit

// Basic configuration
let webAppUrl = URL(string: "https://www.duckduckgo.com")
let allowedOrigin = "duckduckgo.com"
let appTitle = "iOS PWA Wrapper"
let menuButtonJavascript = "document.querySelector('body').remove();"

// Settings
let changeAppTitleToPageTitle = false
let forceLargeTitle = false

// Colors
let useLightStatusBarStyle = true
let primaryColor = getColorFromHex(hex: 0xF44336, alpha: 1.0)
let primaryColorDark = getColorFromHex(hex: 0xD32F2F, alpha: 1.0)
let primaryColorLight = getColorFromHex(hex: 0xE57373, alpha: 1.0)
let progressBarColor = getColorFromHex(hex: 0x4CAF50, alpha: 1.0)
let navigationButtonColor = getColorFromHex(hex: 0xFFFFFF, alpha: 1.0)
let navigationTitleColor = getColorFromHex(hex: 0xFFFFFF, alpha: 1.0)

// Color Helper function
func getColorFromHex(hex: UInt, alpha: CGFloat) -> UIColor {
    return UIColor(
        red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(hex & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}
