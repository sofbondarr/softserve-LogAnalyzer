# 🔍 Bash Log Analyzer

This is a simple yet powerful Bash script that analyzes a log file for:

- ✅ Counting started and stopped services
- 🔐 Extracting and checking passwords
- 🚫 Detecting weak passwords based on a blacklist and complexity rules
- 🎨 Color-coded output (strong = green, weak = red)

---

## 📁 Files

- `ssa_log_analyze.sh` – the main log analyzer script  
- `weak_psswd_list.txt` – a file with weak/common passwords (one per line)  
- `test_log.txt` – your input log file to analyze

---

## 🚀 How to Use

```bash
bash ssa_log_analyze.sh test_log.txt
