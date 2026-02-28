//
//  HeatherWidgetBundle.swift
//  HeatherWidget
//
//  Created by Jacqueline Harnish on 2/12/26.
//

import WidgetKit
import SwiftUI
import CoreText

@main
struct HeatherWidgetBundle: WidgetBundle {

    init() {
        Self.registerFonts()
    }

    var body: some Widget {
        HeatherWeatherWidget()
    }

    static func registerFonts() {
        let fontNames = [
            "Poppins-Regular",
            "Poppins-Medium",
            "Poppins-SemiBold",
            "Poppins-Bold",
        ]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
