import Foundation
import Observation

@MainActor
@Observable
final class HealthDataViewModel {
    var steps: String = ""
    var sodium: String = ""
    var sleepHours: String = ""
    var morningSystolic: String = ""
    var morningDiastolic: String = ""
    var eveningSystolic: String = ""
    var eveningDiastolic: String = ""
    var selectedDate: Date = Date()
    
    var isSaving: Bool = false
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    func onAppear() async {
        do {
            try await HealthKitManager.shared.authorization()
        }
        catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    func saveHealthData() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            let calendar = Calendar.current
            let selectedDay = calendar.startOfDay(for: selectedDate)
            
            // 起床時の血圧用の日時（9:00）
            var morningComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay)
            morningComponents.hour = 9
            morningComponents.minute = 0
            guard let morningDate = calendar.date(from: morningComponents) else { return }
            
            // 就寝時の血圧用の日時（22:00）
            var eveningComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay)
            eveningComponents.hour = 22
            eveningComponents.minute = 0
            guard let eveningDate = calendar.date(from: eveningComponents) else { return }
            
            // 歩数データの保存
            if let steps = Int(steps) {
                try await HealthKitManager.shared.saveStepCount(steps, date: selectedDay)
            }
            
            // ナトリウムの保存
            if let sodium = Double(sodium) {
                try await HealthKitManager.shared.saveSodium(sodium, date: selectedDay)
            }
            
            // 睡眠時間の保存
            if let sleepHours = Double(sleepHours) {
                try await HealthKitManager.shared.saveSleepHours(sleepHours, date: selectedDay)
            }
            
            // 起床時の血圧保存
            if let morningSystolic = Int(morningSystolic),
               let morningDiastolic = Int(morningDiastolic)
            {
                try await HealthKitManager.shared.saveBloodPressure(
                    systolic: morningSystolic,
                    diastolic: morningDiastolic,
                    date: morningDate
                )
            }
            
            // 就寝時の血圧保存
            if let eveningSystolic = Int(eveningSystolic),
               let eveningDiastolic = Int(eveningDiastolic)
            {
                try await HealthKitManager.shared.saveBloodPressure(
                    systolic: eveningSystolic,
                    diastolic: eveningDiastolic,
                    date: eveningDate
                )
            }
            
            alertMessage = "データを保存しました"
            showAlert = true
        } catch {
            alertMessage = "エラーが発生しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
