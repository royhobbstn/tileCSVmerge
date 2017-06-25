var csv = require('csv');
var fs = require('fs');


fs.readdir('./run/readyfiles/', (err, files) => {
    if (err) return err;

    files.forEach(file => {

        var stream = fs.createWriteStream(__dirname + '/result/' + file);

        fs.createReadStream(__dirname + '/run/readyfiles/' + file).pipe(
            csv.parse()).pipe(
            csv.transform(function(record) {
                return record.slice(54);
            })).pipe(
            csv.stringify()).pipe(stream);

        stream.on('finish', function() {
            console.log(file + ' has been written');
        });

    });

});
