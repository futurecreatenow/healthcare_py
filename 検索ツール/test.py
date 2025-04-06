import tkinter as tk
from tkinter import filedialog
import os
import webbrowser

def select_folder():
    global folder_selected
    folder_selected = filedialog.askdirectory()
    if folder_selected:
        listbox.delete(0, tk.END)
        file_paths.clear()
        for file_name in os.listdir(folder_selected):
            full_path = os.path.join(folder_selected, file_name)
            file_paths.append(full_path)
            listbox.insert(tk.END, full_path)

def search_files():
    query = entry_search.get().lower()
    listbox.delete(0, tk.END)
    for file_path in file_paths:
        if query in os.path.basename(file_path).lower():
            listbox.insert(tk.END, file_path)

def open_link(event):
    selected_item = listbox.get(listbox.curselection())
    webbrowser.open(selected_item)  # ファイル名がURLの場合は開く

root = tk.Tk()
root.title("フォルダ内ファイル検索")

frame = tk.Frame(root)
frame.pack(padx=10, pady=10)

btn_select = tk.Button(frame, text="フォルダを選択", command=select_folder)
btn_select.pack()

entry_search = tk.Entry(frame, width=50)
entry_search.pack()
entry_search.bind("<KeyRelease>", lambda event: search_files())  # 入力ごとに検索

listbox = tk.Listbox(frame, width=70, height=20)
listbox.pack()
listbox.bind("<Double-Button-1>", open_link)

file_paths = []  # フォルダ内のファイルリストを格納

root.mainloop()
