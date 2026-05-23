from pathlib import Path


def test_service_modules_do_not_import_fastapi():
    service_files = Path("backend/app/services").glob("*.py")
    offenders = []
    for service_file in service_files:
        source = service_file.read_text(encoding="utf-8")
        if "fastapi" in source:
            offenders.append(str(service_file))

    assert offenders == []
