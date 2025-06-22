#!/bin/bash

# デフォルト値
date_val=""
steps=""
sodium=""
sleepHours=""
bpSystolic=""
bpDiastolic=""
csv_file=""

# 引数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--date)
      date_val="$2"
      shift 2
      ;;
    -steps)
      steps="$2"
      shift 2
      ;;
    -sodium)
      sodium="$2"
      shift 2
      ;;
    -sleepHours)
      sleepHours="$2"
      shift 2
      ;;
    -bloodPressureSystolic)
      bpSystolic="$2"
      shift 2
      ;;
    -bloodPressureDiastolic)
      bpDiastolic="$2"
      shift 2
      ;;
    -f|--file)
      csv_file="$2"
      shift 2
      ;;
    *)
      echo "不明なオプション: $1"
      exit 1
      ;;
  esac
done

registDataArgs=""

# CSVファイルが指定されている場合の処理
if [[ -n "$csv_file" ]]; then
  if [[ ! -f "$csv_file" ]]; then
    echo "ファイルが存在しません: $csv_file"
    exit 1
  fi

  
  first_line=true

  while IFS=',' read -r date steps sodium sleepHours systolic diastolic; do
    if $first_line; then
      first_line=false
      continue
    fi

    # 各項目の前後スペース除去
    date=$(echo "$date" | xargs)
    steps=$(echo "$steps" | xargs)
    sodium=$(echo "$sodium" | xargs)
    sleepHours=$(echo "$sleepHours" | xargs)
    systolic=$(echo "$systolic" | xargs)
    diastolic=$(echo "$diastolic" | xargs)

    part="-date, $date"
    [[ -n "$steps" ]] && part="$part, -steps, $steps"
    [[ -n "$sodium" ]] && part="$part, -sodium, $sodium"
    [[ -n "$sleepHours" ]] && part="$part, -sleepHours, $sleepHours"
    if [[ -n "$systolic" && -n "$diastolic" ]]; then
      part="$part, -bloodPressure, $systolic, $diastolic"
    fi

    registDataArgs="${registDataArgs:+$registDataArgs, }$part"
  done < "$csv_file"
else
  # CSVがない場合は現在時刻をデフォルトに設定
  if [[ -z "$date_val" ]]; then
  date_val=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  fi  
  registDataArgs="-date, $date_val"
  [[ -n "$steps" ]] && registDataArgs="$registDataArgs, -steps, $steps"
  [[ -n "$sodium" ]] && registDataArgs="$registDataArgs, -sodium, $sodium"
  [[ -n "$sleepHours" ]] && registDataArgs="$registDataArgs, -sleepHours, $sleepHours"
  if [[ -n "$bpSystolic" && -n "$bpDiastolic" ]]; then
  registDataArgs="$registDataArgs, -bloodPressure, $bpSystolic, $bpDiastolic"
  fi  
fi

echo $registDataArgs
echo "registring data..."

# ログを一時ファイルに保存
LOGFILE=$(mktemp)

xcodebuild test \
  -project HealthKitTestDataRegister.xcodeproj \
  -scheme HealthKitTestDataRegister \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
  -quiet \
  REGISTER_HEALTH_DATA="$registDataArgs" \
  &> /dev/null

# 直前のコマンドの終了ステータスを取得
if [ $? -eq 0 ]; then
  echo "✅ success!!"
else
  echo "❌ fail. check below log."
fi
