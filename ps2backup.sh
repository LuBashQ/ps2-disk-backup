#!/usr/bin/env bash

fail() {
  echo "$@"
  exit 1
}

usage() {
  echo "Usage: $0 [-h|--help] [-c|--compress] -i|--device <block_device> -o|--output <output_file>"
  echo ""
  echo "-h,--help       Print usage"
  echo "-c,--compress   Compress the ripped image into a CHD file (requires chdman)"
  echo "-i,--device     The input block device"
  echo "-o,--output     The destination file (with .iso extension)"
}

# If no arguments given, print usage and exit
if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]] do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -c|--compress)
      compress=true
      shift # Skip argument
      ;;
    -i|--device) # Block device
      block_device=$2
      shift # Skip argument
      shift # Skip value
      ;;
    -o|--output) # Output file
      output_file=$(realpath $2)
      shift # Skip argument
      shift # Skip value
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage 
      exit 1
      ;;
    *) ;;
  esac
done

if [[ ! -e $block_device ]]; then
  fail "$block_device not found. Aborting."
fi

file_directory=$(dirname $output_file)
if [[ ! -d $file_directory ]]; then
  fail "Directory $file_directory does not exist. Aborting."
fi

if [[ -f $output_file ]]; then
  read -p "File $output_file already exists. Overwrite? (y|N) " overwrite
  case $overwrite in
    [yY]) ;;
    *) fail "Aborting." ;;
  esac
fi

echo "Reading from $block_device"
disk_info=$(isosize -x $block_device)

sector_count=$(echo $disk_info | awk '{printf substr($3, 1, length($3)-1)}')
sector_size=$(echo $disk_info | awk '{printf $6}')
echo "Sector info: size=$sector_size, count=$sector_count"

read -p "Ripping from $block_device into $output_file. Proceed? (y/N) " confirm

case $confirm in
  [yY])
    dd if=$block_device of=$output_file bs=$sector_size count=$sector_count status=progress || exit 1

    if [[ $compress ]]; then
      compressed_output_file=${output_file/iso/"chd"}
      chdman createcd -i $output_file -o $compressed_output_file -np $(nproc) || exit 1

      read -p "Delete original file? (y|N) " delete_original_output
      [[ $delete_original_output ]] && rm $output_file
    fi
    ;;
  *) echo "Ripping aborted.";;
esac
