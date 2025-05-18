
# Excel COMオブジェクトを使用
param (
    [string]$ConfigFile,
    [string]$LogFile
)

# デフォルト値をハッシュテーブルで管理
$DefaultConfig = @{
    ConfigFile   = "config.json"
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
        $CellA1value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[0]
        $CellA2value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[1]   
        $CellA3value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[2]
        $CellB1value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[3]
        $CellB2value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[4]
        $CellB3value=Get-CellValue -Sheet $Sheet -CellAddress $CellArr[5]

        #空行判定
        $Cell1Rownoted=$false
        $Cell2Rownoted=$false
        $Cell3Rownoted=$false
        $CellRownoted=$false

        #空行判定の配列
        if ( -not (Is-EmptyCell -CellValue $CellA1value) -and  -not (Is-EmptyCell -CellValue $CellB1value)) {
            $Cell1Rownoted=$true
        }
        
        if (-not (Is-EmptyCell -CellValue $CellA2value) -and -not (Is-EmptyCell -CellValue $CellB2value )) {
            $Cell2Rownoted=$true
        }
        
        if ( -not (Is-EmptyCell -CellValue $CellA3value) -and -not (Is-EmptyCell -CellValue $CellB3value)) {
            $Cell3Rownoted=$true
        }

        $Rownoted=@($Cell2Rownoted,$Cell3Rownoted)
        if($Cell1Rownoted -eq $false){
            Add-Log -LogFile $LogFile -Message "1行目が空行です:"
        }else{

            for($i = 0;$i -lt $Rownoted.Length;$i++){
                for($j=1;$j -lt $Rownoted.Length;$j++){
                    if(($Rownoted[$i] -eq $false) -and ($Rownoted[$j] -eq $true)){
                        Add-Log -LogFile $LogFile -Message "空行があります:"
                    }
                }
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
# JSONファイルを読み込む
$JsonContent = Get-Content -Path $ConfigFile -Raw -Encoding UTF8| ConvertFrom-Json

# JSONデータから値を取得
$SheetName = $JsonContent.main.SheetName
$CellA1Address = $JsonContent.section1.CellA1.CellA1Address
$CellA1AddressName = $JsonContent.section1.CellA1.CellA1AddressName
$CellA2Address = $JsonContent.section1.CellA2.CellA2Address
$CellA2AddressName = $JsonContent.section1.CellA2.CellA2AddressName
$CellA3Address = $JsonContent.section1.CellA3.CellA3Address
$CellA3AddressName = $JsonContent.section1.CellA3.CellA3AddressName
$CellB1Address = $JsonContent.section1.CellB1.CellB1Address
$CellB1AddressName = $JsonContent.section1.CellB1.CellB1AddressName
$CellB2Address = $JsonContent.section1.CellB2.CellB2Address
$CellB2AddressName = $JsonContent.section1.CellB2.CellB2AddressName
$CellB3Address = $JsonContent.section1.CellB3.CellB3Address
$CellB3AddressName = $JsonContent.section1.CellB3.CellB3AddressName

# 配列の方法２：多次元配列
$CellFirst=@(($CellA1Address,$CellA1AddressName),($CellB1Address,$CellB1AddressName))
$CellSecond=@(($CellA2Address,$CellA2AddressName),($CellB2Address,$CellB2AddressName))
$CellThird=@(($CellA3Address,$CellA3AddressName),($CellB3Address,$CellB3AddressName))
$CellAll=@($CellA1Address,$CellA2Address,$CellA3Address,$CellB1Address,$CellB2Address,$CellB3Address)

# フォルダをユーザーが選択
$TargetFolder = Select-Folder "処理対象フォルダを選択してください"
$TestFolder = Select-Folder "テスト用フォルダを選択してください"

# Excel COMオブジェクトの作成
$Excel = Initialize-Excel

# フォルダの処理
$Folders = @($TargetFolder, $TestFolder)

# 現在の日時をフォーマットしてLogFile名に追加
$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$LogFile = "$($timestamp)_$LogFile"


foreach ($Folder in $Folders) {
    if (Check-Folder -Folder $Folder -LogFile $LogFile) {
        Process-ExcelFile-Test -Folder $Folder -Excel $Excel -SheetName $SheetName -CellArr $CellAll -LogFile $LogFile
    }
}

# Excelプロセス終了
Cleanup-Excel -Excel $Excel


Write-Host "'$LogFile' に出力しました。"


