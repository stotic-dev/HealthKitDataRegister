# HealthKitDataRegister

HealthKit で使用するデータを登録するツール

# 使い方

### 一日の HealthCare データ登録

```console
./script.sh -d 2025-06-21T07:30:00Z -steps 5000 -sodium 1.5 -sleepHours 6 -bloodPressureSystolic 120 -bloodPressureDiastolic 70
```

### 複数日の HealthCare データ一括登録

```console
./registHealthData.sh -f sample.csv
```

# サポートしている HealthCare 項目

| 項目名       |
| ------------ |
| 歩数         |
| ナトリウム   |
| 睡眠時間     |
| 血圧（最大） |
| 血圧（最小） |
