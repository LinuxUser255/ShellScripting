# Git Cheat Sheet - LinuxSecure Repository Management

## Repository Information
- **Main Repo:** `git@gitlab.com:LinuxUser255/linuxsecure.git`
- **Primary Branches:** `main`, `dev`, `rebrand-linuxsecure-fleet`

## Essential Git Commands

###  Status & Information

```bash
# Check current status
git status

# Check current branch and tracking info
git branch -vv

# List all branches (local and remote)
git branch -a

# Show commit history (no pager for scripts)
git --no-pager log --oneline -10
git --no-pager log --oneline --graph main..rebrand-linuxsecure-fleet

# Check which branches contain a specific commit
git branch --contains <commit-hash>

# Show short status
git --no-pager status --short
git --no-pager status --porcelain
```

### 📥 Fetching & Pulling

```bash
# Fetch all remote changes without merging
git fetch --all

# Update current branch from remote
git pull origin main

# Pull with rebase to avoid merge commits
git pull --rebase origin main

# Fetch and prune deleted remote branches
git fetch --prune
```

### 📤 Pushing Changes

```bash
# Push current branch to remote
git push

# Push to specific remote and branch
git push origin main

# Push a new branch to remote
git push -u origin <branch-name>

# Force push (use with caution!)
git push --force-with-lease origin <branch>

# Push all tags
git push --tags

# Delete remote branch
git push origin --delete <branch-name>
```

### 🔀 Branching

```bash
# Create new branch
git branch <branch-name>

# Create and switch to new branch
git checkout -b <branch-name>

# Switch branches
git checkout main
git checkout dev

# Create backup branch with timestamp
git branch backup-$(date +%Y%m%d-%H%M%S)
git branch backup-main-$(date +%Y%m%d-%H%M%S)

# Delete local branch
git branch -d <branch-name>  # Safe delete
git branch -D <branch-name>  # Force delete

# Rename branch
git branch -m <old-name> <new-name>
```

### 🔄 Merging

```bash
# Merge branch into current branch
git merge <branch-name>

# Merge with explicit commit message
git merge --no-ff <branch> -m "Merge message"

# Test merge without committing (dry run)
git merge --no-commit --no-ff <branch>

# Abort merge in progress
git merge --abort

# Example: Merge rebrand-linuxsecure-fleet into main
git checkout main
git pull origin main
git merge --no-ff rebrand-linuxsecure-fleet -m "Merge rebrand-linuxsecure-fleet: Complete LinuxSecure rebranding and Fleet integration"
git push origin main
```

### ♻️ Rebasing

```bash
# Rebase current branch onto main
git rebase main

# Interactive rebase last N commits
git rebase -i HEAD~N

# Rebase onto specific branch
git rebase <target-branch>

# Continue rebase after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip current commit during rebase
git rebase --skip
```

### 🔍 Git Grep & Search Commands

```bash
# Search for text in all files
git grep "HARDN"
git grep -n "LinuxSecure"  # With line numbers
git grep -i "fleet"         # Case insensitive

# Search in specific file types
git grep "TODO" -- "*.rs"
git grep "FIXME" -- "*.sh"

# Search and show context
git grep -C 3 "pattern"     # 3 lines context
git grep -B 2 "pattern"     # 2 lines before
git grep -A 2 "pattern"     # 2 lines after

# Count occurrences
git grep -c "Legion"

# Search in specific branch
git grep "pattern" <branch-name>

# Search commit messages
git log --grep="rebrand"
git log --grep="HARDN.*LinuxSecure" --regexp-ignore-case
```

### 📊 Diff & Comparison

```bash
# Show unstaged changes
git diff

# Show staged changes
git diff --staged
git diff --cached

# Compare branches
git diff main..rebrand-linuxsecure-fleet
git diff main...rebrand-linuxsecure-fleet  # Three dots = changes since divergence

# Show files changed between branches
git diff --name-only main..dev
git diff --stat main..dev

# Show diff without pager
git --no-pager diff
```

