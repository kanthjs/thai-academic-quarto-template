# thai-academic-quarto-template

แม่แบบ Quarto สำหรับตำราวิชาการภาษาไทย ได้ทั้งฉบับเว็บและ PDF สำหรับโรงพิมพ์จากต้นฉบับเดียว
A Quarto book template for Thai academic textbooks: one source, a website and a print-ready PDF.

## มีอะไรบ้าง / What's inside

- `_extensions/kanthjs/thai-book/` คือ format extension ที่มี `thai-book-html` และ `thai-book-pdf`
  - PDF ใช้ XeLaTeX + KOMA-Script `scrbook` บนกระดาษ A4 ขอบกว้าง ตัดคำไทยด้วย `\XeTeXlinebreaklocale "th"`
  - ฟอนต์ Google Sans (มีไฟล์และ `OFL.txt` มาด้วย) DejaVu Sans Mono และ Latin Modern Math
  - เว็บใช้ theme cosmo + `custom.scss` / `custom-dark.scss`
  - ป้าย cross-reference ภาษาไทย (รูปที่ ตารางที่ สมการ) เชิงอรรถ การอ้างอิง และคำบรรยายรูปอยู่ที่ขอบ
  - knitr ใช้ `ragg_png` เพราะ device `png` ปกติบน Windows หาฟอนต์ที่ติดตั้งเองไม่เจอ
- โครงเล่มตัวอย่าง: `index.qmd`, `01-sample-chapter.qmd`, `references.bib`, `appendix-glossary.qmd`
- `R/check-env.R` ตรวจเครื่องก่อน render
- `CLAUDE-template.md` แม่แบบคำสั่งสำหรับผู้ช่วย AI (Claude Code) ใช้คัดลอกเป็น `CLAUDE.md` ของเล่ม

## เริ่มเล่มใหม่ / Start a new book

```bash
quarto use template kanthjs/thai-academic-quarto-template
```

คำสั่งนี้สร้างโฟลเดอร์เล่มใหม่ที่มีทั้ง extension และโครงเล่มตัวอย่าง จากนั้นแก้ `_quarto.yml` (ชื่อเล่ม ผู้เขียน รายชื่อบท)
This creates a new book folder with the extension and a sample skeleton. Then edit `_quarto.yml`.

## ใส่ในเล่มที่มีอยู่แล้ว / Add to an existing book

```bash
quarto add kanthjs/thai-academic-quarto-template
```

แล้วตั้งใน `_quarto.yml` / then set in `_quarto.yml`:

```yaml
format:
  thai-book-html: default
  thai-book-pdf: default
```

ค่าใดที่ใส่ใต้ `thai-book-html:` หรือ `thai-book-pdf:` ในเล่มจะทับค่าของ extension
Any option set under these keys in your book overrides the extension default.

## สิ่งที่ต้องมี / Requirements

- Quarto 1.9 ขึ้นไป (mermaid ใน PDF ต้องใช้ headless Chrome ของ Quarto รุ่นนี้)
- TinyTeX ที่เป็น TeX Live ปีเดียวกับ CTAN และแพ็กเกจ `dejavu`, `lm-math`
- R กับแพ็กเกจ `ragg` (และ `knitr`, `rmarkdown`)

ตรวจเครื่องด้วย / Check your setup:

```bash
Rscript R/check-env.R
```

```bash
quarto render                      # HTML + PDF -> _book/
quarto render --to thai-book-pdf   # PDF only
```

## ข้อควรรู้ / Gotchas

- path ของฟอนต์ (`Path=` ใน `_extension.yml` และ `url()` ใน `custom.scss`) นับจากรากโปรเจกต์
  และเขียนไว้เป็น `_extensions/kanthjs/thai-book/fonts/` ถ้าย้าย extension ไปที่อื่นต้องแก้ทั้งสองที่
  Font paths are relative to the project root; update both if you move the extension.
- ชื่อฟอนต์ PDF คือ `"GoogleSans"` (ไม่มีวรรค) เพราะ fontspec ใช้ชื่อนี้เป็นชื่อไฟล์เมื่อมี `Path=`
- ห้ามใส่การอ้างอิง `@key` ในเชิงอรรถ `^[...]` เพราะเมื่อการอ้างอิงอยู่ที่ขอบ LaTeX จะล่ม
  Don't put citations inside footnotes; with margin citations LaTeX fails.
- ห้ามเปลี่ยน `pdf-engine` เป็น pdflatex (ไม่รองรับฟอนต์ไทยแบบ Unicode)
- Windows: ถ้ามี Quarto รุ่นเก่าค้างอยู่ใน PATH ให้เช็ก `quarto --version` ก่อน render
- ไฟล์ Google Sans ที่ให้มาแตกจาก variable font ตัว Regular กับ Bold มี PostScript name ซ้ำกัน
  ตัวหนาแสดงผลถูกต้อง แต่ก่อนส่งโรงพิมพ์ควรเปลี่ยนเป็นไฟล์ static ที่ตั้งชื่อถูก

## สัญญาอนุญาต / License

โค้ดและการตั้งค่าของแม่แบบใช้สัญญาอนุญาต MIT (ดู `LICENSE`) ส่วนฟอนต์ Google Sans ใช้ SIL Open Font License 1.1 (`_extensions/kanthjs/thai-book/fonts/OFL.txt`)
The template code and configuration are MIT-licensed (see `LICENSE`); the Google Sans fonts are under the SIL OFL 1.1.
