
---

## 🛠️ Setup Your Practice Environment

1. Create a practice directory and file:

```bash
mkdir text-tools-practice && cd text-tools-practice

cat <<EOF > data.txt
ID,Name,Age,Email
1,Alice,30,alice@example.com
2,Bob,25,bob@example.com
3,Charlie,35,charlie@example.com
EOF
```

---

## 🔍 GREP PRACTICE

```bash
# Find lines containing the word 'Alice'
grep 'Alice' data.txt

# Find lines starting with '2'
grep '^2' data.txt

# Find lines that contain numbers
grep '[0-9]' data.txt

# Invert match (lines NOT containing Bob)
grep -v 'Bob' data.txt
```

---

## 🧬 SED PRACTICE (Stream Editor)

```bash
# Replace 'Bob' with 'Robert'
sed 's/Bob/Robert/' data.txt

# Replace all lowercase letters with X (global)
sed 's/[a-z]/X/g' data.txt

# Delete the header row
sed '1d' data.txt

# Append " - Active" to every line
sed 's/$/ - Active/' data.txt
```

---

## 📊 AWK PRACTICE (Field-based Processing)

```bash
# Print only the Name column (2nd field)
awk -F, '{ print $2 }' data.txt

# Print names and ages
awk -F, '{ print $2, $3 }' data.txt

# Skip the header row
awk -F, 'NR > 1 { print $2, $3 }' data.txt

# Sum all ages
awk -F, 'NR > 1 { sum += $3 } END { print "Total Age:", sum }' data.txt
```

---

## 🧰 Create a Makefile to Use These Tools

```Makefile
# Makefile in the same directory

data := data.txt

.PHONY: all grep sed awk clean

all: grep sed awk

grep:
	@echo "🔍 GREP Results:"
	@grep 'Charlie' $(data)

sed:
	@echo "🧬 SED Transformation:"
	@sed 's/@example.com/@domain.com/' $(data)

awk:
	@echo "📊 AWK Processed Output:"
	@awk -F, 'NR > 1 { print $$2 " is " $$3 " years old." }' $(data)

clean:
	@echo "🧹 Nothing to clean right now!"
```

### 🔧 Usage:

```bash
make           # runs all grep, sed, awk
make grep      # just grep
make clean     # cleanup task
```

---

## 🧠 Mini Challenge (Try Yourself)

1. Add a `make sum` target to sum all the ages.
2. Add a `make rename` target that uses `sed` to replace "Charlie" with "Chuck".
3. Add a `make count` target that uses `grep` to count how many emails are in the file.

---


