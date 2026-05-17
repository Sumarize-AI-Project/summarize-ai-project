import re
import math
import unicodedata
from collections import Counter
from typing import Optional
import numpy as np

VI_STOPWORDS = {
    "và", "là", "của", "có", "cho", "trong", "được", "với", "các", "những",
    "một", "này", "đó", "khi", "từ", "đến", "trên", "dưới", "về", "theo",
    "tại", "bởi", "do", "nên", "đã", "đang", "sẽ", "rằng", "thì", "mà",
    "như", "hoặc", "nếu", "để", "ra", "vào", "sau", "trước", "giữa",
    "bị", "bằng", "không", "cũng", "nhiều", "ít", "hơn", "nhất", "gồm",
    "qua", "lại", "năm", "ngày", "tháng", "bài", "báo", "nghiên", "cứu",
    "tỷ", "lệ", "kết", "quả",
}

IMPORTANT_TERMS = {
    "mục tiêu", "phương pháp", "kết quả", "kết luận", "tóm tắt", "tổng quan",
    "tóm lại", "nhìn chung", "giai đoạn", "chính sách", "tổ chức",
    "quản lý", "biến động", "lãnh thổ", "phát triển", "thực thi", "chủ quyền",
    "ảnh hưởng", "vai trò", "ý nghĩa", "đánh giá", "tác động", "đặc điểm",
    "đối tượng", "quá trình", "phân tích"
}

SECTION_HEADINGS = [
    "ĐẶT VẤN ĐỀ",
    "MỞ ĐẦU",
    "GIỚI THIỆU",
    "ĐỐI TƯỢNG VÀ PHƯƠNG PHÁP",
    "PHƯƠNG PHÁP NGHIÊN CỨU",
    "KẾT QUẢ",
    "BÀN LUẬN",
    "KẾT LUẬN",
    "TỔNG KẾT",
]

def _nfc(text: str) -> str:
    return unicodedata.normalize("NFC", text or "")

def _strip_accents(text: str) -> str:
    text = unicodedata.normalize("NFD", text)
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    return text.replace("đ", "d").replace("Đ", "D")

