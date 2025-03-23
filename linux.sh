#!/bin/bash
folder="$HOME/.cache/td"

[ ! -d "$folder" ] && mkdir -p "$folder"
[ ! -f "$folder/default.txt" ] && touch "$folder/default.txt"

view() {
  files=()
  for i in $folder/*.txt; do
    if [ -e "$i" ]; then
      files+=$( basename "$i" .txt )
    fi
  done
  if [ ${#files[@]} -gt 0 ];then
    choose=$(gum choose "${files[@]}" --header "Select a list to view")
    mapfile -t options < "$folder/$choose.txt"
    if [ ${#options[@]} -gt 0 ]; then
      choice=$(gum choose "${options[@]}" --header "Select a task to view")
      echo $choice
    else
      echo "List is empty"
    fi
  else
    echo "No list found"
    exit 0
  fi
}

add() {
  if [ -f "$file" ]; then
    name=$(gum input --placeholder "Enter task name")
    echo "$name" >> "$file"
  else
    touch "$file"
    name=$(gum input --placeholder "Enter task name")
    echo "$name" >> "$file"
  fi
}

remove() {
  if [ ! -f "$file" ]; then
    echo "List not found"
    exit 1
  else
    mapfile -t options < "$file"
    choice=$(gum choose "${options[@]}" --header "Select a task to remove:")
    grep -v "^${choice}$" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
}

removelist() {
  if [ ! -f "$file" ]; then
    echo "List not found"
    exit 1
  else
    if gum confirm "Remove the $file ?" --affirmative "Yep" --negative "Nope"; then
      rm -rf "$file"
    else
      echo "Didn't remove $file"
    fi
  fi
}


if [ "$#" -eq 0 ]; then
  view
else
  case "$1" in
    "a")
      if [ "$#" -lt 2 ]; then
        file="$folder/default.txt"
      else
        file="$folder/$2.txt"
      fi
      add
      ;;
    "r")
      if [ "$#" -lt 2 ]; then
        file="$folder/default.txt"
      else
        file="$folder/$2.txt"
      fi
      remove
      ;;
    "R")
      if [ "$#" -lt 2 ]; then
        file="$folder/default.txt"
      else
        file="$folder/$2.txt"
      fi
      removelist
      ;;
    "h")
      echo "=============================="
      echo "          | |_ __| |          "
      echo "          | __/ _\` |         "
      echo "          | || (_| |          "
      echo "           \__\__,_|          "
      echo "=============================="
      echo ""
      echo "Usage: td <arg> [options]"
      echo ""
      echo "args:"
      echo "├──a: Add a new taks"
      echo "│  └─option1: name of the list, leave blank for default"
      echo "├──r: Remove a task"
      echo "│  └─option1: name of the list, leave blank for default"
      echo "├──R: Remove a list"
      echo "│  └─option1: name of the list, leave blank for default"
      echo "└──h: Show helps"
      ;;
    *)
      echo "Unknown arg, please \"td h\" for help"
    ;;
  esac
fi
