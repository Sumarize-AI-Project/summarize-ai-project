import os
import json
import time
from tqdm import tqdm
from google import genai

# ==============================
# CONFIG
# ==============================
client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)

MODEL = "gemini-2.0-flash"

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

FILES_TO_PROCESS = [
    {
        "input": os.path.join(CURRENT_DIR, "extracted_group_A.jsonl"),
        "output": os.path.join(CURRENT_DIR, "refined_group_A.jsonl"),
        "group_name": "Nhóm A"
    },
    {
        "input": os.path.join(CURRENT_DIR, "extracted_group_B.jsonl"),
        "output": os.path.join(CURRENT_DIR, "refined_group_B.jsonl"),
        "group_name": "Nhóm B"
    }
]

# ==============================
# AI CALL (API MỚI)
# ==============================
def ask_ai(text, retry=3):

    prompt = f"""
Return ONLY valid JSON:

{{
"title": "",
"authors": [],
"publish_year": null,
"keywords_author": [],
"affiliation": "",
"abstract": ""
}}

TEXT:
{text}
"""

    for i in range(retry):
        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=prompt
            )

            text = response.text.strip()

            # fix ```json
            if text.startswith("```"):
                text = text.split("```")[1]

            return json.loads(text)

        except Exception as e:
            print(f"⚠️ Retry {i+1}: {e}")
            time.sleep(2 * (i + 1))

    return None


# ==============================
# CHECK
# ==============================
def need_refine(data):
    m = data.get("metadata", {})
    c = data.get("content", {})

    return (
        not m.get("title") or
        not m.get("authors") or
        not m.get("publish_year") or
        not m.get("keywords_author") or
        not m.get("publisher") or
        not c.get("ai_summary")
    )


# ==============================
# PROCESS
# ==============================
def process_file(input_path, output_path, name):

    if not os.path.exists(input_path):
        print(f"❌ Missing: {input_path}")
        return

    print(f"\n💎 {name}")

    processed = 0
    if os.path.exists(output_path):
        with open(output_path, "r", encoding="utf-8") as f:
            processed = sum(1 for _ in f)
        print(f"⏩ Resume: {processed}")

    with open(input_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    with open(output_path, "a", encoding="utf-8") as fout:

        for i, line in enumerate(tqdm(lines)):

            if i < processed:
                continue

            try:
                data = json.loads(line)
            except:
                continue

            data.setdefault("metadata", {})
            data.setdefault("content", {})
            data.setdefault("system", {})
            data.setdefault("nlp_data", {})

            if not need_refine(data):
                data["system"]["status"] = "skipped"
                fout.write(json.dumps(data, ensure_ascii=False) + "\n")
                continue

            text = data["content"].get("full_text", "")

            if len(text) > 3000:
                text = text[:1500] + "\n...\n" + text[-1500:]

            refined = ask_ai(text)

            if refined:
                data["metadata"]["title"] = refined.get("title", "")
                data["metadata"]["authors"] = refined.get("authors", [])
                data["metadata"]["publish_year"] = refined.get("publish_year", None)
                data["metadata"]["keywords_author"] = refined.get("keywords_author", [])
                data["metadata"]["publisher"] = refined.get("affiliation", "")
                data["content"]["ai_summary"] = refined.get("abstract", "")
                data["system"]["status"] = "refined"
            else:
                data["system"]["status"] = "failed"

            fout.write(json.dumps(data, ensure_ascii=False) + "\n")
            fout.flush()

            time.sleep(0.8)

    print(f"✅ DONE {name}")


# ==============================
# MAIN
# ==============================
def main():
    for f in FILES_TO_PROCESS:
        process_file(f["input"], f["output"], f["group_name"])

    print("\n🏆 ALL DONE")


if __name__ == "__main__":
    main()