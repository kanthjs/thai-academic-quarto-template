# Check the render toolchain for a thai-book Quarto project.
# Run from the project root:  Rscript R/check-env.R
# Exit status 1 if any check fails.

results <- list()
report <- function(name, ok, detail) {
  results[[name]] <<- ok
  cat(sprintf("[%s] %-22s %s\n", if (ok) " OK " else "FAIL", name, detail))
}

run <- function(cmd, args = character()) {
  out <- tryCatch(
    suppressWarnings(system2(cmd, args, stdout = TRUE, stderr = TRUE)),
    error = function(e) character()
  )
  trimws(out)
}

# 1. Quarto >= 1.9 (the first quarto on PATH is the one `quarto render` uses)
quarto_path <- Sys.which("quarto")
quarto_ver <- run("quarto", "--version")
quarto_ok <- length(quarto_ver) > 0 &&
  !is.na(numeric_version(quarto_ver[1], strict = FALSE)) &&
  numeric_version(quarto_ver[1], strict = FALSE) >= "1.9"
report(
  "Quarto >= 1.9", quarto_ok,
  if (length(quarto_ver)) sprintf("%s at %s", quarto_ver[1], quarto_path)
  else "quarto not found on PATH"
)
if (!quarto_ok && .Platform$OS.type == "windows") {
  cat("       hint: put C:\\Program Files\\Quarto\\bin first in PATH",
      "(an old Quarto may sit in AppData\\Local\\Programs\\Quarto)\n")
}

# 2. TinyTeX / TeX Live year matches CTAN (otherwise tlmgr install fails)
tl_year <- function() {
  v <- run("tlmgr", "--version")
  y <- regmatches(v, regexpr("TeX Live \\(?[^0-9]*([0-9]{4})", v))
  if (length(y)) as.integer(sub(".*([0-9]{4}).*", "\\1", y[1])) else NA_integer_
}
local_year <- tl_year()
ctan_year <- tryCatch({
  # The CTAN mirror's TLPDB header names the current release year
  con <- url("https://mirror.ctan.org/systems/texlive/tlnet/tlpkg/texlive.tlpdb")
  on.exit(close(con), add = TRUE)
  head_lines <- readLines(con, n = 200, warn = FALSE)
  rel <- grep("^depend release/", head_lines, value = TRUE)
  as.integer(sub("^depend release/([0-9]{4}).*", "\\1", rel[1]))
}, error = function(e) NA_integer_)
report(
  "TeX Live = CTAN year",
  !is.na(local_year) && (is.na(ctan_year) || local_year == ctan_year),
  sprintf("local %s, CTAN %s%s",
          ifelse(is.na(local_year), "not found", local_year),
          ifelse(is.na(ctan_year), "unknown", ctan_year),
          ifelse(is.na(ctan_year), " (offline? year not compared)", ""))
)
if (!is.na(local_year) && !is.na(ctan_year) && local_year != ctan_year) {
  cat("       hint: tinytex::reinstall_tinytex(packages = TRUE)\n")
}

# 3. Fonts that the PDF format loads by name from TeX Live
for (f in c("DejaVuSansMono.ttf", "latinmodern-math.otf")) {
  hit <- run("kpsewhich", f)
  ok <- length(hit) > 0 && nzchar(hit[1]) && file.exists(hit[1])
  report(paste("kpsewhich", f), ok,
         if (ok) hit[1] else "missing: tlmgr install dejavu lm-math")
}

# 4. Google Sans files reachable through the Path= in the extension
#    (XeLaTeX runs in the project root, so Path= is relative to it)
ext_yml <- Sys.glob(c("_extensions/thai-book/_extension.yml",
                      "_extensions/*/thai-book/_extension.yml"))
if (length(ext_yml) == 0) {
  report("thai-book extension", FALSE, "no _extensions/**/thai-book/_extension.yml")
} else {
  yml <- readLines(ext_yml[1], warn = FALSE, encoding = "UTF-8")
  # option line may be plain (- Path=...) or raw LaTeX (- "`Path=...`{=latex}")
  path_line <- grep("^\\s*-.*Path=", yml, value = TRUE)[1]
  font_dir <- if (is.na(path_line)) NA_character_
              else trimws(sub(".*Path=([^ #`\"]+).*", "\\1", path_line))
  need <- sprintf("GoogleSans-%s.ttf", c("Regular", "Bold", "Italic"))
  have <- !is.na(font_dir) & file.exists(file.path(font_dir, need))
  report("fonts/ reachable", all(have),
         if (all(have)) sprintf("%s (%d files)", font_dir, length(need))
         else sprintf("missing in %s: %s", font_dir, paste(need[!have], collapse = ", ")))
}

if (!all(unlist(results))) quit(status = 1)
cat("All checks passed.\n")
