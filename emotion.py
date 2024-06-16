from fer import FER
import matplotlib.pyplot as plt
import sys
import json
import os
import numpy as np

# 感情のリスト
INITDATA = 0
EMOTIONS = {"angry":INITDATA,"disgust":INITDATA,"fear":INITDATA, "happy":INITDATA, "sad":INITDATA, "surprise":INITDATA,"neutral":INITDATA}

def emotion_cap(pic):
    # 画像の取得
    test_image_one = plt.imread(pic)
    emo_detector = FER(mtcnn=True)
    captured_emotion = emo_detector.detect_emotions(test_image_one)

    # 全ての感情の取得
    for key in EMOTIONS.keys():
        if captured_emotion[0]['emotions'][key]:
            EMOTIONS[key] = captured_emotion[0]['emotions'][key]

    return EMOTIONS

def emotion_show(emoton_dict):
    # 全ての画像の感情値の出力
    print("########################################")
    print(emoton_dict)
    print("########################################")

    myList = emoton_dict['myface2.jpeg'].items()
    myList = sorted(myList)
    x, y = zip(*myList)
    plt.plot(x, y)
    plt.show()
if __name__ == '__main__':

    # 第一引数は設定ファイル
    json_file = sys.argv[1]
    json_file = open(json_file,'r')
    json_data = json.load(json_file)
    
    # 感情の値を格納する辞書型
    emoton_dict = {}

    # 画像を一枚ずつ読み込み感情の値を取得
    for i in json_data["picture"].values():
        pic = i
        emotion_result = emotion_cap(pic)
        filename = os.path.basename(pic)
        emoton_dict[filename] = emotion_result
    
    emotion_show(emoton_dict)



