from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    return """
    <h1>MyWebApp</h1>
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
    return "OK", 200


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000)