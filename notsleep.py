# -*- coding:utf-8 -*-
import tkinter
from tkinter import messagebox
import tkinter.font
import threading
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import cv2
import numpy as np
import time
import mediapipe as mp
from plyer import notification
import sys
import dlib
from imutils import face_utils
from scipy.spatial import distance
from PIL import Image,ImageTk


start_flag = False
quitting_flag = False

# 測定
def measurement():
    global start_flag
    global quitting_flag

    while not quitting_flag:
        while start_flag:
            shoot_interval = shoot_txt.get()
            notice_time = notice_txt.get()
            run_time = run_txt.get()
            if len(shoot_interval) == 0 or len(notice_time) == 0 or len(run_time) == 0:
                messagebox.showerror('入力エラー', '未入力の項目があります')
                start_flag = False
                break

            shoot_interval = int(shoot_interval)
            notice_time = int(notice_time)
            run_time = int(run_time) * 60

            print(f"撮影間隔：{shoot_interval}")
            print(f"眠気の検出回数：{notice_time}")
            print(f"アプリ起動時間：{run_time}")

            #動画の読み込み
            cap = cv2.VideoCapture(0) 
            #顔のモデルの読み込み
            face_cascade = cv2.CascadeClassifier('./setting/haarcascade_frontalface_alt2.xml')
            #顔のランドマークの読み込み
            face_parts_detector = dlib.shape_predictor('./setting/shape_predictor_68_face_landmarks.dat')

           
            def calc_ear(eye):
                A = distance.euclidean(eye[1], eye[5])
                B = distance.euclidean(eye[2], eye[4])
                C = distance.euclidean(eye[0], eye[3])
                eye_ear = (A + B) / (2.0 * C)
                return round(eye_ear, 3)

            def eye_marker(face_mat, position):
                for i, ((x, y)) in enumerate(position):
                    cv2.circle(face_mat, (x, y), 1, (255, 255, 255), -1)
                    cv2.putText(face_mat, str(i), (x + 2, y - 2), cv2.FONT_HERSHEY_SIMPLEX, 0.3, (255, 255, 255), 1)

            count = 0
            bad_count = 0

            while cap.isOpened():
                count += 1
                if start_flag == False:
                        print("ストップが押下されました")
                        break
                
                ret, rgb = cap.read()
                gray = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY)
                faces = face_cascade.detectMultiScale(
                    gray, scaleFactor=1.11, minNeighbors=3, minSize=(100, 100))    

                if len(faces) == 1:
                    print("facesの検出")
                    x, y, w, h = faces[0, :]
                    cv2.rectangle(rgb, (x, y), (x + w, y + h), (255, 0, 0), 2)

                    face_gray = gray[y :(y + h), x :(x + w)]
                    scale = 480 / h
                    face_gray_resized = cv2.resize(face_gray, dsize=None, fx=scale, fy=scale)

                    face = dlib.rectangle(0, 0, face_gray_resized.shape[1], face_gray_resized.shape[0])
                    face_parts = face_parts_detector(face_gray_resized, face)
                    face_parts = face_utils.shape_to_np(face_parts)

                    left_eye = face_parts[42:48]
                    eye_marker(face_gray_resized, left_eye)

                    left_eye_ear = calc_ear(left_eye)

                    right_eye = face_parts[36:42]
                    eye_marker(face_gray_resized, right_eye)

                    right_eye_ear = calc_ear(right_eye)
                    print("left_eye>>>%f" %left_eye_ear)
                    print("right_eye>>>%f" %right_eye_ear)


                    #一定時間停止
                    time.sleep(shoot_interval)
                    print("count >>> %d" % count)

                    if count > 3:
                        if (left_eye_ear + right_eye_ear) < 0.55:
                                bad_count += 1
                                print("bad count>>>%d" % bad_count)
                                print("眠そうな目を検出")

                                #デクストップ通知する
                                if bad_count == notice_time:
                                    notification.notify(
                                                title="眠気感知アプリ",
                                                message="眠くなっています",
                                                timeout=10
                                            )
                    
                                    bad_count = 0
                    #撮影の終了
                    if count == (run_time / shoot_interval):
                        print("時間になったので撮影終了します")
                        break

                    
            print("撮影終了します")
            cap.release()



# スタートボタンが押された時の処理
def start_button_click(event):
    global start_flag
    start_flag = True

