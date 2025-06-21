import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    // 各データタイプの定義
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let workoutSessionType = HKWorkoutType.workoutType()
    private let sodiumType = HKQuantityType.quantityType(forIdentifier: .dietarySodium)!
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    private let bloodPressureSystolicType = HKQuantityType.quantityType(
        forIdentifier: .bloodPressureSystolic)!
    private let bloodPressureDiastolicType = HKQuantityType.quantityType(
        forIdentifier: .bloodPressureDiastolic)!
        
    func authorization() async throws {
        let targetTypes: Set<HKSampleType> = [
            stepType,
            workoutSessionType,
            sodiumType,
            sleepType,
            bloodPressureSystolicType,
            bloodPressureDiastolicType,
        ]
        try await healthStore.requestAuthorization(toShare: targetTypes, read: targetTypes)
    }
    
    // 歩数データの保存（上書き対応）
    func saveStepCount(_ count: Int, date: Date) async throws {
        
        try await deleteHealthData(for: date, of: stepType)
        
        // 新しいデータの保存
        let quantity = HKQuantity(unit: .count(), doubleValue: Double(count))
        let sample = HKQuantitySample(
            type: stepType,
            quantity: quantity,
            start: date,
            end: date
        )
        try await healthStore.save(sample)
    }
    
    // ナトリウムの保存
    func saveSodium(_ milligrams: Double, date: Date) async throws {
        
        try await deleteHealthData(for: date, of: sodiumType)
        
        let quantity = HKQuantity(unit: .gramUnit(with: .milli), doubleValue: milligrams)
        let sample = HKQuantitySample(
            type: sodiumType,
            quantity: quantity,
            start: date,
            end: date
        )
        try await healthStore.save(sample)
    }
    
    // 睡眠時間の保存
    func saveSleepHours(_ hours: Double, date: Date) async throws {
        
        try await deleteHealthData(for: date, of: sleepType)
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endTime = calendar.date(byAdding: .hour, value: Int(hours), to: startOfDay)!
        
        let sample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startOfDay,
            end: endTime
        )
        try await healthStore.save(sample)
    }
    
    // 血圧の保存
    func saveBloodPressure(systolic: Int, diastolic: Int, date: Date) async throws {
        
        let systolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(systolic))
        let diastolicQuantity = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(diastolic))
        
        let systolicSample = HKQuantitySample(
            type: bloodPressureSystolicType,
            quantity: systolicQuantity,
            start: date,
            end: date
        )
        
        let diastolicSample = HKQuantitySample(
            type: bloodPressureDiastolicType,
            quantity: diastolicQuantity,
            start: date,
            end: date
        )
        
        try await healthStore.save([systolicSample, diastolicSample])
    }
    
    // 複数の健康データを保存
    func saveHealthData(_ healthData: HealthData) async throws {
        // 既存データの削除（日付単位で一括削除）
        try await deleteExistingData(for: healthData.date)
        
        // 新しいデータの保存
        if let steps = healthData.steps {
            try await saveStepCount(steps, date: healthData.date)
        }
        if let sodium = healthData.sodium {
            try await saveSodium(sodium, date: healthData.date)
        }
        if let sleepHours = healthData.sleepHours {
            try await saveSleepHours(sleepHours, date: healthData.date)
        }
        if let bloodPressure = healthData.bloodPressure {
            try await saveBloodPressure(
                systolic: bloodPressure.systolic,
                diastolic: bloodPressure.diastolic,
                date: healthData.date
            )
        }
    }
    
    // 複数日付の健康データを保存
    func saveMultipleHealthData(_ healthDataArray: [HealthData]) async throws {
        for healthData in healthDataArray {
            try await saveHealthData(healthData)
        }
    }
}

private extension HealthKitManager {
    
    // 指定された日付のデータを削除するメソッド
    func deleteExistingData(for date: Date) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        // 各データタイプの既存データを削除
        let typesToDelete: [HKSampleType] = [
            stepType,
            workoutSessionType,
            sodiumType,
            sleepType,
            bloodPressureSystolicType,
            bloodPressureDiastolicType,
        ]
        
        for type in typesToDelete {
            try await healthStore.deleteObjects(of: type, predicate: predicate)
        }
    }
    
    func deleteHealthData(for date: Date, of type: HKSampleType) async throws {
        
        let predicate = getPredicateByDate(date)
        try await healthStore.deleteObjects(of: type, predicate: predicate)
    }
    
    func getPredicateByDate(_ date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
    }
}
