var csv = require('csv');
var fs = require('fs');


fs.readdir('./run/readyfiles/', (err, files) => {
    if (err) return err;

    files.forEach(file => {

        var stream = fs.createWriteStream(__dirname + '/result/' + file);
        var stream_orig = fs.createWriteStream(__dirname + '/result_orig/' + file);

        fs.createReadStream(__dirname + '/run/readyfiles/' + file).pipe(
            csv.parse()).pipe(
            csv.transform(function(record) {
                return record.slice(54, -1);
            })).pipe(
            csv.stringify()).pipe(stream);

        fs.createReadStream(__dirname + '/run/readyfiles/' + file).pipe(
            csv.parse()).pipe(
            csv.transform(function(record) {
                return record.slice(54, -1);
            })).pipe(
            csv.stringify()).pipe(stream_orig);

        stream.on('finish', function() {
            console.log(file + ' has been written');
        });

        stream_orig.on('finish', function() {
            console.log(file + '_orig has been written');
        });

    });

});
