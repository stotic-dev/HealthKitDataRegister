import Foundation

// 1つの日付に対する健康データを表す構造体
struct HealthData {
    let date: Date
    let steps: Int?
    let sodium: Double?  // mg
    let sleepHours: Double?
    let bloodPressure: BloodPressure?
    
    struct BloodPressure {
        let systolic: Int  // mmHg
        let diastolic: Int  // mmHg
    }
}

// コマンドライン引数のパース処理
struct CommandLineArguments {
    let healthDataArray: [HealthData]
    
    static func parse() throws -> CommandLineArguments {
        guard let environmentValue = ProcessInfo.processInfo.environment["REGISTER_HEALTH_DATA"] else {
            
            throw CommandLineError.invalidEnvironment
        }
        let args = environmentValue
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        var healthDataArray: [HealthData] = []
        
        // 引数のパース処理
        var currentDate: Date?
        var currentSteps: Int?
        var currentSodium: Double?
        var currentSleepHours: Double?
        var currentSystolic: Int?
        var currentDiastolic: Int?
        
        let dateFormatter = ISO8601DateFormatter()
        
        for (index, arg) in args.enumerated() {
            switch arg {
            case "-date":
                // 前のデータが存在する場合は保存
                if let date = currentDate {
                    let healthData = HealthData(
                        date: date,
                        steps: currentSteps,
                        sodium: currentSodium,
                        sleepHours: currentSleepHours,
                        bloodPressure: currentSystolic != nil && currentDiastolic != nil
                        ? HealthData.BloodPressure(systolic: currentSystolic!, diastolic: currentDiastolic!)
                        : nil
                    )
                    healthDataArray.append(healthData)
                }
                
                // 新しい日付の処理開始
                guard index + 1 <= args.count,
                      let date = dateFormatter.date(from: args[index + 1])
                else {
                    throw CommandLineError.invalidDateFormat
                }
                currentDate = date
                // 他の値をリセット
                currentSteps = nil
                currentSodium = nil
                currentSleepHours = nil
                currentSystolic = nil
                currentDiastolic = nil
                
            case "-steps":
                guard index + 1 <= args.count,
                      let steps = Int(args[index + 1])
                else {
                    throw CommandLineError.invalidStepsValue
                }
                currentSteps = steps
                
            case "-sodium":
                guard index + 1 <= args.count,
                      let sodium = Double(args[index + 1])
                else {
                    throw CommandLineError.invalidSodiumValue
                }
                currentSodium = sodium
                
            case "-sleepHours":
                guard index + 1 <= args.count,
                      let hours = Double(args[index + 1])
                else {
                    throw CommandLineError.invalidSleepHoursValue
                }
                currentSleepHours = hours
                
            case "-bloodPressure":
                guard index + 2 <= args.count,
                      let systolic = Int(args[index + 1]),
                      let diastolic = Int(args[index + 2])
                else {
                    throw CommandLineError.invalidBloodPressureValue
                }
                currentSystolic = systolic
                currentDiastolic = diastolic
            default:
                print("Get no option flg: \(arg)")
            }
        }
        
        // 最後のデータを保存
        if let date = currentDate {
            let healthData = HealthData(
                date: date,
                steps: currentSteps,
                sodium: currentSodium,
                sleepHours: currentSleepHours,
                bloodPressure: currentSystolic != nil && currentDiastolic != nil
                ? HealthData.BloodPressure(systolic: currentSystolic!, diastolic: currentDiastolic!) : nil
            )
            healthDataArray.append(healthData)
        }
        
        return CommandLineArguments(healthDataArray: healthDataArray)
    }
}

// エラー定義
enum CommandLineError: Error {
    case invalidDateFormat
    case invalidStepsValue
    case invalidSodiumValue
    case invalidSleepHoursValue
    case invalidBloodPressureValue
    case invalidEnvironment
}
