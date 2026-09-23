from PIL import Image
import os

train_dir = 'dataset/train'
val_dir   = 'dataset/test'

def force_fix_images(folder):
    print(f"\n🔧 Re-encoding semua gambar di: {folder}")
    total = 0
    fixed = 0
    deleted = 0

    for root, dirs, files in os.walk(folder):
        for file in files:
            path = os.path.join(root, file)

            if not file.lower().endswith(('.png', '.jpg', '.jpeg')):
                continue

            total += 1

            try:
                with Image.open(path) as img:
                    img = img.convert('RGB')

                    # overwrite file jadi JPEG clean
                    img.save(path, 'JPEG', quality=95)

                    fixed += 1

            except Exception as e:
                print(f"[❌ GAGAL - DIHAPUS] {path} | {e}")
                os.remove(path)
                deleted += 1

    print(f"\nTotal gambar: {total}")
    print(f"✔️ Berhasil diperbaiki: {fixed}")
    print(f"🗑️ Dihapus: {deleted}")
    print("✅ Selesai!\n")


# 🔥 JALANKAN
force_fix_images(train_dir)
force_fix_images(val_dir)