# Excel COMオブジェクトを使用
param (
    [string]$ConfigFile = "config.ini",
    [string]$TargetFolder = "..\files",
    [string]$TestFolder = "..\test",
    [string]$LogFile = "result.txt"
)

# config.ini の読み込み
if (-Not (Test-Path $ConfigFile)) {
    Write-Host "エラー: ファイル '$ConfigFile' が見つかりません。"
    exit 1
}

$ConfigData = @{}
foreach ($line in Get-Content $ConfigFile -Encoding UTF8) {
    if ($line -match '^(.*?)=(.*?)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $ConfigData[$key] = $value
    }
}

# 設定値の取得
$SheetName = $ConfigData["SheetName"]
$CellRow = [int]$ConfigData["CellRow"]
$CellColumn = [int]$ConfigData["CellColumn"]

# Excel COMオブジェクトの作成
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.DisplayAlerts = $false

$LogContent = @()
$Folders = @($TargetFolder, $TestFolder)

foreach ($Folder in $Folders) {
    if (-Not (Test-Path $Folder)) {
        Write-Host "エラー: フォルダ '$Folder' が見つかりません。"
        continue
    }

    $ExcelFiles = Get-ChildItem -Path $Folder -Filter "*.xlsx" | Select-Object -ExpandProperty FullName

    foreach ($File in $ExcelFiles) {
        $Workbook = $Excel.Workbooks.Open($File)
        $Sheet = $Workbook.Sheets.Item($SheetName)

        # 指定セルの値取得
        $CellValue = $Sheet.Cells.Item($CellRow, $CellColumn).Text

        # ファイル名を記録
        $LogContent += "フォルダ: $Folder"
        $LogContent += "ファイル名：$File"

        # 空白セル判定
        if ([string]::IsNullOrWhiteSpace($CellValue)) {
            $LogContent += "空白のセル：[$CellRow,$CellColumn]"
        } else {
            $LogContent += "取得した値：$CellValue"
        }

        # 空行を追加してファイルごとの情報を分かりやすくする
        $LogContent += ""

        # 閉じる
        $Workbook.Close($false)
    }
}

# ログファイルに出力
$LogContent | Set-Content $LogFile -Encoding UTF8

# Excelプロセス終了
$Excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)

Write-Host "フォーマットに従い '$LogFile' に出力しました。"
