# tileCSVmerge
Merge multiple ACS sequence data files

Used to stage data to be joined with census vector tilesets.


Prerequisites: You must have gsutil installed.  Using a Google Cloud Instance will set this up automatically.

This is a very memory intensive process.  I suggest you use a high-RAM cloud instance to run this script.

```
git clone https://github.com/royhobbstn/tileCSVmerge.git

cd tileCSVmerge

bash create_multisequence_files.sh
```
