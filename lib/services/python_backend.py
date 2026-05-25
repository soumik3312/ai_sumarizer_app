"""
============================================================
PYTHON BACKEND FOR AI NOTE SUMMARIZER
============================================================

This is the complete Python Flask backend that handles:
1. Text summarization
2. OCR (Image text extraction)
3. PDF text extraction
4. Keyword extraction
5. Sentiment analysis
6. Title generation

SETUP:
1. Install required packages:
   pip install flask flask-cors transformers torch pytesseract Pillow PyPDF2 pdf2image easyocr

2. Install Tesseract OCR on your system:
   - Windows: Download from https://github.com/UB-Mannheim/tesseract/wiki
   - Mac: brew install tesseract
   - Linux: sudo apt-get install tesseract-ocr

3. Run the server:
   python python_backend_example.py

4. The server will start at http://localhost:5000

5. Update the Flutter app's ApiService.baseUrl:
   - Android Emulator: 'http://10.0.2.2:5000'
   - iOS Simulator: 'http://localhost:5000'
   - Physical Device: Use your computer's IP address (e.g., 'http://192.168.1.100:5000')

============================================================
"""

import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename

# Uncomment these imports when you have the libraries installed
# import pytesseract
# from PIL import Image
# import easyocr
# import PyPDF2
# from pdf2image import convert_from_path
# from transformers import pipeline
# import torch

app = Flask(__name__)
CORS(app)

# Configure upload folder
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'pdf'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Create upload folder if it doesn't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# ============================================================
# Initialize AI Models (Uncomment when ready)
# ============================================================
# summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
# sentiment_analyzer = pipeline("sentiment-analysis")
# reader = easyocr.Reader(['en'])  # For EasyOCR

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# ============================================================
# ENDPOINT 1: SUMMARIZE TEXT
# ============================================================
@app.route('/api/summarize', methods=['POST'])
def summarize():
    """
    Summarize note text content.
    
    Request Body (JSON):
    {
        "content": "Your note text here...",
        "type": "brief" | "detailed" | "bullet_points"
    }
    
    Response:
    {
        "summary": "Summarized text...",
        "keyPoints": ["Point 1", "Point 2", ...]
    }
    
    ============================================================
    IMPLEMENTATION OPTIONS:
    ============================================================
    
    Option 1: Using Hugging Face Transformers (Free, Local)
    ---------------------------------------------------------
    from transformers import pipeline
    summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
    
    result = summarizer(content, max_length=130, min_length=30, do_sample=False)
    summary_text = result[0]['summary_text']
    
    
    Option 2: Using OpenAI API (Paid, Cloud)
    ---------------------------------------------------------
    import openai
    openai.api_key = "your-api-key"
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "Summarize the following text concisely."},
            {"role": "user", "content": content}
        ]
    )
    summary_text = response.choices[0].message.content
    
    
    Option 3: Using Google Gemini API (Free tier available)
    ---------------------------------------------------------
    import google.generativeai as genai
    genai.configure(api_key="your-api-key")
    model = genai.GenerativeModel('gemini-pro')
    
    response = model.generate_content(f"Summarize this text: {content}")
    summary_text = response.text
    
    ============================================================
    """
    data = request.json
    content = data.get('content', '')
    summary_type = data.get('type', 'brief')
    
    # ============================================================
    # YOUR AI SUMMARIZATION CODE HERE
    # Replace the mock response below with your actual AI code
    # ============================================================
    
    # MOCK RESPONSE - Replace with actual AI implementation
    words = content.split()
    if summary_type == 'brief':
        summary_text = ' '.join(words[:min(50, len(words))]) + ('...' if len(words) > 50 else '')
        key_points = [
            "Main idea extracted from your note",
            "Key supporting point identified",
            "Action items or conclusions noted"
        ]
    elif summary_type == 'detailed':
        summary_text = f"Detailed Analysis: {content}"
        key_points = [
            "Primary topic discussed",
            "Supporting evidence provided",
            "Contextual information included",
            "Conclusions and recommendations",
            "Related topics for further exploration"
        ]
    else:  # bullet_points
        summary_text = content
        key_points = [f"• {' '.join(words[i:i+10])}" for i in range(0, min(len(words), 50), 10)]
    
    return jsonify({
        'summary': summary_text,
        'keyPoints': key_points
    })


