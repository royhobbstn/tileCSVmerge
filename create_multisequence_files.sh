wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node

npm install

mkdir run

cd run

mkdir schemas; mkdir readyfiles

curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt -O

sed 1d ACS_5yr_Seq_Table_Number_Lookup.txt > no_header.csv

awk -F, '$4 ~ /^[0-9]+$/' no_header.csv > columns_list.csv

n=122;for i in $(seq -f "%04g" ${n});do echo -n "KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,GEOID,NAME,BTTR,BTBG,BLANK7" > "./schemas/schema$i.txt"; done;
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4`"" >> "./schemas/schema$f3.txt"; done < columns_list.csv;

wget https://storage.googleapis.com/acs1115_stage/eseq001.csv; wget https://storage.googleapis.com/acs1115_stage/eseq002.csv; wget https://storage.googleapis.com/acs1115_stage/eseq003.csv;

# gsutil cp gs://acs1115_stage/e*.csv


n=122;for i in $(seq -f "%03g" ${n}); do echo -n -e ",\n" >> ./schemas/schema0$i.txt; cat ./schemas/schema0$i.txt eseq$i.csv > ./readyfiles/eseq$i.csv; done;


# head -1000 ./readyfiles/eseq001.csv > ./readyfiles/heseq001.csv
# head -1000 ./readyfiles/eseq002.csv > ./readyfiles/heseq002.csv
# head -1000 ./readyfiles/eseq003.csv > ./readyfiles/heseq003.csv

cd ..

gsutil mb gs://acs1115_multisequence

node merge_columns.js

gsutil cp ./result/*.csv gs://acs1115_multisequence