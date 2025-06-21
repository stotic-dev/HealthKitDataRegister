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
            print("No Param")
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

struct CliRegisterModeView: View {
    
    @Environment(\.healthRegisterDataArgs) var healthRegisterDataArgs
    @State var isSuccess = false
    
    var body: some View {
        VStack {
            Text(isSuccess ? "OK" : "NO")
            Button("Register") {
                Task {
                    do {
                        try await HealthKitManager.shared.authorization()
                        try await HealthKitManager.shared.saveMultipleHealthData(healthRegisterDataArgs.healthDataArray)
                        isSuccess = true
                    }
                    catch {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
}