# ストップボタンが押された時の処理
def stop_button_click(event):
    global start_flag
    start_flag = False


# 終了ボタンが押された時の処理
def quit_app():
    global quitting_flag
    global app
    global thread1

    quitting_flag = True

    # thread1終了まで待つ
    thread1.join()
    app.destroy()

#ページ遷移の関数
def changePage(page):
        page.tkraise()

'''以下からメイン処理'''

# メインウィンドウを作成
app = tkinter.Tk()
app.title("健康増進")
app.geometry("500x500")

# # この処理をコメントアウトすると配置がズレる
app.grid_rowconfigure(0, weight=1)
app.grid_columnconfigure(0, weight=1)

# メインページフレーム作成
main_frame = tkinter.Frame()
main_frame.grid(row=0, column=0, sticky="nsew")
main_frame.configure(bg="pink")

# タイトルラベル作成
titleLabel = tkinter.Label(main_frame, text="Main Page", font=('Helvetica', '35'),bg="pink",fg="black")
titleLabel.grid(row=0, column=0,columnspan=2, sticky=tkinter.NSEW)

# フレーム1:(姿勢感知)に移動するボタン
changePageButton = tkinter.Button(main_frame, text="姿勢維持", command=lambda : changePage(frame1))
changePageButton.grid(row=1, column=0)

# フレーム2:(眠気感知)に移動するボタン
changePageButton_2 = tkinter.Button(main_frame, text="眠気感知", command=lambda : changePage(frame2))
changePageButton_2.grid(row=1, column=1)

'''姿勢感知フレーム'''
# フレーム1:(姿勢感知)作成
frame1 = tkinter.Frame()
frame1.grid(row=0, column=0, sticky="nsew")
# フレーム1:(姿勢感知)作成
titleLabel = tkinter.Label(frame1, text="姿勢維持", font=('Helvetica', '35'))
titleLabel.grid(row=1, column=0)
# フレーム1:(姿勢感知)からmainフレームに戻るボタン
back_button = tkinter.Button(frame1, text="Go to main page", command=lambda : changePage(main_frame))
back_button.grid(row=2, column=0)


'''眠気感知フレーム'''
# フレーム2:(眠気感知)作成
frame2 = tkinter.Frame()
frame2.grid(row=0, column=0, sticky="nsew")
frame2.configure(bg="#00ffff")

# フレーム2:(眠気感知)タイトルラベル作成
titleLabel = tkinter.Label(frame2, text="眠気感知", font=('Helvetica', '35'),bg ="#00ffff",fg ="black")
titleLabel.grid(row=1, column=0)

message_shoot = tkinter.Message(frame2,text="撮影間隔(秒)",width=200)
message_shoot.grid(row=2, column=0)

shoot_txt =tkinter.Entry(frame2) 
shoot_txt.grid(row=2, column=1)

message_notice = tkinter.Message(frame2,text="眠気の検出回数(回)",width=200)
message_notice.grid(row=3, column=0)

notice_txt = tkinter.Entry(frame2)
notice_txt.grid(row=3, column=1)

message_run = tkinter.Message(frame2,text="測定時間(分)",width=200)
message_run.grid(row=4, column=0)

run_txt = tkinter.Entry(frame2)
run_txt.grid(row=4, column=1)

#スタートボタン
start_img = Image.open("./img/start.jpg")
start_img = start_img.resize((100, 100))
start_img = ImageTk.PhotoImage(start_img)
start_button = tkinter.Button(frame2,image=start_img)
start_button.grid(row=5, column=0)

#ストップボタン
stop_img = Image.open("./img/stop.jpg")
stop_img = stop_img.resize((100, 100))
stop_img = ImageTk.PhotoImage(stop_img)
stop_button = tkinter.Button(frame2,image=stop_img)
stop_button.grid(row=5, column=1)

# フレーム2:(眠気感知)からmainフレームに戻るボタン
back_button = tkinter.Button(frame2, text="Go to main page", command=lambda : changePage(main_frame))
back_button.grid(row=6, column=1)

# イベント処理の設定
start_button.bind("<ButtonPress>", start_button_click)
stop_button.bind("<ButtonPress>", stop_button_click)
app.protocol("WM_DELETE_WINDOW", quit_app)

#　スレッドの生成と開始
thread1 = threading.Thread(target=measurement)
thread1.start()
#main_frameを一番上に表示
main_frame.tkraise()


# メインループ
app.mainloop()
