
starttime="start: `date +"%T"`"

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


gsutil cp gs://acs1115_stage/e*.csv .
 
# get rid of newline
for file in *.csv ; do echo "remove newline $file"; sed 's/,[^,]\+$//' $file > ../nocol/new$file; done;
cd ..

echo "concatenating schema and data files for each sequence"
n=122;for i in $(seq -f "%03g" ${n}); do echo "concatenating with schema $i"; echo -n -e ",\n" >> ./schemas/schema0$i.txt; cat ./schemas/schema0$i.txt ./nocol/neweseq$i.csv > ./readyfiles/eseq$i.csv; done;


cd ..

mkdir finished

echo "dealing with odd case eseq113"
perl -p -e 's/,,\n/,,,\n/' ./run/readyfiles/eseq113.csv > modeseq113.csv
rm -rf ./run/readyfiles/eseq113.csv
mv modeseq113.csv ./run/readyfiles/eseq113.csv

echo "running nodejs program to strip first 55 columns of redundant information"
node merge_columns.js

echo "combining output files"
paste -d "" ./run/readyfiles/eseq001.csv ./result/eseq002.csv ./result/eseq003.csv > ./finished/eseq_001_002_003.csv
paste -d "" ./run/readyfiles/eseq004.csv ./result/eseq005.csv ./result/eseq006.csv > ./finished/eseq_004_005_006.csv
paste -d "" ./run/readyfiles/eseq007.csv ./result/eseq008.csv ./result/eseq009.csv > ./finished/eseq_007_008_009.csv
paste -d "" ./run/readyfiles/eseq010.csv ./result/eseq011.csv ./result/eseq012.csv > ./finished/eseq_010_011_012.csv
paste -d "" ./run/readyfiles/eseq013.csv ./result/eseq014.csv ./result/eseq015.csv > ./finished/eseq_013_014_015.csv
paste -d "" ./run/readyfiles/eseq016.csv ./result/eseq017.csv ./result/eseq018.csv > ./finished/eseq_016_017_018.csv
paste -d "" ./run/readyfiles/eseq019.csv ./result/eseq020.csv ./result/eseq021.csv > ./finished/eseq_019_020_021.csv
paste -d "" ./run/readyfiles/eseq022.csv ./result/eseq023.csv ./result/eseq024.csv > ./finished/eseq_022_023_024.csv
paste -d "" ./run/readyfiles/eseq025.csv ./result/eseq026.csv ./result/eseq027.csv > ./finished/eseq_025_026_027.csv
paste -d "" ./run/readyfiles/eseq028.csv ./result/eseq029.csv ./result/eseq030.csv > ./finished/eseq_028_029_030.csv
paste -d "" ./run/readyfiles/eseq031.csv ./result/eseq032.csv ./result/eseq033.csv > ./finished/eseq_031_032_033.csv
paste -d "" ./run/readyfiles/eseq034.csv ./result/eseq035.csv ./result/eseq036.csv > ./finished/eseq_034_035_036.csv
paste -d "" ./run/readyfiles/eseq037.csv ./result/eseq038.csv ./result/eseq039.csv > ./finished/eseq_037_038_039.csv
paste -d "" ./run/readyfiles/eseq040.csv ./result/eseq041.csv ./result/eseq042.csv > ./finished/eseq_040_041_042.csv
paste -d "" ./run/readyfiles/eseq043.csv ./result/eseq044.csv ./result/eseq045.csv > ./finished/eseq_043_044_045.csv
paste -d "" ./run/readyfiles/eseq046.csv ./result/eseq047.csv ./result/eseq048.csv > ./finished/eseq_046_047_048.csv
paste -d "" ./run/readyfiles/eseq049.csv ./result/eseq050.csv ./result/eseq051.csv > ./finished/eseq_049_050_051.csv
paste -d "" ./run/readyfiles/eseq052.csv ./result/eseq053.csv ./result/eseq054.csv > ./finished/eseq_052_053_054.csv
paste -d "" ./run/readyfiles/eseq055.csv ./result/eseq056.csv ./result/eseq057.csv > ./finished/eseq_055_056_057.csv
paste -d "" ./run/readyfiles/eseq058.csv ./result/eseq059.csv ./result/eseq060.csv > ./finished/eseq_058_059_060.csv
paste -d "" ./run/readyfiles/eseq061.csv ./result/eseq062.csv ./result/eseq063.csv > ./finished/eseq_061_062_063.csv
paste -d "" ./run/readyfiles/eseq064.csv ./result/eseq065.csv ./result/eseq066.csv > ./finished/eseq_064_065_066.csv
paste -d "" ./run/readyfiles/eseq067.csv ./result/eseq068.csv ./result/eseq069.csv > ./finished/eseq_067_068_069.csv
paste -d "" ./run/readyfiles/eseq070.csv ./result/eseq071.csv ./result/eseq072.csv > ./finished/eseq_070_071_072.csv
paste -d "" ./run/readyfiles/eseq073.csv ./result/eseq074.csv ./result/eseq075.csv > ./finished/eseq_073_074_075.csv
paste -d "" ./run/readyfiles/eseq076.csv ./result/eseq077.csv ./result/eseq078.csv > ./finished/eseq_076_077_078.csv
paste -d "" ./run/readyfiles/eseq079.csv ./result/eseq080.csv ./result/eseq081.csv > ./finished/eseq_079_080_081.csv
paste -d "" ./run/readyfiles/eseq082.csv ./result/eseq083.csv ./result/eseq084.csv > ./finished/eseq_082_083_084.csv
paste -d "" ./run/readyfiles/eseq085.csv ./result/eseq086.csv ./result/eseq087.csv > ./finished/eseq_085_086_087.csv
paste -d "" ./run/readyfiles/eseq088.csv ./result/eseq089.csv ./result/eseq090.csv > ./finished/eseq_088_089_090.csv
paste -d "" ./run/readyfiles/eseq091.csv ./result/eseq092.csv ./result/eseq093.csv > ./finished/eseq_091_092_093.csv
paste -d "" ./run/readyfiles/eseq094.csv ./result/eseq095.csv ./result/eseq096.csv > ./finished/eseq_094_095_096.csv
paste -d "" ./run/readyfiles/eseq097.csv ./result/eseq098.csv ./result/eseq099.csv > ./finished/eseq_097_098_099.csv
paste -d "" ./run/readyfiles/eseq100.csv ./result/eseq101.csv ./result/eseq102.csv > ./finished/eseq_100_101_102.csv
paste -d "" ./run/readyfiles/eseq103.csv ./result/eseq104.csv ./result/eseq105.csv > ./finished/eseq_103_104_105.csv
paste -d "" ./run/readyfiles/eseq106.csv ./result/eseq107.csv ./result/eseq108.csv > ./finished/eseq_106_107_108.csv
paste -d "" ./run/readyfiles/eseq109.csv ./result/eseq110.csv ./result/eseq111.csv > ./finished/eseq_109_110_111.csv
paste -d "" ./run/readyfiles/eseq112.csv ./result/eseq113.csv ./result/eseq114.csv > ./finished/eseq_112_113_114.csv
paste -d "" ./run/readyfiles/eseq115.csv ./result/eseq116.csv ./result/eseq117.csv > ./finished/eseq_115_116_117.csv
paste -d "" ./run/readyfiles/eseq118.csv ./result/eseq119.csv ./result/eseq120.csv > ./finished/eseq_118_119_120.csv
paste -d "" ./run/readyfiles/eseq121.csv ./result/eseq122.csv > ./finished/eseq_120_121_000.csv

gsutil rm -r gs://acs1115_multisequence

echo "creating google storage bucket for stripped sequence files"
gsutil mb gs://acs1115_multisequence

echo "loading all processed data into storage bucket"
gsutil cp ./finished/*.csv gs://acs1115_multisequence

echo $starttime
echo "end: `date +"%T"`"