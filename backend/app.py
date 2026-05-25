from flask import Flask, request, jsonify
from flask_cors import CORS
from config import ensure_directories
from ai.summarizer import summarize_text



# ============================================================
# HEALTH CHECK
# ============================================================
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

# ============================================================
# REAL AI SUMMARIZATION
# ============================================================
@app.route("/api/summarize", methods=["POST"])
def summarize():
    data = request.json
    content = data.get("content", "")
    summary_type = data.get("type", "brief")

    result = summarize_text(content, summary_type)

    return jsonify({
        "summary": result["summary"],
        "keyPoints": result["keyPoints"]
    })

# ============================================================
# PLACEHOLDERS (SAFE)
# ============================================================
@app.route("/api/extract-keywords", methods=["POST"])
def keywords_placeholder():
    return jsonify({"keywords": ["ai", "notes", "summary"]})

@app.route("/api/sentiment", methods=["POST"])
def sentiment_placeholder():
    return jsonify({"sentiment": "neutral", "score": 0.5})

@app.route("/api/generate-title", methods=["POST"])
def title_placeholder():
    return jsonify({"title": "AI Generated Note"})

# ============================================================
# RUN SERVER
# ============================================================
if __name__ == "__main__":
    print("========================================")
    print(" AI NOTE SUMMARIZER - PHASE 2")
    print("========================================")
    print(" Loading AI model... first run may be slow")
    print("========================================")
    app.run(host="0.0.0.0", port=5000, debug=True)
