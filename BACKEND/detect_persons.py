import cv2
import numpy as np
import time

prototxt_path = r"C:\Users\VICTUS\Downloads\deploy (2).prototxt"
model_path = r"C:\Users\VICTUS\Downloads\mobilenet_iter_73000 (10).caffemodel"

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

                # Draw bounding box around the person
                box = detections[0, 0, i, 3:7] * np.array([w, h, w, h])
                (startX, startY, endX, endY) = box.astype("int")
                cv2.rectangle(frame, (startX, startY), (endX, endY), (0, 255, 0), 2)

                # Add label for the confidence level
                label = f"Person: {confidence:.2f}"
                cv2.putText(frame, label, (startX, startY - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

    person_count_per_frame.append(person_count)
    frame_count += 1

    # Display person count on the frame
    cv2.putText(frame, f'Person count: {person_count}', (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
    cv2.imshow("Frame", frame)

    # Exit on pressing "Esc" or "q" key
    if cv2.waitKey(1) & 0xFF == 27 or cv2.waitKey(1) & 0xFF == ord('q'):
        break

    # Exit after 10 seconds
    if time.time() - start_time > 1000:  # Changed to 10 seconds from 1000 for practical use
        # Calculate average person count over the frames
        average_person_count = sum(person_count_per_frame) / frame_count
        print(f'Average persons detected in 10 seconds: {average_person_count:.2f}')
        break

cap.release()
cv2.destroyAllWindows()
