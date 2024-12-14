import tkinter as tk
from tkinter import ttk
import os
import json

# JSONファイルからフォルダパスを読み込む
def load_folders_from_json(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
    return data['folders']

# フォルダを開く関数
def open_folder(path):
    os.startfile(path)

# GUIの設定
root = tk.Tk()
root.title("フォルダオープナー")

# ウィンドウサイズの設定
root.geometry("700x350")
root.configure(background='white')  # 背景色を白に設定

# スタイリングの設定
style = ttk.Style()
style.theme_use("clam")

# カスタムスタイルの作成
style.configure("Custom.TButton",
                font=("Helvetica", 12, "bold"),
                padding=20,
                relief="raised",
                borderwidth=4,
                background="#000000",  # ボタンの背景色を黒に設定
                foreground="#00ff00")  # 文字色を緑に設定

# ボタンをクリックした時のスタイル設定
style.map("Custom.TButton",
          relief=[("pressed", "sunken"), ("!pressed", "raised")],
          background=[("pressed", "#808080"), ("!pressed", "#000000")])

# ラベルのスタイル設定
style.configure("TLabel", font=("Helvetica", 14, "bold"), background='white')

# JSONファイルからフォルダ情報を取得
folders = load_folders_from_json('folders.json')

# ボタンフレームの設定
button_frame = tk.Frame(root, background='white')
button_frame.pack(pady=20)

# 各フォルダに対応するボタンを作成し、一列に3つ配置
for index, folder in enumerate(folders):
    button = ttk.Button(button_frame, text=f"{folder['name']}を開く", command=lambda p=folder['path']: open_folder(p), style="Custom.TButton")
    button.grid(row=index // 3, column=index % 3, padx=10, pady=10, ipadx=20, ipady=20)

# 現在のディレクトリを表示するラベル
label = ttk.Label(root, text="Click a button to open the specified folder")
label.pack(pady=20)

# メインループの開始
root.mainloop()
