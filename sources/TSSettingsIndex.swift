//
//  TSSettingsIndex.swift
//  TrollSpeed
//
//  Created by Lessica on 2024/1/25.
//

import Foundation

enum TSSettingsIndex: Int, CaseIterable {
    case masterSwitch

    var key: String {
        switch self {
        case .masterSwitch:
            return "FGimguiEnabled"
        }
    }

    var title: String {
        switch self {
        case .masterSwitch:
            return "总开关"
        }
    }

    func subtitle(highlighted: Bool, restartRequired: Bool) -> String {
        switch self {
        case .masterSwitch:
            return highlighted ? "开启" : "关闭"
        }
    }
}
