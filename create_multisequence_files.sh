
echo "install nodeJS";
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node

echo "clean any previous installations";
rm -r node_modules
rm -r run
rm -r result

echo "install JS dependencies";
npm install

mkdir run
mkdir result

cd run

mkdir schemas
mkdir readyfiles
mkdir nocol
mkdir dl


echo "downloading census metadata";
curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt -O

echo "strip header row from metadata";
sed 1d ACS_5yr_Seq_Table_Number_Lookup.txt > no_header.csv

awk -F, '$4 ~ /^[0-9]+$/' no_header.csv > columns_list.csv

echo "populating schema files with basic column information"
n=122;for i in $(seq -f "%04g" ${n});do echo -n "KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,GEOID,NAME,BTTR,BTBG,BLANK7" > "./schemas/schema$i.txt"; done;

echo "appending additional columns to each table according to metadata"
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4`"" >> "./schemas/schema$f3.txt"; done < columns_list.csv;

echo "downloading all census estimate sequence files in bucket"
cd dl

gsutil cp gs://acs1115_stage/e*.csv


# get rid of newline
for file in *.csv ; do sed 's/,[^,]\+$//' $file > ../nocol/new$file; done;
cd ..

echo "concatenating schema and data files for each sequence"
n=122;for i in $(seq -f "%03g" ${n}); do echo -n -e ",\n" >> ./schemas/schema0$i.txt; cat ./schemas/schema0$i.txt ./nocol/neweseq$i.csv > ./readyfiles/eseq$i.csv; done;


cd ..


echo "running nodejs program to strip first 55 columns of redundant information"
node merge_columns.js

paste -d "" ./run/readyfiles/eseq001.csv ./result/eseq002.csv ./result/eseq003.csv > eseq_001_002_003.csv

paste -d "" ./run/readyfiles/eseq004.csv ./result/eseq005.csv ./result/eseq006.csv > eseq_004_005_006.csv

paste -d "" ./run/readyfiles/eseq007.csv ./result/eseq008.csv ./result/eseq009.csv > eseq_007_008_009.csv

paste -d "" ./run/readyfiles/eseq010.csv ./result/eseq011.csv ./result/eseq012.csv > eseq_010_011_012.csv


gsutil rm -r gs://acs1115_multisequence

echo "creating google storage bucket for stripped sequence files"
gsutil mb gs://acs1115_multisequence

echo "loading all processed data into storage bucket"
gsutil cp ./result/*.csv gs://acs1115_multisequence