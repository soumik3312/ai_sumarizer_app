import os

# ===============================
# BASIC APP CONFIG
# ===============================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")
MAX_FILE_SIZE_MB = 16

ALLOWED_IMAGE_EXTENSIONS = {"png", "jpg", "jpeg", "webp"}
ALLOWED_PDF_EXTENSIONS = {"pdf"}

# ===============================
# AI MODEL CONFIG
# ===============================

SUMMARIZER_MODEL = "facebook/bart-large-cnn"
SENTIMENT_MODEL = "distilbert-base-uncased-finetuned-sst-2-english"

MAX_SUMMARY_LENGTH = {
    "brief": 80,
    "detailed": 200,
    "bullet_points": 150,
}

MIN_SUMMARY_LENGTH = {
    "brief": 30,
    "detailed": 100,
    "bullet_points": 60,
}

# ===============================
# OCR CONFIG
# ===============================

OCR_LANGUAGES = ["en"]

# ===============================
# UTILITY
# ===============================

def ensure_directories():
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
