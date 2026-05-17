import fitz
from typing import Optional

def _words_to_lines(words: list, y_tol: float = 3.0) -> str:
    if not words:
        return ""
    words = sorted(words, key=lambda w: (w[1], w[0]))
    lines = []
    cur = []
    cur_y = None
    for w in words:
        x0, y0, x1, y1, token = w[:5]
        if cur_y is None or abs(y0 - cur_y) <= y_tol:
            cur.append(w)
            cur_y = y0 if cur_y is None else (cur_y * 0.8 + y0 * 0.2)
        else:
            cur = sorted(cur, key=lambda z: z[0])
            lines.append(" ".join(str(z[4]) for z in cur))
            cur = [w]
            cur_y = y0
    if cur:
        cur = sorted(cur, key=lambda z: z[0])
        lines.append(" ".join(str(z[4]) for z in cur))
    return "\n".join(lines)

def _detect_two_column_split(words: list, page_width: float) -> Optional[float]:
    if len(words) < 80:
        return None
    centers = [float((w[0] + w[2]) / 2) for w in words]
    n_bins = 32
    counts = [0] * n_bins
    for x in centers:
        idx = min(n_bins - 1, max(0, int(x / page_width * n_bins)))
        counts[idx] += 1
    lo = int(n_bins * 0.35)
    hi = int(n_bins * 0.65)
    max_count = max(counts) or 1
    threshold = max(2, max_count * 0.18)

    best_start, best_len = -1, 0
    cur_start, cur_len = -1, 0
    for i in range(lo, hi):
        if counts[i] <= threshold:
            if cur_len == 0:
                cur_start = i
            cur_len += 1
            if cur_len > best_len:
                best_start, best_len = cur_start, cur_len
        else:
            cur_len = 0
    if best_len < 1:
        return None
    split_x = (best_start + best_len / 2) / n_bins * page_width
    left = sum(1 for x in centers if x < split_x)
    right = sum(1 for x in centers if x >= split_x)
    if left < 30 or right < 30:
        return None
    if min(left, right) / max(left, right) < 0.25:
        return None
    return split_x

def _page_text_by_columns(page) -> str:
    words = page.get_text("words")
    if not words:
        return page.get_text("text", sort=True) or ""
    page_w = float(page.rect.width)
    page_h = float(page.rect.height)
    words = [
        w for w in words
        if page_h * 0.035 <= float(w[1]) <= page_h * 0.965
    ]
    split_x = _detect_two_column_split(words, page_w)
    if split_x is None:
        return _words_to_lines(words)
    left = [w for w in words if (float(w[0]) + float(w[2])) / 2 < split_x]
    right = [w for w in words if (float(w[0]) + float(w[2])) / 2 >= split_x]
    return _words_to_lines(left) + "\n\n" + _words_to_lines(right)

def extract_text_from_pdf(pdf_path: str, max_pages: Optional[int] = None) -> str:
    """Đọc file PDF, tự động nhận diện và trích xuất text (hỗ trợ layout 2 cột)."""
    pages = []
    with fitz.open(pdf_path) as doc:
        limit = min(doc.page_count, max_pages) if max_pages else doc.page_count
        for i in range(limit):
            text = _page_text_by_columns(doc.load_page(i))
            if text and text.strip():
                pages.append(text)
    return "\n\n".join(pages)
