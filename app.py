from flask import Flask, render_template, request, redirect, session
import mysql.connector
from functools import wraps
from datetime import datetime
import os

app = Flask(__name__, 
            template_folder=os.path.join(os.path.dirname(__file__), 'templates'),
            static_folder=os.path.join(os.path.dirname(__file__), 'static'))
app.secret_key = "gym_management_system_2026"


# ---------------- DATABASE ----------------
def get_db():
    return mysql.connector.connect(
        host="6hm-dl.h.filess.io",
        user="GymFitnessDB_aloudcanal",
        password="d2e55d0b16f3ce0522f4c4a6ff22202e8711cee3",
        database="GymFitnessDB_aloudcanal",
        port=61002
    )


# ---------------- LOGIN REQUIRED ----------------
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user' not in session:
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated_function


# ---------------- LOGIN ----------------
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username'].strip()
        password = request.form['password'].strip()
        db = get_db()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM Admin WHERE username=%s AND password=%s", (username, password))
        user = cursor.fetchone()
        db.close()
        if user:
            session['user'] = username
            return redirect('/dashboard')
        return render_template("login.html", error="Invalid username or password.")
    return render_template("login.html")


# ---------------- LOGOUT ----------------
@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')


# ---------------- DASHBOARD ----------------
@app.route('/dashboard')
@login_required
def dashboard():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT COUNT(*) FROM Members")
    total_members = cursor.fetchone()[0]
    cursor.execute("SELECT SUM(amount) FROM Payments WHERE payment_status='Paid'")
    total_revenue = cursor.fetchone()[0] or 0
    cursor.execute("SELECT COUNT(*) FROM Attendance WHERE attendance_date = CURDATE() AND status='Present'")
    today_attendance = cursor.fetchone()[0]
    db.close()
    return render_template("dashboard.html", total_members=total_members,
                           total_revenue=total_revenue, today_attendance=today_attendance)


# ---------------- HOME (MEMBERS) ----------------
@app.route('/')
@login_required
def home():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT m.member_id, m.full_name, m.gender, m.phone, m.membership_type, m.join_date,
               COALESCE(MAX(t.trainer_name), 'Not Assigned')
        FROM Members m
        LEFT JOIN Workout_Plans wp ON m.member_id = wp.member_id
        LEFT JOIN Trainers t ON wp.trainer_id = t.trainer_id
        GROUP BY m.member_id, m.full_name, m.gender, m.phone, m.membership_type, m.join_date
    """)
    members = cursor.fetchall()
    db.close()
    return render_template("index.html", members=members)


# ---------------- ADD MEMBER ----------------
@app.route('/add', methods=['POST'])
@login_required
def add_member():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO Members(full_name, gender, phone, email, membership_type, join_date)
        VALUES (%s, %s, %s, %s, %s, CURDATE())
    """, (request.form['name'], request.form['gender'], request.form['phone'],
          request.form.get('email',''), request.form.get('membership_type','Monthly')))
    db.commit()
    db.close()
    return redirect('/')


# ---------------- EDIT MEMBER ----------------
@app.route('/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def edit_member(id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Members WHERE member_id=%s", (id,))
    member = cursor.fetchone()
    if request.method == 'POST':
        cursor.execute("""
            UPDATE Members SET full_name=%s, gender=%s, phone=%s, membership_type=%s
            WHERE member_id=%s
        """, (request.form['name'], request.form['gender'], request.form['phone'],
              request.form.get('membership_type','Monthly'), id))
        db.commit()
        db.close()
        return redirect('/')
    db.close()
    return render_template("edit.html", member=member)


# ---------------- DELETE MEMBER ----------------
@app.route('/delete/<int:id>')
@login_required
def delete_member(id):
    try:
        db = get_db()
        cursor = db.cursor()
        cursor.execute("DELETE FROM Members WHERE member_id=%s", (id,))
        db.commit()
        db.close()
        return redirect('/')
    except Exception as e:
        print("DELETE ERROR:", e)
        return "Cannot delete member — an error occurred."


# ---------------- MARK ATTENDANCE ----------------
@app.route('/mark_attendance/<int:id>')
@login_required
def mark_attendance(id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO Attendance(member_id, attendance_date, check_in_time, status)
        VALUES (%s, CURDATE(), %s, 'Present')
    """, (id, datetime.now().strftime("%H:%M:%S")))
    db.commit()
    db.close()
    return redirect('/')


# ---------------- ATTENDANCE PAGE ----------------
@app.route('/attendance')
@login_required
def attendance():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT m.full_name, a.attendance_date, a.check_in_time, a.status
        FROM Attendance a
        JOIN Members m ON m.member_id = a.member_id
        ORDER BY a.attendance_date DESC
    """)
    data = cursor.fetchall()
    db.close()
    return render_template("attendance.html", data=data)


# ---------------- TRAINERS ----------------
# ---------------- TRAINERS ----------------
@app.route('/trainers')
@login_required
def trainers():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Trainers")
    data = cursor.fetchall()
    db.close()
    return render_template("trainers.html", trainers=data)

@app.route('/trainers/add', methods=['POST'])
@login_required
def add_trainer():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO Trainers (trainer_name, specialization, phone)
        VALUES (%s, %s, %s)
    """, (request.form['name'], request.form['specialization'], request.form['phone']))
    db.commit()
    db.close()
    return redirect('/trainers')

@app.route('/trainers/delete/<int:id>')
@login_required
def delete_trainer(id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("DELETE FROM Trainers WHERE trainer_id=%s", (id,))
    db.commit()
    db.close()
    return redirect('/trainers')
    
# ---------------- ADD PAYMENT ----------------
@app.route('/pay/<int:id>', methods=['POST'])
@login_required
def add_payment(id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO Payments(member_id, amount, payment_date, payment_status)
        VALUES (%s, %s, CURDATE(), 'Paid')
    """, (id, request.form['amount']))
    db.commit()
    db.close()
    return redirect('/')


# ---------------- PAYMENTS PAGE ----------------
@app.route('/payments')
@login_required
def payments():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("""
        SELECT m.full_name, p.amount, p.payment_date, p.payment_status
        FROM Payments p
        JOIN Members m ON m.member_id = p.member_id
        ORDER BY p.payment_date DESC
    """)
    data = cursor.fetchall()
    db.close()
    return render_template("payments.html", data=data)


# ---------------- RUN APP ----------------
if __name__ == '__main__':
    app.run(debug=True)