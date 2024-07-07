//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by BUSINESS ZAMED on 7.07.2024.
//

import WidgetKit
import SwiftUI

@main
struct weatherBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WeatherWidget()
    }
}
