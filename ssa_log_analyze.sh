#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Using: $0 test_log.txt"
  exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: '$LOG_FILE' not found."
    exit 1
fi

#Downloading weak_psswd_list.txt
BLACKLIST=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]] && continue
    BLACKLIST+=("$line")
done < weak_psswd_list.txt

echo "Analyzing services..."
STARTED_SERVICES=$(grep -c "Finished Install" "$LOG_FILE")
STOPPED_SERVICES=$(grep -c "Finished Remove" "$LOG_FILE")
echo "Services started: $STARTED_SERVICES"
echo "Services stopped: $STOPPED_SERVICES"

#Searching for passwords in file
echo -e "\nPassword complexity check..."
PASSWORDS=$(grep -oE "admin_pass.*value=['\"][^'\"]+" "$LOG_FILE" | sed -E "s/.*value=['\"]([^'\"]+).*/\1/")

if [ -z "$PASSWORDS" ]; then
    echo "No passwords in log file."
    exit 0
fi

#Checking password complexity
check_password_complexity() {
    local password="$1"
    local forbidden_hits=()
    local problems=()
    local output=()

    #Checking length
    [ ${#password} -lt 12 ] && problems+=("less than 12 symbols")

    #Checking for symbols
    [[ "$password" =~ [a-z] ]] || problems+=("no lowercase letters")
    [[ "$password" =~ [A-Z] ]] || problems+=("no uppercase letters")
    [[ "$password" =~ [0-9] ]] || problems+=("no digits")
    [[ "$password" =~ [[:punct:]] ]] || problems+=("no special characters")

    #Checking for common words from weak_psswd_list.txt
    local lower_pass
    lower_pass=$(echo "$password" | tr '[:upper:]' '[:lower:]')
    for word in "${BLACKLIST[@]}"; do
        [[ -z "$word" || "$word" =~ ^[[:space:]]*$ ]] && continue
        local lower_word
        lower_word=$(echo "$word" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_pass" == *"$lower_word"* ]]; then
            forbidden_hits+=("$word")
        fi
    done

    #Output
    if [ ${#forbidden_hits[@]} -eq 0 ] && [ ${#problems[@]} -eq 0 ]; then
        echo -e "$password \033[32m is Strong \033[0m"
    else
        [ ${#forbidden_hits[@]} -gt 0 ] && output+=("contains common words ${forbidden_hits[*]}")
        [ ${#problems[@]} -gt 0 ] && output+=("error: ${problems[*]}")
        echo -e "$password \033[31m is Weak \033[0m (${output[*]})" #\033[31m \033[0m -- escape code для червоного
    fi
}

echo "Passwords: "
while IFS= read -r password; do
    check_password_complexity "$password"
done <<< "$(echo "$PASSWORDS" | sort | uniq)"
