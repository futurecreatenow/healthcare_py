# ログファイルのパス
$logFilePath = "C:\Users\teradatakayuki\Desktop\job\Powershell_tool\log.txt"

# Excelアプリケーションを作成
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false  # Excelを非表示で開く

# Excelファイルを開く
$workbook = $excel.Workbooks.Open("C:\Users\teradatakayuki\Desktop\job\Powershell_tool\test.xlsx")

# 指定したシートを取得
$sheet = $workbook.Sheets.Item("Sheet1")

# 指定したセルの値を取得（B3セル）
$cellValue = $sheet.Cells.Item(3,2).Value()

# 値が存在するか判定
if ($null -eq $cellValue -or $cellValue -eq "") {
    Write-Output "empty"
} else {
    Write-Output "get data >> $cellValue"

    # ログファイルへ値を記載
    $logEntry = "data : $cellValue"
    
    Add-Content -Path $logFilePath -Value $logEntry
}

# Excelを閉じる
$workbook.Close($false)
$excel.Quit()

# COMオブジェクトの解放
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[GC]::Collect()
