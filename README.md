# ps2-disk-backup
Backup your PS2 games to your Linux machine.

This simple script will detect the block size and number of sectors of the PS2 game disk, and will copy the contents as-is into a file to the filesystem.

Optional but highly recommended, the resulting dumped game file can be compressed into a `.chd` file using `chdman`, resulting in ~25-35% less space used. Check out the official [chdman](https://github.com/charlesthobe/chdman) repository for more info.

## Requirements

- `bash`
- `awk`
- `isosize`
- `dd`
- Optionally `chdman`

## Installation

Either run the script from the current directory, or copy it to `/usr/local/bin`.

```
sudo cp ps2dump.sh /usr/local/bin/ps2dump
```

## Usage

```
Usage: ps2dump [-h|--help] [-c|--compress] -i|--device <block_device> -o|--output <output_file>"

  -h,--help       Print usage
  -c,--compress   Compress the ripped image into a CHD file (requires chdman)
  -i,--device     The input block device
  -o,--output     The destination file (with .iso extension)
```

## Example

```
ps2dump --compress --device /dev/sr0 --output ~/games/ps2/shin_megami_tensei_3_nocturne.iso
```

**Note: the `.iso` extension is required when compressing the file!**

**Note 2: the arguments must be specified in the order shown in the usage!**
