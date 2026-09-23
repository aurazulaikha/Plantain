import tensorflow as tf
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.applications import EfficientNetB2
from tensorflow.keras.optimizers import Adam
import numpy as np
from sklearn.utils import class_weight
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
import os, pickle

# DATASET

train_dir = 'dataset/train'
val_dir   = 'dataset/test'

IMG_SIZE = (260, 260)
BATCH_SIZE = 32
AUTOTUNE = tf.data.AUTOTUNE

train_ds_raw = tf.keras.preprocessing.image_dataset_from_directory(
    train_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='int'
)

val_ds_raw = tf.keras.preprocessing.image_dataset_from_directory(
    val_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode='int'
)

class_names = train_ds_raw.class_names
num_classes = len(class_names)
print("Classes Detected:", class_names)

# DATA AUGMENTATION 

data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.15),
    layers.RandomZoom(0.15),
    layers.RandomContrast(0.2),
])

preprocess_input = tf.keras.applications.efficientnet.preprocess_input

train_ds = train_ds_raw.map(
    lambda x, y: (preprocess_input(data_augmentation(x)), y),
    num_parallel_calls=AUTOTUNE
)
train_ds = train_ds.shuffle(1000).prefetch(AUTOTUNE)

val_ds = val_ds_raw.map(
    lambda x, y: (preprocess_input(x), y),
    num_parallel_calls=AUTOTUNE
)
val_ds = val_ds.prefetch(AUTOTUNE)

# CLASS WEIGHT 

labels = []
for _, y in train_ds_raw.unbatch():
    labels.append(y.numpy())

class_weights = class_weight.compute_class_weight(
    class_weight='balanced',
    classes=np.unique(labels),
    y=labels
)
class_weights = dict(enumerate(class_weights))
print("Class Weights:", class_weights)

# MODEL

base_model = EfficientNetB2(
    input_shape=(260, 260, 3),
    include_top=False,
    weights='imagenet'
)

# Fine-tuning: bekukan layer awal
base_model.trainable = True
for layer in base_model.layers[:-30]:
    layer.trainable = False

model = models.Sequential([
    base_model,                              # CNN pretrained
    layers.GlobalAveragePooling2D(),         # CNN feature reduction
    layers.BatchNormalization(),

    layers.Dense(
        256,
        activation='relu',
        kernel_regularizer=regularizers.l2(0.001)  # L2 Regularization
    ),
    layers.Dropout(0.35),                    # Dropout anti overfitting

    layers.Dense(num_classes, activation='softmax')
])

# COMPILATION (HYPERPARAMETER MANUAL)

model.compile(
    optimizer=Adam(learning_rate=1e-5),     # learning rate (fine-tuning)
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

model.summary()

# CALLBACK 

early_stop = tf.keras.callbacks.EarlyStopping(
    monitor='val_loss',
    patience=3,                
    restore_best_weights=True
)

# TRAINING

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=30,                  
    callbacks=[early_stop],
    class_weight=class_weights
)

# SAVE MODEL & HISTORY

os.makedirs('models', exist_ok=True)

model.save('models/model_efficientnetb2_final3.keras')

with open('models/history_final3.pkl', 'wb') as f:
    pickle.dump(history.history, f)

# PLOT AKURASI & LOSS

def plot_history(hist):
    plt.figure(figsize=(12, 4))

    plt.subplot(1, 2, 1)
    plt.plot(hist['accuracy'], label='Training Accuracy')
    plt.plot(hist['val_accuracy'], label='Validation Accuracy')
    plt.title('Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.legend()

    plt.subplot(1, 2, 2)
    plt.plot(hist['loss'], label='Training Loss')
    plt.plot(hist['val_loss'], label='Validation Loss')
    plt.title('Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.legend()

    plt.tight_layout()
    plt.show()

plot_history(history.history)

# EVALUASI

val_images, val_labels = [], []
for img, lbl in val_ds_raw:
    val_images.append(preprocess_input(img))
    val_labels.append(lbl)

val_images = tf.concat(val_images, axis=0)
val_labels = tf.concat(val_labels, axis=0)

pred_probs = model.predict(val_images)
pred_labels = tf.argmax(pred_probs, axis=1)


# LAPORAN KLASIFIKASI

print("\n=== CLASSIFICATION REPORT ===")
print(classification_report(val_labels, pred_labels, target_names=class_names))

# CONFUSION MATRIX

cm = confusion_matrix(val_labels, pred_labels)
plt.figure(figsize=(8, 6))
sns.heatmap(
    cm,
    annot=True,
    fmt='d',
    cmap='Blues',
    xticklabels=class_names,
    yticklabels=class_names
)
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.title("Confusion Matrix")
plt.tight_layout()
plt.show()
