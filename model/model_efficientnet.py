import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pickle
import os
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.utils import class_weight

# Path Dataset
train_dir = 'dataset/train'
test_dir = 'dataset/test'

# Load Dataset
IMG_SIZE = (260, 260)  # Ukuran standar EfficientNetB2
BATCH_SIZE = 32

train_ds = tf.keras.preprocessing.image_dataset_from_directory(
    train_dir, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='int'
)

val_ds = tf.keras.preprocessing.image_dataset_from_directory(
    test_dir, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='int'
)

class_names = train_ds.class_names
print("Class Detected:", class_names)

# Data Augmentation
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
])

# Normalization (EfficientNet sudah punya preprocessing built-in)
preprocess_input = tf.keras.applications.efficientnet.preprocess_input
AUTOTUNE = tf.data.AUTOTUNE

train_ds = train_ds.map(lambda x, y: (preprocess_input(data_augmentation(x)), y))
train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)

val_ds = val_ds.map(lambda x, y: (preprocess_input(x), y))
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# Class Weight Handling
all_train_labels = []
for _, labels in train_ds.unbatch():
    all_train_labels.append(labels.numpy())

class_weights = class_weight.compute_class_weight(
    class_weight='balanced',
    classes=np.unique(all_train_labels),
    y=all_train_labels
)
class_weights = dict(enumerate(class_weights))
print("Class Weights:", class_weights)

# Model - Transfer Learning EfficientNetB2
from tensorflow.keras.applications import EfficientNetB2

base_model = EfficientNetB2(
    input_shape=(260, 260, 3), include_top=False, weights='imagenet'
)
base_model.trainable = False

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.BatchNormalization(),
    layers.Dense(256, activation='relu'),
    layers.Dropout(0.4),
    layers.Dense(len(class_names), activation='softmax')
])

# Summary
model.summary()

# Save Summary
os.makedirs('models', exist_ok=True)
with open('models/model_summary.txt', 'w', encoding='utf-8') as f:
    model.summary(print_fn=lambda x: f.write(x + '\n'))

# Compile
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Training
EPOCHS = 30
history = model.fit(
    train_ds, validation_data=val_ds, epochs=EPOCHS, class_weight=class_weights
)

# Save model & history
model.save('models/pisang_detector_efficientnetb2.keras')
with open('models/history_effiecient.pkl', 'wb') as f:
    pickle.dump(history.history, f)

# Plot Performance
def plot_performance(history_dict):
    plt.figure(figsize=(12, 4))
    plt.subplot(1, 2, 1)
    plt.plot(history_dict['accuracy'], label='Train Accuracy')
    plt.plot(history_dict['val_accuracy'], label='Val Accuracy')
    plt.title('Accuracy')
    plt.legend()

    plt.subplot(1, 2, 2)
    plt.plot(history_dict['loss'], label='Train Loss')
    plt.plot(history_dict['val_loss'], label='Val Loss')
    plt.title('Loss')
    plt.legend()

    plt.tight_layout()
    plt.show()

# Confusion Matrix & Evaluation
val_ds_raw = tf.keras.preprocessing.image_dataset_from_directory(
    test_dir, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='int'
)
val_ds_raw = val_ds_raw.map(lambda x, y: (preprocess_input(x), y))

val_images, val_labels = [], []
for images, labels in val_ds_raw:
    val_images.append(images)
    val_labels.append(labels)

val_images = tf.concat(val_images, axis=0)
val_labels = tf.concat(val_labels, axis=0)

pred_probs = model.predict(val_images)
pred_labels = tf.argmax(pred_probs, axis=1)

cm = confusion_matrix(val_labels, pred_labels)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=class_names, yticklabels=class_names)
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.tight_layout()
plt.show()

print("\n=== Laporan Klasifikasi ===")
print(classification_report(val_labels, pred_labels, target_names=class_names))

# Final Accuracy
final_train_acc = history.history['accuracy'][-1]
final_val_acc = history.history['val_accuracy'][-1] 
print(f"\n Akurasi akhir (Training): {final_train_acc*100:.2f}%")
print(f" Akurasi akhir (Validasi): {final_val_acc*100:.2f}%")

# Plot accuracy & loss
plot_performance(history.history)
