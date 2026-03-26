from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch

MODEL_NAME = "google/flan-t5-base"

print("Loading FLAN-T5 model (instruction-tuned)...")

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME)

model.eval()

print("FLAN-T5 loaded successfully.")

# ============================================================
# HELPER: RUN PROMPT
# ============================================================

def run_prompt(prompt: str, max_length=256):
    inputs = tokenizer(prompt, return_tensors="pt", truncation=True)
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=max_length,
            do_sample=False
        )
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# ============================================================
# MAIN SUMMARIZER (REAL AI)
# ============================================================

def summarize_text(content: str, summary_type: str):
    content = content.strip()

    if len(content.split()) < 20:
        return {
            "summary": content,
            "keyPoints": ["Content too short to summarize"]
        }

    # ---------------------------
    # SUMMARY PROMPTS
    # ---------------------------

    if summary_type == "brief":
        summary_prompt = f"""
        Summarize the following note in 2–3 concise sentences:

        {content}
        """

    elif summary_type == "detailed":
        summary_prompt = f"""
        Create a clear, well-structured detailed summary of the following note:

        {content}
        """

    else:  # bullet_points
        summary_prompt = f"""
        Summarize the following note into 5 clear bullet points:

        {content}
        """

    summary = run_prompt(summary_prompt, max_length=300)

    # ---------------------------
    # KEY POINTS PROMPT
    # ---------------------------

    key_points_prompt = f"""
    Extract the 5 most important key points from the following note:

    {content}
    """

    key_points_text = run_prompt(key_points_prompt, max_length=200)

    key_points = [
        kp.strip("-• ").strip()
        for kp in key_points_text.split("\n")
        if len(kp.strip()) > 4
    ][:5]

    return {
        "summary": summary,
        "keyPoints": key_points
    }
