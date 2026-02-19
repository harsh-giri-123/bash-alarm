#!/bin/bash

# banner to display
banner() {
echo "   █████████   ████                                                    ███                       ███                      ███";
echo "  ███▒▒▒▒▒███ ▒▒███                                                   ▒▒▒                       ▒▒▒                      ▒███";
echo " ▒███    ▒███  ▒███   ██████   ████████  █████████████      ████████  ████  ████████    ███████ ████  ████████    ███████▒███";
echo " ▒███████████  ▒███  ▒▒▒▒▒███ ▒▒███▒▒███▒▒███▒▒███▒▒███    ▒▒███▒▒███▒▒███ ▒▒███▒▒███  ███▒▒███▒▒███ ▒▒███▒▒███  ███▒▒███▒███";
echo " ▒███▒▒▒▒▒███  ▒███   ███████  ▒███ ▒▒▒  ▒███ ▒███ ▒███     ▒███ ▒▒▒  ▒███  ▒███ ▒███ ▒███ ▒███ ▒███  ▒███ ▒███ ▒███ ▒███▒███";
echo " ▒███    ▒███  ▒███  ███▒▒███  ▒███      ▒███ ▒███ ▒███     ▒███      ▒███  ▒███ ▒███ ▒███ ▒███ ▒███  ▒███ ▒███ ▒███ ▒███▒▒▒ ";
echo " █████   █████ █████▒▒████████ █████     █████▒███ █████    █████     █████ ████ █████▒▒███████ █████ ████ █████▒▒███████ ███";
echo "▒▒▒▒▒   ▒▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒▒▒▒ ▒▒▒▒▒     ▒▒▒▒▒ ▒▒▒ ▒▒▒▒▒    ▒▒▒▒▒     ▒▒▒▒▒ ▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒███▒▒▒▒▒ ▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒███▒▒▒ ";
echo "                                                                                       ███ ▒███                  ███ ▒███    ";
echo "                                                                                      ▒▒██████                  ▒▒██████     ";
echo "                                                                                       ▒▒▒▒▒▒                    ▒▒▒▒▒▒      ";
echo "                                                                                                                             ";
echo "                                                                                              - made by harsh giri           ";
}

# Prompt user for the alarm time in HH:MM format
read -p "Enter the alarm time (HH:MM): " alarm_time


# Prompt user for the alarm repeat time in MM format
read -p "Enter repeat time in minutes (or type 'never' to skip repeating): " repeat_time

# Function to set a repeat alarm
repeat_alarm() {
    if [[ "$repeat_time" == "never" ]]; then
        echo "The alarm is set to not repeat."
    elif [[ "$repeat_time" =~ ^[0-9]+$ ]]; then
        repeat_seconds=$((repeat_time * 60))
        # Prompt user for the number of times to repeat
        read -p "Enter number of times to repeat the alarm: " repeat_count
        echo "The alarm will repeat every $repeat_time minutes for $repeat_count times"
    else
        echo "Invalid input. Setting alarm to not repeat."
    fi
};repeat_alarm

# Convert time to seconds since midnight for comparison
IFS=: read alarm_hour alarm_minute <<< "$alarm_time"
alarm_seconds=$((10#$alarm_hour * 3600 + 10#$alarm_minute * 60))

# Get the current time in seconds since midnight
current_time=$(date +%s)
current_hour=$(date +%H)
current_minute=$(date +%M)
current_seconds=$((10#$current_hour * 3600 + 10#$current_minute * 60))

# Calculate the time to wait until the alarm
if [ "$alarm_seconds" -lt "$current_seconds" ]; then
    echo "The specified time has already passed. Please enter a future time."
    exit 1
fi

# Calculate the difference in seconds
time_diff=$((alarm_seconds - current_seconds))


# Get the path of mpv
mpv_path=$(command -v mpv)

# Check if mpv is installed
if [ -n "$mpv_path" ]; then
    :
else
    echo "mpv is not installed."
    echo "install mpv using this command : sudo apt install mpv"
fi

###### chose alarm tune 

# Define the directory containing alarm sounds
alarm_sound_dir="alarm_sounds"

# Check if the directory exists
if [ ! -d "$alarm_sound_dir" ]; then
    echo "The alarm sound directory does not exist."
    exit 1
fi

# List the available sounds
echo "Available alarm sounds:"

# Temporarily store only the base filenames in an array for display
sounds=()
for file in "$alarm_sound_dir"/*; do
    sounds+=("$(basename "$file")")  # Get the filename only
done

select sound in "${sounds[@]}"; do
     
    # Remove the prefix for display
    sound_name=$(basename "$sound")

    # Check if a valid option was chosen
    if [[ -n "$sound" ]]; then
        echo "You have selected: $sound_name"
        break
    else
        echo "Invalid selection. Please choose a valid sound."
    fi
done

#### real time before alarm
# Loop until the alarm time is reached
while [ $time_diff -gt 0 ]; do
    # Convert time_diff to hours, minutes, and seconds
    hours=$((time_diff / 3600))
    minutes=$(( (time_diff % 3600) / 60 ))
    seconds=$((time_diff % 60))

    # Display the countdown
    echo -ne "Time until alarm: ${hours} hours, ${minutes} minutes, and ${seconds} seconds.\r"
    
    # Wait for one second
    sleep 1
    
    # Decrease the time difference
    time_diff=$((time_diff - 1))
done

# Full path for later use
selected_sound="$alarm_sound_dir/$sound" 

# fetch banner from banner function
banner 


# Function to play the alarm sound
play_alarm_sound() {
      # Execute the MPV command to play the alarm song
      $mpv_path $selected_sound 
};play_alarm_sound

 
# Function to execute the repeat alarm if repeat_seconds is set
execute_repeat_alarm() {
    while [[ "$repeat_count" -gt 1 ]]; do
        if [[ -n "$repeat_seconds" && "$repeat_seconds" -gt 0 ]]; then
            # Wait for the specified repeat time
            sleep "$repeat_seconds"
            
            # Play the selected sound again
            echo "Repeating the alarm..."
            play_alarm_sound 
            
            # Decrement the repeat_count by 1
            ((repeat_count--))
            echo $repeat_count 
        else
            break
        fi
    done
};execute_repeat_alarm



