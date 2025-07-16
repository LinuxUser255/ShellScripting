#!/usr/bin/env bash

# SIMPLE CASE CONVERSION EXERCISE
#--------------------------------
#TODO Convert this to simple case
#TODO Convert this to simple case
#TODO Convert this to simple case
#TODO Convert this to simple case
#TODO Convert this to simple case
#TODO Convert this to simple case
#TODO Convert this to simple case

echo ''
echo 'Select an Ollama Model to run.'
echo ''

# Function to check if model is pulled, pull if not, and then run
check_pull_and_run() {
    local model=$1

    # Check if model is already downloaded, and if not install it
    if ! ollama list | rg -q "$model"; then
        echo "Model $model not found. Pulling..."
        ollama pull $model
    fi

    # Try to run the model
    echo "Running $model..."
    if ! ollama run $model; then
        # If running fails due to version mismatch, update Ollama
        echo "Updating Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo "Retrying with $model..."
        ollama run $model
    fi
}

# Function to handle model selection
handle_model() {
    case $1 in
        A) check_pull_and_run gemma3:latest ;;
        B) check_pull_and_run qwen3:8b ;;
        C) check_pull_and_run devstral:24b ;;
        D) check_pull_and_run deepseek-r1:latest ;;
        E) check_pull_and_run deepseek-coder-v2:latest ;;
        F) check_pull_and_run llama4:latest ;;
        G) check_pull_and_run qwen2.5vl:latest ;;
        H) check_pull_and_run llama3.3 ;;
        I) check_pull_and_run codellama:latest ;;
        J) check_pull_and_run starcoder2 ;;
        K) check_pull_and_run codegemma:2b ;;
        L) check_pull_and_run phi4 ;;
        M) check_pull_and_run mistral ;;
        N) check_pull_and_run qwen2.5-coder:latest;;
        O) check_pull_and_run deepseek-v3:latest;;
        *) echo "Invalid selection" ;;
    esac
}

# Display menu
echo "A: gemma3"
echo "B: qwen3"
echo "C: devstral"
echo "D: deepseek-r1"
echo "E: deepseek-coder-v2"
echo "F: llama4"
echo "G: qwen2.5vl"
echo "H: llama3.3"
echo "I: codellama"
echo "J: starcoder2"
echo "K: codegemma"
echo "L: phi4"
echo "M: mistral"
echo "N: qwen2.5-coder"
echo "O: deepseek-v3"
echo ''

# Prompt user for selection
#read -p "Enter your choice (A-M): " choice
read -p "Enter your choice (A/B/C/D/E/F/G/H/I/J/K/L/M/N/O): " choice

# Convert to uppercase
choice=$(echo $choice | tr '[:lower:]' '[:upper:]')

# Handle the selected model
handle_model $choice