# ============================================================
# ENDPOINT 2: OCR - EXTRACT TEXT FROM IMAGE
# ============================================================
@app.route('/api/ocr/image', methods=['POST'])
def ocr_image():
    """
    Extract text from an image using OCR.
    
    Request: multipart/form-data
    - Field name: 'image'
    - File: image file (jpg, png, etc.)
    
    Response:
    {
        "text": "Extracted text from the image..."
    }
    
    ============================================================
    IMPLEMENTATION OPTIONS:
    ============================================================
    
    Option 1: Using Tesseract OCR (Free, Local)
    ---------------------------------------------------------
    import pytesseract
    from PIL import Image
    
    # Set Tesseract path if needed (Windows)
    # pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
    
    image = Image.open(file_path)
    text = pytesseract.image_to_string(image)
    
    
    Option 2: Using EasyOCR (Free, Local, GPU support)
    ---------------------------------------------------------
    import easyocr
    reader = easyocr.Reader(['en'])
    
    result = reader.readtext(file_path)
    text = ' '.join([item[1] for item in result])
    
    
    Option 3: Using Google Cloud Vision API (Paid)
    ---------------------------------------------------------
    from google.cloud import vision
    client = vision.ImageAnnotatorClient()
    
    with open(file_path, 'rb') as image_file:
        content = image_file.read()
    image = vision.Image(content=content)
    response = client.text_detection(image=image)
    text = response.text_annotations[0].description
    
    
    Option 4: Using AWS Textract (Paid)
    ---------------------------------------------------------
    import boto3
    client = boto3.client('textract')
    
    with open(file_path, 'rb') as file:
        response = client.detect_document_text(Document={'Bytes': file.read()})
    text = ' '.join([block['Text'] for block in response['Blocks'] if block['BlockType'] == 'LINE'])
    
    ============================================================
    """
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        try:
            # ============================================================
            # YOUR OCR CODE HERE
            # Replace with actual OCR implementation
            # ============================================================
            
            # Example with pytesseract (uncomment when installed):
            # from PIL import Image
            # import pytesseract
            # image = Image.open(file_path)
            # text = pytesseract.image_to_string(image)
            
            # Example with EasyOCR (uncomment when installed):
            # result = reader.readtext(file_path)
            # text = ' '.join([item[1] for item in result])
            
            # MOCK RESPONSE - Replace with actual OCR
            text = f"[Mock OCR] Text extracted from image: {filename}. Install pytesseract or easyocr for real OCR."
            
            return jsonify({'text': text})
            
        finally:
            # Clean up uploaded file
            if os.path.exists(file_path):
                os.remove(file_path)
    
    return jsonify({'error': 'Invalid file type'}), 400


# ============================================================
# ENDPOINT 3: EXTRACT TEXT FROM PDF
# ============================================================
@app.route('/api/extract-pdf-text', methods=['POST'])
def extract_pdf_text():
    """
    Extract text from a PDF file.
    
    Request: multipart/form-data
    - Field name: 'pdf'
    - File: PDF file
    
    Response:
    {
        "text": "Extracted text from the PDF...",
        "pages": 5
    }
    
    ============================================================
    IMPLEMENTATION OPTIONS:
    ============================================================
    
    Option 1: Using PyPDF2 (Free, for text-based PDFs)
    ---------------------------------------------------------
    import PyPDF2
    
    with open(file_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        text = ''
        for page in reader.pages:
            text += page.extract_text() + '\n'
        pages = len(reader.pages)
    
    
    Option 2: Using pdfplumber (Free, better for tables)
    ---------------------------------------------------------
    import pdfplumber
    
    text = ''
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            text += page.extract_text() + '\n'
        pages = len(pdf.pages)
    
    
    Option 3: Using pdf2image + pytesseract (For scanned PDFs)
    ---------------------------------------------------------
    from pdf2image import convert_from_path
    import pytesseract
    
    images = convert_from_path(file_path)
    text = ''
    for image in images:
        text += pytesseract.image_to_string(image) + '\n'
    pages = len(images)
    
    ============================================================
    """
    if 'pdf' not in request.files:
        return jsonify({'error': 'No PDF file provided'}), 400
    
    file = request.files['pdf']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and file.filename.lower().endswith('.pdf'):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        try:
            # ============================================================
            # YOUR PDF EXTRACTION CODE HERE
            # Replace with actual PDF extraction implementation
            # ============================================================
            
            # Example with PyPDF2 (uncomment when installed):
            # import PyPDF2
            # with open(file_path, 'rb') as f:
            #     reader = PyPDF2.PdfReader(f)
            #     text = ''
            #     for page in reader.pages:
            #         text += page.extract_text() + '\n'
            #     pages = len(reader.pages)
            
            # MOCK RESPONSE - Replace with actual extraction
            text = f"[Mock PDF] Text extracted from PDF: {filename}. Install PyPDF2 or pdfplumber for real extraction."
            pages = 1
            
            return jsonify({
                'text': text,
                'pages': pages
            })
            
        finally:
            # Clean up uploaded file
            if os.path.exists(file_path):
                os.remove(file_path)
    
    return jsonify({'error': 'Invalid file type'}), 400


