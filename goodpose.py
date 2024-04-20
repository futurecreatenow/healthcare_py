import tkinter
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import cv2
import numpy as np
import time
import mediapipe as mp
from plyer import notification

class Application (tkinter.Frame):
    def __init__(self,root=None):
        super().__init__(root,width=800,height=700,borderwidth=1,relief='groove')
        self.root = root
        self.pack()
        self.pack_propagate(0)
        self.create_widgets()
        self.shoot_interval = 30
        self.notice_time = 3

    def create_widgets(self):
        run_btn = tkinter.Button(self,text="実行",command=self.submit)
        run_btn.pack(side="top")


        message_shoot = tkinter.Message(self,text="撮影間隔(秒)",width=200)
        message_shoot.pack()

        self.shoot =tkinter.Entry(self) 
        self.shoot.pack()
        
        message_notice = tkinter.Message(self,text="悪い姿勢の検出回数(回)",width=200)
        message_notice.pack()
        
        self.notice = tkinter.Entry(self)
        self.notice.pack()

    def submit(self):
        print("実行ボタンが押下されました")
        shoot_interval = self.shoot.get()
        self.shoot_interval = int(shoot_interval)
        print(self.shoot_interval)

        notice_time = self.notice.get()
        self.notice_time = int(notice_time)
        print(self.notice_time)

        self.fig, self.ax = plt.subplots(figsize=(12,4))
        self.canvas = FigureCanvasTkAgg(self.fig,master=self)
        self.canvas.get_tk_widget().pack()
        self.show()
    
    #部位の座標の取得
    def findPoint(self,landmark_num):
        parts_array = {"x":0, "y":0, "z":0,"v":0}
        parts_array["x"] = self.results.pose_landmarks.landmark[landmark_num].x
        parts_array["y"] = self.results.pose_landmarks.landmark[landmark_num].y
        body_array = [0,0]
        body_array[0] = int(parts_array["x"] * self.width + 0.5)
        body_array[1] = int(parts_array["y"] * self.height + 0.5)
        return body_array


    def show(self):
        #初期設定
        mp_drawing = mp.solutions.drawing_utils
        mp_drawing_styles = mp.solutions.drawing_styles
        mp_pose = mp.solutions.pose


        cap = cv2.VideoCapture(0)
        count = 0
        bad_count = 0
        nose_y = []
        nose_y_all = []

        with mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5) as pose:
            while cap.isOpened():
                count += 1
                print(count)
                success, image = cap.read()
                if not success:
                    print("Ignoring empty camera frame.")
                    continue
                image.flags.writeable = False
                image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
                self.results = pose.process(image)

                image.flags.writeable = True
                image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
                self.height,self.width = image.shape[0],image.shape[1]
                mp_drawing.draw_landmarks(
                    image,
                    self.results.pose_landmarks,
                    mp_pose.POSE_CONNECTIONS,
                    landmark_drawing_spec=mp_drawing_styles.get_default_pose_landmarks_style())


                cv2.imshow('MediaPipe Pose', cv2.flip(image, 1))

                #鼻の座標の取得
                nose = self.findPoint(0)
                if len(nose) > 0:
                    # nose_x.append(nose[0])
                    nose_y.append(nose[1])
                    nose_y_all.append(nose[1])

                print(f"鼻のy座標:{nose_y}")

                #一定時間停止
                time.sleep(self.shoot_interval)

                #鼻のy座標の3回の平均
                thre = [i for i in nose_y[:3]]
                thre = np.mean(thre)
                print(thre)


                if count > 3:
                # 閾値を超える鼻の座標
                    if nose[1] > thre:
                        bad_count += 1
                        print("bad posture")

                        #閾値を3回超えたらデクストップ通知する
                        if bad_count == self.notice_time:
                            notification.notify(
                                        title="腰の負担を減らそう",
                                        message="姿勢が悪くなっています",
                                        timeout=10
                                    )
                            bad_count = 0

                            #鼻の座標をクリアする
                            nose_y.clear()
                

                #撮影の終了
                if len(nose_y_all) == 10:
                    print("要素数が基準を満たしました")
                    print(f"nose_yの要素数：{len(nose_y)},nose_y_allの要素数：{len(nose_y_all)}")
                    break
                
                # 停止 スクリプトの終了
                key = cv2.waitKey(100)
                if key == ord('q'): 
                    print("qが押下されました")
                    break
            
        cap.release()

        x_date = [self.shoot_interval * i for i in range(len(nose_y_all))]

        self.ax.plot(x_date,nose_y_all)
        self.ax.grid()
        self.canvas.draw()


root = tkinter.Tk()
root.title("health")
root.geometry("1000x1000")
app = Application(root=root)
app.mainloop()