def _squeeze(text: str) -> str:
    text = _nfc(text or "")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\s+([,.;:!?%])", r"\1", text)
    text = re.sub(r"([(])\s+", r"\1", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()

def word_count(text: str) -> int:
    return len((text or "").split())

def extract_title(raw_text: str) -> str:
    text = _nfc(raw_text)
    lines = []
    for line in text.splitlines():
        line = _squeeze(line)
        if len(line.split()) >= 8 and not re.search(r"doi|tạp chí|bản quyền", line, re.I):
            lines.append(line)
    return lines[0] if lines else "Tài liệu khoa học/Nghiên cứu"

def clean_pdf_body_text(raw_text: str) -> str:
    text = _nfc(raw_text).replace("\r", "\n")
    text = re.sub(
        r"(?is)\bTÓM TẮT\b.*?\bTừ kh[oó]a\b.*?(?=\bĐẶT VẤN ĐỀ\b|\bI\.\s*ĐẶT VẤN ĐỀ\b|\b1\.\s*ĐẶT VẤN ĐỀ\b|\bGIỚI THIỆU\b)",
        " ",
        text,
    )
    text = re.sub(
        r"(?is)\bABSTRACT\s*:?.*?\bKeywords?\b.*?(?=\bTÓM TẮT\b|\bĐẶT VẤN ĐỀ\b|\bI\.\s*ĐẶT VẤN ĐỀ\b|\bGIỚI THIỆU\b)",
        " ",
        text,
    )
    text = re.split(r"(?im)^\s*(TÀI LIỆU THAM KHẢO|REFERENCES)\s*$", text)[0]

    body_start = None
    for pat in [
        r"(?im)^\s*(I\.|1\.)?\s*ĐẶT VẤN ĐỀ\s*$",
        r"(?im)^\s*(I\.|1\.)?\s*MỞ ĐẦU\s*$",
        r"(?im)^\s*(I\.|1\.)?\s*GIỚI THIỆU\s*$",
    ]:
        m = re.search(pat, text)
        if m:
            body_start = m.start()
            break
    if body_start is not None:
        text = text[body_start:]

    noise_patterns = [
        r"^Tạp chí Khoa học", r"^Tập\s+\d+", r"^Bản quyền", r"^DOI\s*:",
        r"^https?://", r"^\*?Tác giả liên hệ", r"^Điện thoại\s*:", r"^Email\s*:",
        r"^Thông tin bài đăng", r"^Ngày nhận bài\s*:", r"^Ngày phản biện\s*:",
        r"^Ngày duyệt bài\s*:", r"^PGS\.?TS", r"^TS\.", r"^ThS\.", r"^GS\.", r"^BS\.",
        r"^Viện\s+", r"^Trường Đại học",
    ]

    kept = []
    for line in text.splitlines():
        line = _squeeze(line)
        if not line:
            kept.append("")
            continue
        if re.fullmatch(r"\d{1,3}", line):
            continue
        if any(re.search(p, line, flags=re.IGNORECASE) for p in noise_patterns):
            continue
        
        letters = len(re.findall(r"[A-Za-zÀ-ỹĐđ]", line))
        digits = len(re.findall(r"\d", line))
        if len(line.split()) <= 4 and digits > letters:
            continue
        kept.append(line)

    text = "\n".join(kept)
    text = re.sub(r"(?<=\w)-\n(?=\w)", "", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"(?<!\n)\n(?!\n)", " ", text)
    text = re.sub(r"[ \t]{2,}", " ", text)
    return _squeeze(text)

def protect_abbreviations(text: str) -> str:
    protected = {
        "cs.": "cs<dot>", "ThS.": "ThS<dot>", "TS.": "TS<dot>",
        "BS.": "BS<dot>", "PGS.": "PGS<dot>", "GS.": "GS<dot>",
        "vs.": "vs<dot>", "v.v.": "vv<dot>"
    }
    for k, v in protected.items():
        text = text.replace(k, v)
    return text

def unprotect_abbreviations(text: str) -> str:
    return text.replace("<dot>", ".")

def split_sentences(text: str) -> list[str]:
    text = protect_abbreviations(_squeeze(text))
    for h in SECTION_HEADINGS:
        text = re.sub(rf"\b{re.escape(h)}\b", f". {h}. ", text, flags=re.IGNORECASE)

    raw_sents = re.split(r"(?<=[.!?])\s+(?=[A-ZÀ-ỸĐ0-9])", text)
    sentences = []

    for s in raw_sents:
        s = unprotect_abbreviations(_squeeze(s))
        if not s:
            continue
        wc = word_count(s)
        if wc < 7 or wc > 90:
            continue
        if re.search(r"(?i)\b(tạp chí|doi|bản quyền|email|điện thoại)\b", s):
            continue
        if re.search(r"\bKIẾN NGHỊ\b", s, flags=re.IGNORECASE):
            s = re.split(r"\bKIẾN NGHỊ\b", s, flags=re.IGNORECASE)[0].strip()
            if word_count(s) < 7:
                continue
                
        table_markers = [
            r"nguyên nhân\s*\( ?% ?\)", r"\bBảng\s+\d+", r"\bBiểu đồ\s+\d+", r"\bHình\s+\d+", r"\(N\s*="
        ]
        if sum(1 for p in table_markers if re.search(p, s, flags=re.IGNORECASE)) >= 2:
            continue
            
        alpha = len(re.findall(r"[A-Za-zÀ-ỹĐđ]", s))
        if alpha < 20:
            continue
        sentences.append(s)

    out, seen = [], set()
    for s in sentences:
        key = _strip_accents(s.lower())
        key = re.sub(r"[^a-z0-9à-ỹđ]+", " ", key)
        key = " ".join(key.split()[:18])
        if key in seen:
            continue
        seen.add(key)
        out.append(s)
    return out

def tokenize_for_rank(sentence: str) -> list[str]:
    s = _strip_accents(sentence.lower())
    words = re.findall(r"[a-zA-ZÀ-ỹĐđ]{2,}", s)
    return [w for w in words if w not in VI_STOPWORDS and len(w) >= 2]

def build_tfidf_matrix(sentences: list[str], max_terms: int = 1200) -> np.ndarray:
    tokenized = [tokenize_for_rank(s) for s in sentences]
    df = Counter()
    tf_list = []
    for toks in tokenized:
        tf = Counter(toks)
        tf_list.append(tf)
        df.update(tf.keys())

    terms = [t for t, c in df.most_common(max_terms) if c >= 2 or len(sentences) < 30]
    vocab = {t: i for i, t in enumerate(terms)}
    n = len(sentences)
    mat = np.zeros((n, len(vocab)), dtype=np.float32)

    for i, tf in enumerate(tf_list):
        for term, count in tf.items():
            j = vocab.get(term)
            if j is None:
                continue
            idf = math.log((1 + n) / (1 + df[term])) + 1.0
            mat[i, j] = (1.0 + math.log(count)) * idf

    norms = np.linalg.norm(mat, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    return mat / norms

def pagerank_scores(similarity: np.ndarray, damping: float = 0.85, max_iter: int = 100, tol: float = 1e-6) -> np.ndarray:
    n = similarity.shape[0]
    if n == 0:
        return np.array([])
    W = similarity.copy()
    np.fill_diagonal(W, 0.0)
    W[W < 0.05] = 0.0
    row_sums = W.sum(axis=1, keepdims=True)
    W = np.divide(W, row_sums, out=np.zeros_like(W), where=row_sums != 0)
    scores = np.ones(n, dtype=np.float32) / n
    base = (1.0 - damping) / n
    for _ in range(max_iter):
        new_scores = base + damping * (W.T @ scores)
        if np.linalg.norm(new_scores - scores, ord=1) < tol:
            scores = new_scores
            break
        scores = new_scores
    return scores

def section_bonus(sentence: str) -> float:
    s = sentence.lower()
    bonus = 1.0
    if any(term in s for term in IMPORTANT_TERMS):
        bonus += 0.18
    if re.search(r"(?i)\b(mục tiêu|phương pháp|kết quả|kết luận|tóm tắt|tổng quan)\b", s):
        bonus += 0.08
    return bonus

def clean_sentence_for_display(sentence: str) -> str:
    s = _squeeze(sentence)
    s = re.split(r"\bKIẾN NGHỊ\b", s, flags=re.IGNORECASE)[0]
    s = re.sub(r"\s*\(\d+\)\s*", " ", s)
    s = re.sub(r"\s*\[\d+(?:\s*,\s*\d+)*\]\s*", " ", s)
    s = re.sub(r"\b(BÀN LUẬN|KẾT LUẬN|KẾT QUẢ|PHƯƠNG PHÁP NGHIÊN CỨU)\b", " ", s, flags=re.IGNORECASE)
    s = re.sub(r"\s+([,.;:!?%])", r"\1", s)
    s = re.sub(r"\.{2,}", ".", s)
    s = re.sub(r"\s{2,}", " ", s)
    return _squeeze(s)

def select_sentences_textrank(
    sentences: list[str],
    base_scores: np.ndarray,
    target_words: int = 500,
    min_words: int = 320,
    redundancy_threshold: float = 0.72,
) -> list[dict]:
    if not sentences:
        return []
    mat = build_tfidf_matrix(sentences)
    similarity = mat @ mat.T
    final_scores = np.array([
        float(base_scores[i]) * section_bonus(sentences[i])
        for i in range(len(sentences))
    ], dtype=np.float32)

    order = list(np.argsort(-final_scores))
    selected = []
    selected_ids = []
    total_words = 0

    def is_redundant(idx: int, threshold: float = redundancy_threshold) -> bool:
        if not selected_ids:
            return False
        return max(float(similarity[idx, j]) for j in selected_ids) > threshold

    def add_idx(idx: int, *, allow_over: bool = False, threshold: float = redundancy_threshold) -> bool:
        nonlocal total_words
        if idx in selected_ids:
            return False
        raw_sent = sentences[idx]
        clean_sent = clean_sentence_for_display(raw_sent)
        if not clean_sent:
            return False
        wc = word_count(clean_sent)
        upper_words = target_words + max(60, int(target_words * 0.15))

        if (not allow_over) and total_words >= min_words and total_words + wc > upper_words:
            return False
        if total_words + wc > upper_words:
            return False
        if is_redundant(idx, threshold=threshold):
            return False
        selected.append({
            "idx": int(idx),
            "score": float(final_scores[idx]),
            "textrank": float(base_scores[idx]),
            "word_count": wc,
            "text": raw_sent,
            "clean_text": clean_sent,
        })
        selected_ids.append(idx)
        total_words += wc
        return True

    def best_idx(pattern: str, pool: Optional[range] = None) -> Optional[int]:
        ids = list(pool) if pool is not None else list(range(len(sentences)))
        candidates = [
            i for i in ids
            if re.search(pattern, sentences[i], flags=re.IGNORECASE)
        ]
        if not candidates:
            return None
        return max(candidates, key=lambda i: final_scores[i])

    n = len(sentences)
    early_pool = range(0, max(1, min(n, int(n * 0.28))))

    seed_patterns = [
        (r"mục tiêu|mục đích|nội dung chính|tóm tắt lại|tổng quan|đặt vấn đề", early_pool),
        (r"phương pháp|cách thức|quá trình|giai đoạn|thời kỳ|tiến trình", None),
        (r"tóm lại|nhìn chung|kết luận|kết quả|cho thấy|đánh giá", None),
        (r"số liệu|tỷ lệ|thống kê|thực thi|quản lý|tác động|ý nghĩa", None),
    ]

    for pat, pool in seed_patterns:
        idx = best_idx(pat, pool)
        if idx is not None:
            add_idx(idx, allow_over=True, threshold=0.88)

    for idx in order:
        add_idx(idx)
        if total_words >= min_words:
            break

    if total_words < min_words:
        for idx in order:
            if add_idx(idx, allow_over=False, threshold=0.92):
                if total_words >= min_words:
                    break

    selected = sorted(selected, key=lambda x: x["idx"])
    return selected

def textrank_extract(text: str, target_words: int = 500) -> tuple[list[dict], list[str], np.ndarray]:
    sentences = split_sentences(text)
    if len(sentences) < 5:
        return [], sentences, np.array([])
    mat = build_tfidf_matrix(sentences)
    similarity = mat @ mat.T
    scores = pagerank_scores(similarity)
    selected = select_sentences_textrank(
        sentences=sentences,
        base_scores=scores,
        target_words=target_words,
        min_words=max(120, int(target_words * 0.90)),
    )
    return selected, sentences, scores

def extractive_summary_from_selected(selected: list[dict]) -> str:
    cleaned = []
    seen = set()
    for item in selected:
        s = item.get("clean_text") or clean_sentence_for_display(item["text"])
        if not s:
            continue
        key = re.sub(r"\W+", " ", _strip_accents(s.lower())).strip()[:120]
        if key in seen:
            continue
        seen.add(key)
        cleaned.append(s)
    if len(cleaned) <= 4:
        return _squeeze(" ".join(cleaned))
    chunks = []
    step = max(2, math.ceil(len(cleaned) / 4))
    for i in range(0, len(cleaned), step):
        chunks.append(" ".join(cleaned[i:i + step]))
    return _squeeze("\n\n".join(chunks))

def generate_extractive_summary(pdf_text: str, target_words: int = 500) -> dict:
    """Hàm chính để gom các bước lại thành 1 pipeline cho backend API."""
    title = extract_title(pdf_text)
    body_text = clean_pdf_body_text(pdf_text)
    
    # Trích xuất bản thô với dung lượng vừa đủ (1.15x) để ép LLM tóm tắt chặt chẽ hơn.
    # Nếu truyền vào quá nhiều, LLM thường có xu hướng viết dài lan man bất chấp prompt.
    extract_target = int(target_words * 1.05)
    selected, sentences, scores = textrank_extract(body_text, target_words=extract_target)
    extractive = extractive_summary_from_selected(selected)
    
    return {
        "title": title,
        "body_word_count": word_count(body_text),
        "sentence_count": len(sentences),
        "selected": selected,
        "extractive_text": extractive,
    }
