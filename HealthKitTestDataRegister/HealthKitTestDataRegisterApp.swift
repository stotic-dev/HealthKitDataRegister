//
//  HealthKitTestDataRegisterApp.swift
//  HealthKitTestDataRegister
//
//  Created by 佐藤汰一 on 2025/06/17.
//

import SwiftUI

@main
struct HealthKitTestDataRegisterApp: App {
    private let isCliMode: Bool
    private var arguments: CommandLineArguments?
    
    init() {
        do {
            arguments = try CommandLineArguments.parse()
            isCliMode = true
        }
        catch {
            print("No Param: \(error)")
            isCliMode = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isCliMode {
                CliRegisterModeView()
                    .environment(\.healthRegisterDataArgs,
                                  arguments ?? .init(healthDataArray: []))
            }
            else {
                ContentView()
            }
        }
    }
}

extension EnvironmentValues {
    @Entry var healthRegisterDataArgs: CommandLineArguments = .init(healthDataArray: [])
}
