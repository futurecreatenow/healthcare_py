from fer import FER
import matplotlib.pyplot as plt

# 画像の取得
test_image_one = plt.imread("myface.jpeg")
emo_detector = FER(mtcnn=True)
captured_emotion = emo_detector.detect_emotions(test_image_one)

# 全ての感情の取得
INITDATA = 0
EMOTIONS = {"angry":INITDATA,"disgust":INITDATA,"fear":INITDATA, "happy":INITDATA, "sad":INITDATA, "surprise":INITDATA,"neutral":INITDATA}
for key in EMOTIONS.keys():
    if captured_emotion[0]['emotions'][key]:
        EMOTIONS[key] = captured_emotion[0]['emotions'][key]


# 全ての感情を抽出
print(EMOTIONS)

# 最も高い感情を抽出
dominant_emotion = max(EMOTIONS.items(), key=lambda x: x[1])
print(dominant_emotion)

# 感情をグラフ化する
figure_diagram = EMOTIONS.items()
figure_diagram = sorted(figure_diagram)
x, y = zip(*figure_diagram)

plt.plot(x, y)
plt.show()
