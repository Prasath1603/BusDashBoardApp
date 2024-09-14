from flask import Flask, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import time

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Path to your MobileNet SSD model files
prototxt_path = r"C:\Users\VICTUS\Downloads\deploy (2).prototxt"
model_path = r"C:\Users\VICTUS\Downloads\mobilenet_iter_73000 (10).caffemodel"

# Function to count persons
def count_persons():
    net = cv2.dnn.readNetFromCaffe(prototxt_path, model_path)
    cap = cv2.VideoCapture(0)

    start_time = time.time()
    frame_count = 0
    person_count_per_frame = []

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        (h, w) = frame.shape[:2]
        blob = cv2.dnn.blobFromImage(cv2.resize(frame, (300, 300)), 0.007843, (300, 300), 127.5)

        net.setInput(blob)
        detections = net.forward()

        person_count = 0  # Initialize person count for the current frame

        for i in range(detections.shape[2]):
            confidence = detections[0, 0, i, 2]

            if confidence > 0.5:
                class_id = int(detections[0, 0, i, 1])
                if class_id == 15:  # Class ID 15 is for 'Person' in MobileNet SSD
                    person_count += 1  # Increment for each person detected

        person_count_per_frame.append(person_count)
        frame_count += 1

        # Exit after 10 seconds
        if time.time() - start_time > 5:
            break

    cap.release()
    total_person_count = sum(person_count_per_frame)
    average_person_count = total_person_count / frame_count if frame_count > 0 else 0
    return int(average_person_count)

@app.route('/get_person_count', methods=['GET'])
def get_person_count():
    person_count = count_persons()
    return jsonify({'person_count': person_count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
