#Log file to record UUIDs
UUID_LOG="uuid_log.txt"
ACTIVITY_LOG="activity_log.txt"

#Function to log user activity and script commands
log_activity() {
    user=$(whoami)
    timestamp=$(date)
    pid=$$
    subpid=$(ps -o pid= --ppid $$)
    command="$@"
    echo "User: $user | Timestamp: $timestamp | PID: $pid | SubPID: $subpid | Command: $command" >> $ACTIVITY_LOG
}

#Function to check for UUID collisions
check_collision() {
    uuid=$1
    if grep -q "$uuid" "$UUID_LOG"; then
        echo "Collision detected: $uuid"
    else
        echo "$uuid | Generated at: $(date)" >> "$UUID_LOG"
        echo "UUID: $uuid"
    fi
}

#Function to generate UUID v1
generate_uuid_v1() {
    uuid=$(powershell.exe -Command "[guid]::NewGuid()")
    check_collision "$uuid"
}

#Function to generate UUID v4
generate_uuid_v4() {
     uuid=$(powershell.exe -Command "[guid]::NewGuid()")

    #Call the check_collision function to verify the generated UUID for collisions
    check_collision "$uuid"
}

#Function to generate UUID based on version
generate_uuid() {
    version=$1
    case $version in
        1) generate_uuid_v1 ;;
        4) generate_uuid_v4 ;;
        *) echo "Invalid UUID version. Use 1 or 4." ;;
    esac
}

#Function to categorise content in a chosen directory
analyze_directory() {
    directory="$1"
    output_file="$2"

    if [ ! -d "$directory" ]; then
        echo "Directory '$directory' does not exist."
        return 1
    fi

    echo "Analyzing directory: $directory"
    echo "Results:" > "$output_file"

    for subdir in "$directory"/*/; do
        subdir_name=$(basename "$subdir")
        echo "Directory: $subdir_name"
        echo "Directory: $subdir_name" >> "$output_file"

        #File types and counts
        file_types=$(find "$subdir" -type f | sed -e 's/.*\.//' | sort | uniq -c)
        echo "File types and counts:"
        echo "$file_types" >> "$output_file"

        #Total space used
        total_size=$(du -sh "$subdir" | cut -f1)
        echo "Total space used: $total_size"
        echo "Total space used: $total_size" >> "$output_file"

        #Shortest and longest filename
        shortest_filename=$(find "$subdir" -type f -printf "%f\n" | awk '{print length, $0}' | sort -n | head -n 1 | cut -d ' ' -f 2-)
        longest_filename=$(find "$subdir" -type f -printf "%f\n" | awk '{print length, $0}' | sort -nr | head -n 1 | cut -d ' ' -f 2-)
        echo "Shortest filename: $shortest_filename"
        echo "Shortest filename: $shortest_filename" >> "$output_file"
        echo "Longest filename: $longest_filename"
        echo "Longest filename: $longest_filename" >> "$output_file"
        
        echo "" 
    done
}

#Command for script
if [ $# -eq 0 ]; then
    echo "Usage: $0 [uuid version (1 or 4) | analyze <directory> <output_file> | log <command>]"
    exit 1
fi

case "$1" in
    1|4) generate_uuid "$1" ;;  #creating uuid
    analyze) analyze_directory "$2" "$3" ;;  #Directory analysis
    log) log_activity "${@:2}" ;;  #Log activity
    *) echo "Invalid argument. Use 1 or 4 for UUID, analyze <dir> <out> for directory, or log <command> for activity." ;;
esac
