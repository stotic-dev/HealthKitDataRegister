//
//  CliRegisterModeView.swift
//  HealthKitTestDataRegister
//
//  Created by 佐藤汰一 on 2025/06/22.
//

import SwiftUI

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
