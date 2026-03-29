import sys
import argparse

def extract_pdf(file_path):
    try:
        import pypdf
        reader = pypdf.PdfReader(file_path)
        text = "\n".join([page.extract_text() for page in reader.pages])
        return text
    except ImportError:
        pass

    try:
        import PyPDF2
        reader = PyPDF2.PdfReader(file_path)
        text = "\n".join([page.extract_text() for page in reader.pages])
        return text
    except ImportError:
        pass

    try:
        import fitz  # PyMuPDF
        doc = fitz.open(file_path)
        text = "\n".join([page.get_text() for page in doc])
        return text
    except ImportError:
        pass

    return "ERROR: No PDF library found. Please install pypdf, PyPDF2, or PyMuPDF."

if __name__ == "__main__":
    file_path = r"c:\data_mining\Tai lieu PTTK .pdf"
    content = extract_pdf(file_path)
    if content.startswith("ERROR:"):
        print(content)
        sys.exit(1)
    
    with open(r"c:\data_mining\extracted_pdf.txt", "w", encoding="utf-8") as f:
        f.write(content)
    print("Successfully extracted PDF to extracted_pdf.txt")
