import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.applications import EfficientNetB2
from tensorflow.keras.optimizers import Adam
import keras_tuner as kt
import numpy as np
from sklearn.utils import class_weight
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
import os
import pickle

# ================= Dataset =================
train_dir = 'dataset/train'
test_dir = 'dataset/test'
IMG_SIZE = (260, 260)
BATCH_SIZE = 32
AUTOTUNE = tf.data.AUTOTUNE

train_ds_raw = tf.keras.preprocessing.image_dataset_from_directory(
    train_dir, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='int'
)

val_ds_raw = tf.keras.preprocessing.image_dataset_from_directory(
    test_dir, image_size=IMG_SIZE, batch_size=BATCH_SIZE, label_mode='int'
)

# Simpan class names
class_names = train_ds_raw.class_names
num_classes = len(class_names)
print("Class Detected:", class_names)

# ================= Data Augmentation & Preprocessing =================
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
])
preprocess_input = tf.keras.applications.efficientnet.preprocess_input

train_ds = train_ds_raw.map(lambda x, y: (preprocess_input(data_augmentation(x)), y))
train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)

val_ds = val_ds_raw.map(lambda x, y: (preprocess_input(x), y))
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# ================= Class Weights =================
all_train_labels = []
for _, labels in train_ds_raw.unbatch():
    all_train_labels.append(labels.numpy())

class_weights = class_weight.compute_class_weight(
    class_weight='balanced',
    classes=np.unique(all_train_labels),
    y=all_train_labels
)
class_weights = dict(enumerate(class_weights))
print("Class Weights:", class_weights)

# ================= Hyperparameter Tuning =================
def model_builder(hp):
    base_model = EfficientNetB2(input_shape=(260, 260, 3), include_top=False, weights='imagenet')
    base_model.trainable = False

    model = models.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.BatchNormalization()
    ])

    # Dense units
    hp_units = hp.Int('units', min_value=128, max_value=512, step=64)
    model.add(layers.Dense(units=hp_units, activation='relu'))

    # Dropout
    hp_dropout = hp.Float('dropout', min_value=0.2, max_value=0.5, step=0.1)
    model.add(layers.Dropout(rate=hp_dropout))

    model.add(layers.Dense(num_classes, activation='softmax'))

    # Learning rate
    hp_learning_rate = hp.Choice('learning_rate', values=[1e-2, 1e-3, 1e-4])
    model.compile(
        optimizer=Adam(learning_rate=hp_learning_rate),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model

# ================= Tuner =================
tuner = kt.RandomSearch(
    model_builder,
    objective='val_accuracy',
    max_trials=5, 
    executions_per_trial=1,
    directory='kt_tuner',
    project_name='efficientnetb2_tuning'
)

stop_early_search = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=2, restore_best_weights=True)

# Jalankan hyperparameter search (singkat)
tuner.search(train_ds, validation_data=val_ds, epochs=3, class_weight=class_weights, callbacks=[stop_early_search])

# Ambil model terbaik
best_hps = tuner.get_best_hyperparameters(num_trials=1)[0]
print(f"Best hyperparameters: Units={best_hps.get('units')}, Dropout={best_hps.get('dropout')}, Learning Rate={best_hps.get('learning_rate')}")

# Build model final
model = tuner.hypermodel.build(best_hps)

# ================= Training Final =================
stop_early_final = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=3, restore_best_weights=True)

history = model.fit(
    train_ds, validation_data=val_ds, epochs=15,  
    class_weight=class_weights,
    callbacks=[stop_early_final]
)

# ================= Save Model & History =================
os.makedirs('models', exist_ok=True)
model.save('models/pisang_detector_effihype30.keras')
with open('models/history_tuned30.pkl', 'wb') as f:
    pickle.dump(history.history, f)

# ================= Plot Performance =================
def plot_performance(history_dict):
    plt.figure(figsize=(12,4))
    plt.subplot(1,2,1)
    plt.plot(history_dict['accuracy'], label='Train Accuracy')
    plt.plot(history_dict['val_accuracy'], label='Val Accuracy')
    plt.title('Accuracy')
    plt.legend()

    plt.subplot(1,2,2)
    plt.plot(history_dict['loss'], label='Train Loss')
    plt.plot(history_dict['val_loss'], label='Val Loss')
    plt.title('Loss')
    plt.legend()
    plt.tight_layout()
    plt.show()

plot_performance(history.history)

# ================= Confusion Matrix & Classification Report =================
val_images, val_labels = [], []
for images, labels in val_ds_raw.map(lambda x, y: (preprocess_input(x), y)):
    val_images.append(images)
    val_labels.append(labels)

val_images = tf.concat(val_images, axis=0)
val_labels = tf.concat(val_labels, axis=0)

pred_probs = model.predict(val_images)
pred_labels = tf.argmax(pred_probs, axis=1)

cm = confusion_matrix(val_labels, pred_labels)
plt.figure(figsize=(8,6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=class_names, yticklabels=class_names)
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.tight_layout()
plt.show()

print("\n=== Laporan Klasifikasi ===")
print(classification_report(val_labels, pred_labels, target_names=class_names))

final_train_acc = history.history['accuracy'][-1]
final_val_acc = history.history['val_accuracy'][-1] 
print(f"\nAkurasi akhir (Training): {final_train_acc*100:.2f}%")
print(f"Akurasi akhir (Validasi): {final_val_acc*100:.2f}%")