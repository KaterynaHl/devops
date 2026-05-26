from app import app


def test_health_alive():
    client = app.test_client()

    response = client.get("/health/alive")

    assert response.status_code == 200
    assert response.data == b"OK"


def test_index_returns_endpoint_list():
    client = app.test_client()

    response = client.get("/")

    assert response.status_code == 200
    assert b"/notes" in response.data
    assert b"/health/alive" in response.data
    assert b"/health/ready" in response.data


def test_create_note_without_json_returns_bad_request():
    client = app.test_client()

    response = client.post("/notes")

    assert response.status_code == 400


def test_create_note_without_required_fields_returns_bad_request():
    client = app.test_client()

    response = client.post(
        "/notes",
        json={
            "title": "Only title"
        },
    )

    assert response.status_code == 400


def test_matrix_endpoint_returns_result():
    client = app.test_client()

    response = client.get("/matrix")

    assert response.status_code == 200

    data = response.get_json()

    assert "matrix_a" in data
    assert "matrix_b" in data
    assert "product" in data

    assert len(data["matrix_a"]) == 10
    assert len(data["matrix_b"]) == 10
    assert len(data["product"]) == 10
