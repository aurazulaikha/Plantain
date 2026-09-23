from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_mysqldb import MySQL
from functools import wraps
import jwt, bcrypt, os
from datetime import datetime, timedelta
import numpy as np
import cv2
from tensorflow.lite.python.interpreter import Interpreter
from werkzeug.utils import secure_filename 
import time

# CONFIG
app = Flask(__name__)
CORS(app)

app.config['MYSQL_HOST'] = "localhost"
app.config['MYSQL_USER'] = "root"
app.config['MYSQL_PASSWORD'] = ""
app.config['MYSQL_DB'] = "pisang_deteksi"
app.config['MYSQL_PORT'] = 3306

app.config['SECRET_KEY'] = 'Bismillah_bisa'

mysql = MySQL(app)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")
UPLOAD_USERS = os.path.join(UPLOAD_FOLDER, "users")
UPLOAD_PENYAKIT = os.path.join(UPLOAD_FOLDER, "penyakit")
UPLOAD_HISTORI = os.path.join(UPLOAD_FOLDER, "histori")

os.makedirs(UPLOAD_USERS, exist_ok=True)
os.makedirs(UPLOAD_PENYAKIT, exist_ok=True)
os.makedirs(UPLOAD_HISTORI, exist_ok=True)

ALLOWED_EXT = {'png', 'jpg', 'jpeg'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.',1)[1].lower() in ALLOWED_EXT


# HELPERS / AUTH

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.headers.get('Authorization')
        if not auth:
            return jsonify({'message':'Token missing'}), 401
        token = auth.replace('Bearer ', '')
        try:
            payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
            user_id = payload.get('user_id')
        except jwt.ExpiredSignatureError:
            return jsonify({'message':'Token expired'}), 401
        except Exception as e:
            return jsonify({'message':'Invalid token', 'error': str(e)}), 401
        return f(user_id, *args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.headers.get('Authorization')
        if not auth:
            return jsonify({'message':'Token missing'}), 401
        token = auth.replace('Bearer ', '')
        try:
            payload = jwt.decode(
                token,
                app.config['SECRET_KEY'],
                algorithms=['HS256']
            )
            if payload.get('role') != 'admin':
                return jsonify({
                    'message':'Akses hanya untuk admin'
                }), 403
        except jwt.ExpiredSignatureError:
            return jsonify({
                'message':'Token expired'
            }), 401
        except Exception as e:
            return jsonify({
                'message':'Invalid token',
                'error': str(e)
            }), 401
        return f(*args, **kwargs)
    return decorated

# ROOT
@app.route('/')
def index():
    return jsonify({'message':'Backend Pisang Deteksi aktif'})

#REGISTER LEWAT POSTMAN
@app.route('/register-postman', methods=['POST'])
def register():
    data = request.json

    hashed = bcrypt.hashpw(
        data['password'].encode(),
        bcrypt.gensalt()
    )

    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO users
        (nama, email, no_telepon, alamat, username, password, role)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (
        data['nama'],
        data['email'],
        data['no_telepon'],
        data['alamat'],
        data['username'],
        hashed,
        data['role']
    ))

    mysql.connection.commit()
    return jsonify({"message": "success"})

# REGISTER
@app.route('/register', methods=['POST'])
def register_postman():
    data = request.form
    nama = data.get('nama')
    email = data.get('email')
    no_telepon = data.get('no_telepon')
    alamat = data.get('alamat')
    username = data.get('username')
    password = data.get('password')

    if not all([nama, email, no_telepon, alamat, username, password]):
        return jsonify({'message':'Lengkapi field yang dibutuhkan'}), 400

    cur = mysql.connection.cursor()
    cur.execute("SELECT id FROM users WHERE email=%s OR no_telepon=%s OR username=%s", (email,no_telepon,username))
    exists = cur.fetchone()
    if exists:
        cur.close()
        return jsonify({'message':'Email/No telepon/Username sudah digunakan'}), 400

    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    foto_filename = None
    if 'foto' in request.files:
        f = request.files['foto']
        if f and f.filename and allowed_file(f.filename):
            ext = f.filename.rsplit('.',1)[1].lower()
            foto_filename = f"user_{username}_{int(datetime.utcnow().timestamp())}.{ext}"
            f.save(os.path.join(UPLOAD_USERS, foto_filename))

    cur.execute("""
        INSERT INTO users (nama,email,no_telepon,alamat,foto,username,password)
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (nama,email,no_telepon,alamat,foto_filename,username,hashed))
    mysql.connection.commit()
    cur.close()
    return jsonify({'message':'Registrasi sukses'}), 201

# TAMBAH ADMIN
@app.route('/admin/tambah', methods=['POST'])
@admin_required
def admin_create_user():

    data = request.form

    nama = data.get('nama')
    email = data.get('email')
    no_telepon = data.get('no_telepon')
    alamat = data.get('alamat')
    username = data.get('username')
    password = data.get('password')
    role = "admin"

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT id
        FROM users
        WHERE email=%s OR username=%s OR no_telepon=%s
    """, (email, username, no_telepon))

    if cur.fetchone():
        cur.close()
        return jsonify({'message': 'Data sudah digunakan'}), 400

    hashed = bcrypt.hashpw(
        password.encode('utf-8'),
        bcrypt.gensalt()
    ).decode('utf-8')

    # TAMBAHAN FOTO 
    foto_filename = None

    if 'foto' in request.files:
        file = request.files['foto']

        if file and file.filename and allowed_file(file.filename):
            ext = file.filename.rsplit('.', 1)[1].lower()

            foto_filename = (
                f"admin_{username}_{int(datetime.utcnow().timestamp())}.{ext}"
            )

            file.save(os.path.join(UPLOAD_USERS, foto_filename))

    #  INSERT 
    cur.execute("""
        INSERT INTO users
        (
            nama,email,no_telepon,alamat,
            foto,username,password,role
        )
        VALUES
        (%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        nama,
        email,
        no_telepon,
        alamat,
        foto_filename,   
        username,
        hashed,
        role
    ))

    mysql.connection.commit()
    cur.close()

    return jsonify({
        'message': 'Admin berhasil dibuat'
    }), 201

# DELETE USER
@app.route('/admin/users/<int:id>', methods=['DELETE'])
@admin_required
def delete_user(id):
    cur = mysql.connection.cursor()

    cur.execute("SELECT id FROM users WHERE id=%s", (id,))
    if not cur.fetchone():
        cur.close()
        return jsonify({'message': 'User tidak ditemukan'}), 404

    cur.execute("DELETE FROM users WHERE id=%s", (id,))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'User berhasil dihapus'}), 200

# UBAH ROLE (ADMIN)
@app.route('/admin/users/<int:id>/role', methods=['PUT'])
@admin_required
def update_user_role(id):
    data = request.json or {}
    role = data.get('role')

    if role not in ['admin', 'user']:
        return jsonify({'message': 'Role harus admin atau user'}), 400

    cur = mysql.connection.cursor()

    cur.execute("SELECT id FROM users WHERE id=%s", (id,))
    if not cur.fetchone():
        cur.close()
        return jsonify({'message': 'User tidak ditemukan'}), 404

    cur.execute(
        "UPDATE users SET role=%s WHERE id=%s",
        (role, id)
    )

    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'Role berhasil diperbarui'}), 200

#MELIHAT DAFTAR USER (ADMIN)
@app.route('/admin/users', methods=['GET'])
@admin_required
def admin_list_users():

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT
            id,
            nama,
            email,
            username,
            role,
            created_at
        FROM users
        ORDER BY id DESC
    """)

    rows = cur.fetchall()
    cur.close()

    result = []

    for r in rows:
        result.append({
            'id': r[0],
            'nama': r[1],
            'email': r[2],
            'username': r[3],
            'role': r[4],
            'created_at': r[5]
        })

    return jsonify(result)

# LOGIN
@app.route('/login', methods=['POST'])
def login():
    data = request.json or {}
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message':'username & password diperlukan'}), 400

    cur = mysql.connection.cursor()
    cur.execute(
        "SELECT id, password, role FROM users WHERE username=%s",
        (username,)
    )
    user = cur.fetchone()
    cur.close()
    if not user:
        return jsonify({'message':'Credentials invalid'}), 401

    user_id = user[0]
    stored_hash = user[1]
    role = user[2]
    if isinstance(stored_hash, str):
        stored_hash = stored_hash.encode('utf-8')

    if not bcrypt.checkpw(password.encode('utf-8'), stored_hash):
        return jsonify({'message':'Credentials invalid'}), 401

    token = jwt.encode({
        'user_id': user_id,
        'role': role,
        'exp': datetime.utcnow() + timedelta(hours=8)
    }, app.config['SECRET_KEY'], algorithm='HS256')

    return jsonify({
        'token': token,
        'user_id': user_id,
        'role': role
    })

# LOGOUT
@app.route('/logout', methods=['POST'])
@token_required
def logout(user_id):
    return jsonify({'message': 'Logout berhasil'}), 200

# PROFILE
@app.route('/profile', methods=['GET'])
@token_required
def get_profile(user_id):
    cur = mysql.connection.cursor()
    cur.execute(
        """
        SELECT id,nama,email,no_telepon,alamat,
            foto,username,role,created_at
        FROM users
        WHERE id=%s
        """,
        (user_id,)
    )
    row = cur.fetchone()
    cur.close()
    if not row:
        return jsonify({'message':'User tidak ditemukan'}), 404
    keys = [
        'id',
        'nama',
        'email',
        'no_telepon',
        'alamat',
        'foto',
        'username',
        'role',
        'created_at'
    ]

    data = dict(zip(keys, row))
    if data['foto']:
        data['foto_url'] = request.host_url.rstrip('/') + '/uploads/users/' + data['foto']
    else:
        data['foto_url'] = None
    return jsonify(data)

# PENYAKIT
@app.route('/penyakit', methods=['GET'])
def list_penyakit():
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, nama, deskripsi, gambar, gejala, pencegahan, mengatasi, bahaya, created_at FROM penyakit ORDER BY id")
    rows = cur.fetchall()
    cur.close()
    result = []
    for r in rows:
        item = {
            'id': r[0], 'nama': r[1], 'deskripsi': r[2], 'gambar': r[3],
            'gejala': r[4], 'pencegahan': r[5], 'mengatasi' : r[6], 'bahaya': r[7],
            'created_at': r[8]
        }
        item['gambar_url'] = request.host_url.rstrip('/') + '/uploads/penyakit/' + item['gambar'] if item['gambar'] else None
        result.append(item)
    return jsonify(result)

#TAMBAH PENYAKIT (ADMIN)
@app.route('/admin/penyakit', methods=['POST'])
@admin_required
def tambah_penyakit():

    nama = request.form.get('nama')
    deskripsi = request.form.get('deskripsi')
    gejala = request.form.get('gejala')
    pencegahan = request.form.get('pencegahan')
    mengatasi = request.form.get('mengatasi')
    bahaya = request.form.get('bahaya')

    if not nama:
        return jsonify({
            'message':'Nama penyakit wajib diisi'
        }), 400

    filename = None

    if 'gambar' in request.files:
        file = request.files['gambar']

        if file and allowed_file(file.filename):
            ext = file.filename.rsplit('.',1)[1].lower()
            filename = (
                f"penyakit_{int(datetime.utcnow().timestamp())}.{ext}"
            )
            file.save(
                os.path.join(
                    UPLOAD_PENYAKIT,
                    filename
                )
            )

    cur = mysql.connection.cursor()

    cur.execute("""
        INSERT INTO penyakit
        (
            nama,
            deskripsi,
            gambar,
            gejala,
            pencegahan,
            mengatasi,
            bahaya
        )
        VALUES
        (%s,%s,%s,%s,%s,%s,%s)
    """, (
        nama,
        deskripsi,
        filename,
        gejala,
        pencegahan,
        mengatasi,
        bahaya
    ))

    mysql.connection.commit()
    penyakit_id = cur.lastrowid
    cur.close()

    return jsonify({
        'message':'Penyakit berhasil ditambahkan',
        'id': penyakit_id
    }), 201

#EDIT PENYAKIT (ADMIN)
@app.route('/admin/penyakit/<int:id>', methods=['PUT'])
@admin_required
def update_penyakit(id):

    cur = mysql.connection.cursor()
    cur.execute(
        "SELECT gambar FROM penyakit WHERE id=%s",
        (id,)
    )

    old_data = cur.fetchone()

    if not old_data:
        cur.close()
        return jsonify({
            'message':'Penyakit tidak ditemukan'
        }), 404

    old_gambar = old_data[0]

    nama = request.form.get('nama')
    deskripsi = request.form.get('deskripsi')
    gejala = request.form.get('gejala')
    pencegahan = request.form.get('pencegahan')
    mengatasi = request.form.get('mengatasi')
    bahaya = request.form.get('bahaya')

    gambar = old_gambar

    if 'gambar' in request.files:
        file = request.files['gambar']

        if file and allowed_file(file.filename):
            ext = file.filename.rsplit('.',1)[1].lower()
            gambar = f"penyakit_{int(time.time())}.{ext}"
            file.save(
                os.path.join(
                    UPLOAD_PENYAKIT,
                    gambar
                )
            )

            if old_gambar:
                try:
                    os.remove(
                        os.path.join(
                            UPLOAD_PENYAKIT,
                            old_gambar
                        )
                    )
                except:
                    pass

    cur.execute("""
        UPDATE penyakit
        SET
            nama=%s,
            deskripsi=%s,
            gambar=%s,
            gejala=%s,
            pencegahan=%s,
            mengatasi=%s,
            bahaya=%s
        WHERE id=%s
    """, (
        nama,
        deskripsi,
        gambar,
        gejala,
        pencegahan,
        mengatasi,
        bahaya,
        id
    ))

    mysql.connection.commit()
    cur.close()
    return jsonify({
        'message':'Penyakit berhasil diperbarui'
    })

#HAPUS PENYAKIT (ADMIN)
@app.route('/admin/penyakit/<int:id>', methods=['DELETE'])
@admin_required
def delete_penyakit(id):
    cur = mysql.connection.cursor()
    cur.execute(
        "SELECT gambar FROM penyakit WHERE id=%s",
        (id,)
    )

    penyakit = cur.fetchone()

    if not penyakit:
        cur.close()
        return jsonify({
            'message':'Penyakit tidak ditemukan'
        }), 404

    gambar = penyakit[0]
    cur.execute(
        "DELETE FROM penyakit WHERE id=%s",
        (id,)
    )

    mysql.connection.commit()
    cur.close()

    if gambar:
        try:
            os.remove(
                os.path.join(
                    UPLOAD_PENYAKIT,
                    gambar
                )
            )
        except:
            pass

    return jsonify({
        'message':'Penyakit berhasil dihapus'
    })

# RIWAYAT DETEKSI
@app.route('/riwayat', methods=['GET'])
@token_required
def list_riwayat(user_id):

    cur = mysql.connection.cursor()

    cur.execute("""
        SELECT
            rd.id,
            p.nama,
            rd.confidence,
            rd.waktu_deteksi,
            rd.filename,
            rd.created_at
        FROM riwayat_deteksi rd
        LEFT JOIN penyakit p
            ON rd.penyakit_id = p.id
        WHERE rd.user_id=%s
        ORDER BY rd.waktu_deteksi DESC
    """, (user_id,))

    rows = cur.fetchall()
    cur.close()

    result = []

    for r in rows:

        item = {
            'id': r[0],
            'jenis_penyakit': r[1],
            'confidence': round(r[2] * 100, 2),
            'waktu_deteksi': r[3],
            'filename': r[4],
            'created_at': r[5]
        }

        if item['filename']:
            item['image_url'] = (
                request.host_url.rstrip('/')
                + '/uploads/histori/'
                + item['filename']
            )
        else:
            item['image_url'] = None

        result.append(item)

    return jsonify(result)

@app.route('/riwayat/<int:id>', methods=['DELETE'])
@token_required
def delete_riwayat(user_id, id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT filename FROM riwayat_deteksi WHERE id=%s AND user_id=%s", (id,user_id))
    r = cur.fetchone()
    if not r:
        cur.close()
        return jsonify({'message':'Riwayat tidak ditemukan'}), 404
    filename = r[0]
    cur.execute("DELETE FROM riwayat_deteksi WHERE id=%s AND user_id=%s", (id,user_id))
    mysql.connection.commit()
    cur.close()
    if filename:
        try:
            os.remove(os.path.join(UPLOAD_HISTORI, filename))
        except:
            pass
    return jsonify({'message':'Riwayat dihapus'})

@app.route('/riwayat/all', methods=['DELETE'])
@token_required
def delete_all_riwayat(user_id):
    cur = mysql.connection.cursor()

    # Ambil semua filename dulu (agar file juga ikut dihapus)
    cur.execute("SELECT filename FROM riwayat_deteksi WHERE user_id=%s", (user_id,))
    rows = cur.fetchall()

    # Hapus semua data dari database
    cur.execute("DELETE FROM riwayat_deteksi WHERE user_id=%s", (user_id,))
    mysql.connection.commit()
    cur.close()

    # Hapus file gambar di folder
    for r in rows:
        filename = r[0]
        if filename:
            try:
                os.remove(os.path.join(UPLOAD_HISTORI, filename))
            except:
                pass

    return jsonify({'message': 'Semua riwayat berhasil dihapus'})

# SERVE UPLOADS
@app.route('/uploads/users/<filename>')
def serve_user_image(filename):
    return send_from_directory(UPLOAD_USERS, filename)

@app.route('/uploads/penyakit/<filename>')
def serve_penyakit_image(filename):
    return send_from_directory(UPLOAD_PENYAKIT, filename)

@app.route('/uploads/histori/<filename>')
def serve_histori_image(filename):
    return send_from_directory(UPLOAD_HISTORI, filename)

# MODEL DETEKSI PISANG (EfficientNetB2)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.abspath(
    os.path.join(BASE_DIR, "..", "models", "model_efficientnetb2_final3.tflite")
)
interpreter = Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
IMG_SIZE = 260


def simpan_riwayat(user_id, filename, penyakit_id , confidence):
    cur = mysql.connection.cursor()
    cur.execute(
        "INSERT INTO riwayat_deteksi (user_id, penyakit_id, confidence, waktu_deteksi, filename, created_at) "
        "VALUES (%s,%s,%s,NOW(),%s,NOW())",
        (user_id, penyakit_id, confidence, filename)
    )
    mysql.connection.commit()
    cur.close()

# PREDICT REALTIME
from tensorflow.keras.applications.efficientnet import preprocess_input

@app.route('/predict/realtime', methods=['POST'])
@token_required
def predict_realtime(user_id):

    if 'image' not in request.files:
        return jsonify({
            "message": "File gambar wajib dikirim"
        }), 400

    file = request.files['image']
    file_bytes = np.frombuffer(file.read(),np.uint8)
    image = cv2.imdecode(file_bytes,cv2.IMREAD_COLOR)

    if image is None:
        return jsonify({
            "message": "Gambar tidak valid"
        }), 400

    # Convert RGB
    image_rgb = cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb,(IMG_SIZE, IMG_SIZE))

    # Preprocessing EfficientNetB2
    input_data = preprocess_input(
        np.expand_dims(image_resized.astype(np.float32),axis=0)
    )

    # Hitung waktu inferensi
    start_time = time.time()

    interpreter.set_tensor(input_details[0]['index'],input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])[0]

    end_time = time.time()

    inference_time = round(end_time - start_time,4)

    # Ambil kelas dengan probabilitas tertinggi
    idx = int(np.argmax(output_data))

    CLASS_NAMES = [
        "Cordana",
        "Sehat",
        "no_leaf",
        "Pestalotiopsis",
        "Yellow Sigatoka"
    ]

    label = CLASS_NAMES[idx]
    confidence = float(output_data[idx])

    # Cari penyakit_id dari database
    cur = mysql.connection.cursor()

    cur.execute(
        """
        SELECT id
        FROM penyakit
        WHERE nama=%s
        """,
        (label,)
    )

    row = cur.fetchone()
    cur.close()

    if not row:
        return jsonify({
            "message": f"Data penyakit '{label}' tidak ditemukan"
        }), 404

    penyakit_id = row[0]

    # Simpan gambar hasil deteksi
    filename = (
        f"deteksi_{user_id}_"
        f"{int(datetime.utcnow().timestamp())}.jpg"
    )

    save_path = os.path.join(UPLOAD_HISTORI,filename)

    cv2.imwrite(save_path,image)

    # Simpan riwayat
    simpan_riwayat(
        user_id,
        filename,
        penyakit_id,
        confidence
    )

    return jsonify({
        'label': label,
        'confidence': round(
            confidence * 100,
            2
        ),
        'inference_time': inference_time,
        'file_url':
            request.host_url.rstrip('/')
            + '/uploads/histori/'
            + filename
    })

