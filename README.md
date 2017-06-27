# tileCSVmerge
Merge multiple ACS sequence data files

Used to stage data to be joined with census vector tilesets.


Prerequisites: You must have gsutil installed.  Using a Google Cloud Instance will set this up automatically.

Don't skimp on your instance, and use a SSD drive.

```
sudo apt-get install git

git clone https://github.com/royhobbstn/tileCSVmerge.git

cd tileCSVmerge

bash create_multisequence_files.sh
```
