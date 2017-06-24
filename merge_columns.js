var csv = require('csv');
var fs = require('fs');

fs.createReadStream(__dirname+'/run/readyfiles/heseq001.csv').pipe(
csv.parse     ()).pipe(
csv.transform (function(record){
                return record.slice(54,-1);
              })).pipe(
csv.stringify ()).pipe(process.stdout);