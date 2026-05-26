from flask import Flask, request, jsonify
from sqlalchemy import text

from app.database import SessionLocal
from app.models import Note

app = Flask(__name__)


@app.route("/")
def index():
    return """
    <h1>MyWebApp API</h1>

    <ul>
        <li>GET /notes</li>
        <li>POST /notes</li>
        <li>GET /notes/&lt;id&gt;</li>
        <li>GET /health/alive</li>
        <li>GET /health/ready</li>
    </ul>
    """


@app.route("/health/alive")
def health_alive():
    return "OK", 200


@app.route("/health/ready")
def health_ready():
    try:
        db = SessionLocal()

        db.execute(text("SELECT 1"))

        return "OK", 200

    except Exception as error:
        return str(error), 500


@app.route("/notes", methods=["GET"])
def get_notes():
    db = SessionLocal()

    notes = db.query(Note).all()

    notes_data = [
        {
            "id": note.id,
            "title": note.title
        }
        for note in notes
    ]

    accept_header = request.headers.get("Accept")

    if accept_header == "application/json":
        return jsonify(notes_data)

    html = """
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Title</th>
        </tr>
    """

    for note in notes:
        html += f"""
        <tr>
            <td>{note.id}</td>
            <td>{note.title}</td>
        </tr>
        """

    html += "</table>"

    return html


@app.route("/notes", methods=["POST"])
def create_note():
    db = SessionLocal()

    request_data = request.json

    note = Note(
        title=request_data["title"],
        content=request_data["content"]
    )

    db.add(note)

    db.commit()

    return jsonify(
        {
            "message": "note created"
        }
    ), 201


@app.route("/notes/<int:note_id>")
def get_note(note_id):
    db = SessionLocal()

    note = db.query(Note).filter(Note.id == note_id).first()

    if not note:
        return "Not found", 404

    note_data = {
        "id": note.id,
        "title": note.title,
        "content": note.content,
        "created_at": str(note.created_at)
    }

    accept_header = request.headers.get("Accept")

    if accept_header == "application/json":
        return jsonify(note_data)

    return f"""
    <h1>{note.title}</h1>

    <p>{note.content}</p>

    <small>{note.created_at}</small>
    """


if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=8000
    )