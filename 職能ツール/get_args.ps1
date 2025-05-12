# Excel COMオブジェクトを使用
param (
    [string]$ConfigFile,
    [string]$LogFile
)

# デフォルト値をハッシュテーブルで管理
$DefaultConfig = @{
    ConfigFile   = "config.ini"
    LogFile      = "result.txt"
}

# デフォルト値を適用
foreach ($key in $DefaultConfig.Keys) {
    if (-Not (Get-Variable -Name $key -ErrorAction SilentlyContinue).Value) {
        Set-Variable -Name $key -Value $DefaultConfig[$key]
    }
}

################################################################
### 関数定義
################################################################
# LogFileに追記する関数
function Add-Log {
    param ([string]$LogFile, [string]$Message)
    $Message | Add-Content -Path $LogFile -Encoding UTF8
}

# 第一引数のチェックを行う関数 config.iniの読み込み確認
function Check-FirstArgument {
    param ([string]$ConfigFile)
    if (-Not $ConfigFile) {
        Write-Host "エラー: 第一引数に 'config.ini' を指定してください。"
        exit 1
    }
}

# config.ini の読み込みを行う関数（セクション対応）
function Load-Config {
    param ([string]$ConfigFile)
    if (-Not (Test-Path $ConfigFile)) {
        Write-Host "エラー: ファイル '$ConfigFile' が見つかりません。"
        exit 1
    }

    $ConfigData = @{}
    $CurrentSection = ""

    foreach ($line in Get-Content $ConfigFile -Encoding UTF8) {
        $line = $line.Trim()
        if ($line -match '^\[(.*?)\]$') {
            $CurrentSection = $matches[1]
            $ConfigData[$CurrentSection] = @{}
        } elseif ($line -match '^(.*?)=(.*?)$' -and $CurrentSection) {
            $ConfigData[$CurrentSection][$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    return $ConfigData
}


# フォルダの存在確認を行う関数
function Check-Folder {
    param ([string]$Folder, [string]$LogFile)
    if (-Not (Test-Path $Folder)) {
        Add-Log -LogFile $LogFile -Message "エラー: フォルダ '$Folder' が見つかりません。"
        return $false
    }
    return $true
}

# フォルダ選択ダイアログを表示する関数
function Select-Folder($Description) {
    Add-Type -AssemblyName System.Windows.Forms
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = $Description
    
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderDialog.SelectedPath
    } else {
        Write-Host "フォルダ選択がキャンセルされました。"
        exit 1
    }
}


# Excel COMオブジェクトを初期化する関数
function Initialize-Excel {
    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Excel.DisplayAlerts = $false
    return $Excel
}

# Excel COMオブジェクトをクリーンアップする関数
function Cleanup-Excel {
    param ([object]$Excel)
    $Excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
}

# 指定セルの値を取得する関数
function Get-CellValue {
    param ([object]$Sheet, [string]$CellAddress)
    return $Sheet.Range($CellAddress).Text
}

# 空白セル判定を行う関数
function Is-EmptyCell {
    param ([string]$CellValue)
    return [string]::IsNullOrWhiteSpace($CellValue)
}

# Excelファイルを処理する関数
function Process-ExcelFile-Test {
    param ([string]$Folder, [object]$Excel, [string]$SheetName, [Array]$CellArr, [string]$LogFile)

    Add-Log -LogFile $LogFile -Message "フォルダ: $Folder"
    $ExcelFiles = Get-ChildItem -Path $Folder -Filter "*.xlsx" | Select-Object -ExpandProperty FullName

    foreach ($File in $ExcelFiles) {
        Add-Log -LogFile $LogFile -Message "ファイル名：$File"
        $Workbook = $Excel.Workbooks.Open($File)
        $Sheet = $Workbook.Sheets.Item($SheetName)

        foreach ($Celldata in $CellArr) {
            $Cell = $Celldata[0]
            Add-Log -LogFile $LogFile -Message "セル座標：$Cell"
            $CellValue = Get-CellValue -Sheet $Sheet -CellAddress $Celldata[0]

            if (Is-EmptyCell -CellValue $CellValue) {
                Add-Log -LogFile $LogFile -Message "空白"
            }
        }

        Add-Log -LogFile $LogFile -Message ""
        $Workbook.Close($false)
    }
}

################################################################
### 実処理
################################################################
# 設定値の取得
$ConfigData = Load-Config -ConfigFile $ConfigFile
$SheetName = $ConfigData["main"]["SheetName"]
$CellAddress = $ConfigData["section1"]["CellAddress"]
$CellAddressName = $ConfigData["section1"]["CellAddressName"]
$CellAddress1 = $ConfigData["section1"]["CellAddress1"]
$CellAddress1Name = $ConfigData["section1"]["CellAddress1Name"]

# 配列の方法１：1次元配列
$AddressArr=$CellAddress,$CellAddress1
# foreach ($Address in $AddressArr) {
# 	Write-Host $Address
# }

# 配列の方法２：多次元配列
$AddressMulArr=@(($CellAddress,$CellAddressName),($CellAddress1,$CellAddress1Name))
# foreach($Address in $AddressMulArr){
#     # ペアを出力する 例)B3 CellAddress
#     Write-Host $Address
#     # 最初のインデックスを出力する
#     Write-Host $Address[0]
#     # 2番目のインデックスを出力する
#     Write-Host $Address[1]
# }


# フォルダをユーザーが選択
$TargetFolder = Select-Folder "処理対象フォルダを選択してください"
$TestFolder = Select-Folder "テスト用フォルダを選択してください"

# Excel COMオブジェクトの作成
$Excel = Initialize-Excel

# フォルダの処理
$Folders = @($TargetFolder, $TestFolder)



foreach ($Folder in $Folders) {
    if (Check-Folder -Folder $Folder -LogFile $LogFile) {
        Process-ExcelFile-Test -Folder $Folder -Excel $Excel -SheetName $SheetName -CellArr $AddressMulArr -LogFile $LogFile
    }
}

# Excelプロセス終了
Cleanup-Excel -Excel $Excel

Write-Host "'$LogFile' に出力しました。"