# EDIT PROFILE
@app.route('/profile/edit', methods=['PUT'])
@token_required
def edit_profile(user_id):
    cur = mysql.connection.cursor()
    data = request.form

    # Ambil data
    nama = data.get('nama')
    email = data.get('email')
    username = data.get('username')
    no_telepon = data.get('no_telepon', '')
    alamat = data.get('alamat', '')
    password = data.get('password', None)

    # Validasi field 
    if not all([nama, email, username]):
        cur.close()
        return jsonify({'message': 'Nama, email, dan username wajib diisi'}), 400

    # Cek duplikasi email/username/no_telepon untuk user lain
    cur.execute("""
        SELECT id FROM users 
        WHERE (email=%s OR username=%s OR no_telepon=%s) AND id != %s
    """, (email, username, no_telepon, user_id))
    exists = cur.fetchone()
    if exists:
        cur.close()
        return jsonify({'message': 'Email, username, atau no telepon sudah digunakan'}), 400

    # Update password jika ada
    password_sql = ""
    params = [nama, email, username, no_telepon, alamat, user_id]
    if password:
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        password_sql = ", password=%s"
        params.insert(-1, hashed)  # masukkan sebelum user_id

    # Update foto jika ada
    foto_filename = None
    if 'foto' in request.files:
        f = request.files['foto']
        if f and f.filename and allowed_file(f.filename):
            ext = f.filename.rsplit('.',1)[1].lower()
            foto_filename = f"user_{user_id}_{int(datetime.utcnow().timestamp())}.{ext}"
            f.save(os.path.join(UPLOAD_USERS, foto_filename))
            password_sql += ", foto=%s"
            params.insert(-1, foto_filename)

    sql = f"""
        UPDATE users
        SET nama=%s, email=%s, username=%s, no_telepon=%s, alamat=%s {password_sql}
        WHERE id=%s
    """
    cur.execute(sql, tuple(params))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'Profile berhasil diperbarui'})

#STATISTIK USER TERAKTIF
@app.route('/admin/statistik', methods=['GET'])
@admin_required
def statistik_user_aktif():
    try:
        cur = mysql.connection.cursor()

        cur.execute("""
            SELECT 
                u.id,
                u.nama,
                COUNT(rd.id) AS total_deteksi
            FROM users u
            LEFT JOIN riwayat_deteksi rd 
                ON rd.user_id = u.id
            WHERE u.role != 'admin'
            GROUP BY u.id, u.nama
            ORDER BY total_deteksi DESC
            LIMIT 5
        """)

        rows = cur.fetchall()
        cur.close()

        result = [
            {
                "id": r[0],
                "nama": r[1],
                "total_deteksi": int(r[2])
            }
            for r in rows
        ]

        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            "message": "Server error",
            "error": str(e)
        }), 500


# RUN
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
