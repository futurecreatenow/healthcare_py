# 必要なアセンブリをロード
Add-Type -AssemblyName System.Windows.Forms

# フォームの作成
$form = New-Object System.Windows.Forms.Form
$form.Text = "項目と教科選択"
$form.Width = 600
$form.Height = 300

# ラベルの作成（画面上部に「項目を選んでください」を追加）
$label = New-Object System.Windows.Forms.Label
$label.Text = "項目を選んでください"
$label.Font = New-Object System.Drawing.Font("Arial", 10)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($label)

# チェックボックス1
$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Text = "項目1"
$checkbox1.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($checkbox1)

# チェックボックス2
$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Text = "項目2"
$checkbox2.Location = New-Object System.Drawing.Point(120, 50)
$form.Controls.Add($checkbox2)

# チェックボックス3
$checkbox3 = New-Object System.Windows.Forms.CheckBox
$checkbox3.Text = "項目3"
$checkbox3.Location = New-Object System.Drawing.Point(220, 50)
$form.Controls.Add($checkbox3)

# ラベルの作成（画面上部に「教科を選んでください」を追加）
$subjectlabel = New-Object System.Windows.Forms.Label
$subjectlabel.Text = "教科を選んでください"
$subjectlabel.Font = New-Object System.Drawing.Font("Arial", 10)
$subjectlabel.AutoSize = $true
$subjectlabel.Location = New-Object System.Drawing.Point(20, 80)
$form.Controls.Add($subjectlabel)

# チェックボックス「英語」
$SubjectEnglish = New-Object System.Windows.Forms.CheckBox
$SubjectEnglish.Text = "英語"
$SubjectEnglish.Location = New-Object System.Drawing.Point(20, 100)
$form.Controls.Add($SubjectEnglish)

# チェックボックス「数学」
$SubjectMath = New-Object System.Windows.Forms.CheckBox
$SubjectMath.Text = "数学"
$SubjectMath.Location = New-Object System.Drawing.Point(120, 100)
$form.Controls.Add($SubjectMath)

# チェックボックス「物理」
$SubjectPhysics = New-Object System.Windows.Forms.CheckBox
$SubjectPhysics.Text = "物理"
$SubjectPhysics.Location = New-Object System.Drawing.Point(220, 100)
$form.Controls.Add($SubjectPhysics)

# 選択された「項目」を格納する変数
$selectedItems = [ref] "未登録"
$subjectItems = [ref] "未登録"

# OKボタン
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(150, 200)
$okButton.Add_Click({
    # 選択された項目と教科を取得
    $selectedItems.Value = ""
    $subjectItems.Value = ""
    $selectedItemsCount = 0
    $subjectItemsCount = 0

    if ($checkbox1.Checked) {$selectedItems.Value += "項目1"; $selectedItemsCount++}
    if ($checkbox2.Checked) {$selectedItems.Value += "項目2"; $selectedItemsCount++}
    if ($checkbox3.Checked) {$selectedItems.Value += "項目3"; $selectedItemsCount++}
    if ($SubjectEnglish.Checked) {$subjectItems.Value += "英語"; $subjectItemsCount++}
    if ($SubjectMath.Checked) {$subjectItems.Value += "数学"; $subjectItemsCount++}
    if ($SubjectPhysics.Checked) {$subjectItems.Value += "物理"; $subjectItemsCount++}
    
    
    # 選択された項目と教科を画面に表示
    # [System.Windows.Forms.MessageBox]::Show("選択された項目: $($selectedItems.Value)")
    # [System.Windows.Forms.MessageBox]::Show("選択された教科: $($subjectItems.Value)")

    # 項目と教科が選択されているか確認
    if ([string]::IsNullOrWhiteSpace($selectedItems.Value) -or [string]::IsNullOrWhiteSpace($subjectItems.Value)) {
        [System.Windows.Forms.MessageBox]::Show("項目と教科を最低1つずつ選択してください。", "警告", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # 項目と教科が2つ以上選択されているか確認
    if ($selectedItemsCount -gt 1 -or $subjectItemsCount -gt 1) {
        [System.Windows.Forms.MessageBox]::Show("項目と教科はそれぞれ最大1つ選択してください。", "警告", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # フォームを閉じる
    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
})

$form.Controls.Add($okButton)

# フォームを表示
$result = $form.ShowDialog()

$FinalItems=$($selectedItems.Value)
$Finalsub=$($subjectItems.Value)

# フォーム閉じた後の選択項目を出力
Write-Host "項目番号: $FinalItems"
Write-Host "教科番号: $Finalsub"
