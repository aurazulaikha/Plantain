import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.efficientnet import preprocess_input
import matplotlib.pyplot as plt

# Load TFLite model dengan interpreter
interpreter = tf.lite.Interpreter(model_path='models/model_efficientnetb2_final2.tflite')
interpreter.allocate_tensors()

# Ambil input & output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Class names sesuai urutan saat training
class_names = ['cordana', 'healthy', 'no_leaf', 'pestalotiopsis', 'sigatoka']

# Cek ukuran input dari model
input_shape = input_details[0]['shape']
img_height, img_width = input_shape[1], input_shape[2]
print(f"Model expects image size: {img_height}x{img_width}")

# Load dan preprocess gambar
img_path = 'test_real/no_leaf.jpg'
img = image.load_img(img_path, target_size=(img_height, img_width))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0).astype(np.float32)

# PREPROCESS SESUAI TRAINING
img_array = preprocess_input(img_array)

# Set input tensor
interpreter.set_tensor(input_details[0]['index'], img_array)

# Jalankan inferensi
interpreter.invoke()

# Ambil hasil output
output_data = interpreter.get_tensor(output_details[0]['index'])
pred_label = class_names[np.argmax(output_data)]
confidence = np.max(output_data) * 100

# Tampilkan hasil prediksi
print(f'Prediksi Gambar: {pred_label} ({confidence:.2f}%)')

# Tampilkan gambar
plt.imshow(image.load_img(img_path))
plt.title(f'Prediksi: {pred_label} ({confidence:.2f}%)')
plt.axis('off')
plt.show()