### 🏷️ Tagging

```bash
# List tags
git tag

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Create lightweight tag
git tag v1.0.0-beta

# Push specific tag
git push origin v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

### 🧹 Cleanup & Maintenance

```bash
# Remove untracked files (dry run)
git clean -n

# Remove untracked files and directories
git clean -fd

# Garbage collection and optimization
git gc
git gc --prune=now --aggressive

# Verify repository integrity
git fsck

# Remove local branches merged into main
git branch --merged main | grep -v "main" | xargs -r git branch -d
```

## 📝 LinuxSecure-Specific Git Workflows

### Renaming/Rebranding Workflow
```bash
# Find all occurrences of old name
git grep -l "HARDN" | xargs sed -i 's/HARDN/LinuxSecure/g'
git grep -l "hardn" | xargs sed -i 's/hardn/linsec/g'
git grep -l "Legion" | xargs sed -i 's/Legion/Fleet/g'

# Check what was renamed
git diff --name-status
git status --porcelain | grep "^R"
```

### Service File Management
```bash
# Find all systemd service files
git ls-files "systemd/*.service"
git ls-files "**/linuxsecure*.service"

# Track service file changes
git log --follow systemd/linuxsecure.service
```

### Module and Tool Tracking
```bash
# List all shell scripts in tools
git ls-files "usr/share/linuxsecure/tools/*.sh"

# Find recently modified modules
git log --since="1 week ago" -- "usr/share/linuxsecure/modules/"

# Check tool additions/removals
git diff --name-status main..dev -- "usr/share/linuxsecure/tools/"
```

## 🚀 Useful One-Liners

```bash
# Show commits by author
git log --author="Chris" --oneline

# Find deleted files
git log --diff-filter=D --summary

# Show commits modifying specific file
git log --follow -p -- src/main.rs

# List contributors
git shortlog -sn

# Show commit count by author
git shortlog -sn --no-merges

# Find large files in history
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print $3,$4}' | sort -n -k1 | tail -20

# Show files changed in last commit
git show --name-only HEAD

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Show remote URL
git remote -v
git remote get-url origin

# Change remote URL
git remote set-url origin git@gitlab.com:LinuxUser255/linuxsecure.git
```

## ⚠️ Emergency Commands

```bash
# Recover deleted branch
git reflog
git checkout -b <branch-name> <commit-hash>

# Reset to remote state (DESTRUCTIVE!)
git fetch origin
git reset --hard origin/main

# Stash changes temporarily
git stash
git stash pop
git stash list
git stash drop

# Cherry-pick specific commit
git cherry-pick <commit-hash>

# Revert a commit (creates new commit)
git revert <commit-hash>
```

## 🔐 GitLab-Specific

```bash
# Clone via SSH
git clone git@gitlab.com:LinuxUser255/linuxsecure.git

# Clone via HTTPS
git clone https://gitlab.com/LinuxUser255/linuxsecure.git

# Add GitLab remote
git remote add origin git@gitlab.com:LinuxUser255/linuxsecure.git

# Create merge request from command line
git push -o merge_request.create -o merge_request.target=main origin feature-branch
```

## 📋 Project Rules Reminder
- **NEVER** execute LinuxSecure/linsec binary on development machine
- **ALWAYS** test in VirtualBox VM
- **ALWAYS** create backup branches before major merges
- **COMMIT** messages should be descriptive
- **PUSH** to GitLab regularly for backup

## 🎯 Quick Reference Aliases
Add these to your `.zshrc` or `.bashrc`:

```bash
alias gs='git status'
alias gp='git push'
alias gl='git --no-pager log --oneline -10'
alias gd='git diff'
alias gc='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gf='git fetch --all'
alias gm='git merge'
alias gr='git remote -v'
```

---
*Generated for LinuxSecure repository management - October 2025*jjj

