//
//  ContentView.swift
//  HealthKitTestDataRegister
//
//  Created by 佐藤汰一 on 2025/06/17.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = HealthDataViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本データ")) {
                    DatePicker("日付", selection: $viewModel.selectedDate, displayedComponents: [.date])
                    
                    TextField("歩数", text: $viewModel.steps)
                        .keyboardType(.numberPad)
                    
                    TextField("ナトリウム（mg）", text: $viewModel.sodium)
                        .keyboardType(.decimalPad)
                    
                    TextField("睡眠時間（時間）", text: $viewModel.sleepHours)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("起床時の血圧（9:00）")) {
                    TextField("最大値（mmHg）", text: $viewModel.morningSystolic)
                        .keyboardType(.numberPad)
                    
                    TextField("最小値（mmHg）", text: $viewModel.morningDiastolic)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("就寝時の血圧（22:00）")) {
                    TextField("最大値（mmHg）", text: $viewModel.eveningSystolic)
                        .keyboardType(.numberPad)
                    
                    TextField("最小値（mmHg）", text: $viewModel.eveningDiastolic)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.saveHealthData()
                        }
                    }) {
                        if viewModel.isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("データを保存")
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .navigationTitle("HealthKitデータ登録")
            .alert("通知", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

#Preview {
    ContentView()
}