# ============================================================
# ENDPOINT 4: SUMMARIZE FILE (Image or PDF) - ALL IN ONE
# ============================================================
@app.route('/api/summarize-file', methods=['POST'])
def summarize_file():
    """
    Extract text from file (OCR for images, text extraction for PDFs)
    and then summarize the extracted text.
    
    Request: multipart/form-data
    - Field name: 'file'
    - Fields: 'summary_type' (brief|detailed|bullet_points), 'file_type' (image|pdf)
    
    Response:
    {
        "extractedText": "Full extracted text...",
        "summary": "Summarized text...",
        "keyPoints": ["Point 1", "Point 2", ...]
    }
    
    ============================================================
    IMPLEMENTATION:
    This endpoint combines OCR/PDF extraction + summarization
    ============================================================
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    summary_type = request.form.get('summary_type', 'brief')
    file_type = request.form.get('file_type', 'image')
    
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        try:
            # ============================================================
            # STEP 1: EXTRACT TEXT
            # ============================================================
            
            if file_type == 'image':
                # OCR for images
                # Example with pytesseract:
                # from PIL import Image
                # import pytesseract
                # image = Image.open(file_path)
                # extracted_text = pytesseract.image_to_string(image)
                
                # MOCK - Replace with actual OCR
                extracted_text = f"[Mock] Extracted text from image: {filename}"
            else:
                # Text extraction for PDFs
                # Example with PyPDF2:
                # import PyPDF2
                # with open(file_path, 'rb') as f:
                #     reader = PyPDF2.PdfReader(f)
                #     extracted_text = ''
                #     for page in reader.pages:
                #         extracted_text += page.extract_text() + '\n'
                
                # MOCK - Replace with actual extraction
                extracted_text = f"[Mock] Extracted text from PDF: {filename}"
            
            # ============================================================
            # STEP 2: SUMMARIZE EXTRACTED TEXT
            # ============================================================
            
            # Example with transformers:
            # result = summarizer(extracted_text, max_length=130, min_length=30)
            # summary = result[0]['summary_text']
            
            # MOCK - Replace with actual summarization
            words = extracted_text.split()
            if summary_type == 'brief':
                summary = ' '.join(words[:50]) + '...' if len(words) > 50 else extracted_text
                key_points = ["Key point 1", "Key point 2", "Key point 3"]
            elif summary_type == 'detailed':
                summary = f"Detailed analysis of the {file_type}: " + extracted_text
                key_points = ["Detailed point 1", "Detailed point 2", "Detailed point 3", "Detailed point 4"]
            else:
                summary = extracted_text
                key_points = [f"• Bullet {i+1}" for i in range(5)]
            
            return jsonify({
                'extractedText': extracted_text,
                'summary': summary,
                'keyPoints': key_points
            })
            
        finally:
            # Clean up uploaded file
            if os.path.exists(file_path):
                os.remove(file_path)
    
    return jsonify({'error': 'Invalid file type'}), 400


# ============================================================
# ENDPOINT 5: EXTRACT KEYWORDS
# ============================================================
@app.route('/api/extract-keywords', methods=['POST'])
def extract_keywords():
    """
    Extract keywords from text content.
    
    Request Body (JSON):
    {
        "content": "Your note text here..."
    }
    
    Response:
    {
        "keywords": ["keyword1", "keyword2", ...]
    }
    
    ============================================================
    IMPLEMENTATION OPTIONS:
    ============================================================
    
    Option 1: Using KeyBERT (Free, Local)
    ---------------------------------------------------------
    from keybert import KeyBERT
    kw_model = KeyBERT()
    
    keywords = kw_model.extract_keywords(content, top_n=10)
    keyword_list = [kw[0] for kw in keywords]
    
    
    Option 2: Using RAKE (Free, Local, Simple)
    ---------------------------------------------------------
    from rake_nltk import Rake
    rake = Rake()
    
    rake.extract_keywords_from_text(content)
    keywords = rake.get_ranked_phrases()[:10]
    
    
    Option 3: Using spaCy (Free, Local)
    ---------------------------------------------------------
    import spacy
    nlp = spacy.load("en_core_web_sm")
    
    doc = nlp(content)
    keywords = [token.text for token in doc if token.pos_ in ['NOUN', 'PROPN']][:10]
    
    ============================================================
    """
    data = request.json
    content = data.get('content', '')
    
    # MOCK - Replace with actual keyword extraction
    words = content.split()
    keywords = [w for w in words if len(w) > 4][:10]
    
    return jsonify({
        'keywords': keywords if keywords else ['note', 'content', 'summary']
    })


# ============================================================
# ENDPOINT 6: ANALYZE SENTIMENT
# ============================================================
@app.route('/api/sentiment', methods=['POST'])
def analyze_sentiment():
    """
    Analyze sentiment of text content.
    
    Request Body (JSON):
    {
        "content": "Your note text here..."
    }
    
    Response:
    {
        "sentiment": "positive" | "negative" | "neutral",
        "score": 0.85
    }
    
    ============================================================
    IMPLEMENTATION:
    ============================================================
    
    from transformers import pipeline
    sentiment_analyzer = pipeline("sentiment-analysis")
    
    result = sentiment_analyzer(content)[0]
    sentiment = result['label'].lower()
    score = result['score']
    
    ============================================================
    """
    data = request.json
    content = data.get('content', '')
    
    # MOCK - Replace with actual sentiment analysis
    return jsonify({
        'sentiment': 'neutral',
        'score': 0.5
    })


# ============================================================
# ENDPOINT 7: GENERATE TITLE
# ============================================================
@app.route('/api/generate-title', methods=['POST'])
def generate_title():
    """
    Generate a title for note content.
    
    Request Body (JSON):
    {
        "content": "Your note text here..."
    }
    
    Response:
    {
        "title": "Generated Title"
    }
    
    ============================================================
    IMPLEMENTATION:
    ============================================================
    
    Using OpenAI:
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "Generate a short, descriptive title (max 5 words)."},
            {"role": "user", "content": content}
        ]
    )
    title = response.choices[0].message.content
    
    ============================================================
    """
    data = request.json
    content = data.get('content', '')
    
    # MOCK - Replace with actual title generation
    words = content.split()[:5]
    title = ' '.join(words).title() if words else 'New Note'
    
    return jsonify({
        'title': title
    })


# ============================================================
# HEALTH CHECK ENDPOINT
# ============================================================
@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'})


# ============================================================
# MAIN - RUN SERVER
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("AI NOTE SUMMARIZER - PYTHON BACKEND")
    print("=" * 60)
    print("")
    print("Server starting at http://localhost:5000")
    print("")
    print("ENDPOINTS:")
    print("-" * 60)
    print("TEXT PROCESSING:")
    print("  POST /api/summarize         - Summarize note text")
    print("  POST /api/extract-keywords  - Extract keywords")
    print("  POST /api/sentiment         - Analyze sentiment")
    print("  POST /api/generate-title    - Generate title")
    print("")
    print("FILE PROCESSING:")
    print("  POST /api/ocr/image         - Extract text from image (OCR)")
    print("  POST /api/extract-pdf-text  - Extract text from PDF")
    print("  POST /api/summarize-file    - Extract + Summarize file")
    print("")
    print("HEALTH:")
    print("  GET  /health                - Health check")
    print("-" * 60)
    print("")
    print("FLUTTER CONNECTION:")
    print("  - Android Emulator: http://10.0.2.2:5000")
    print("  - iOS Simulator:    http://localhost:5000")
    print("  - Physical Device:  http://<YOUR_IP>:5000")
    print("=" * 60)
    
    app.run(debug=True, host='0.0.0.0', port=5000)
