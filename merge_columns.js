var csv = require('csv');
var fs = require('fs');

var file1 = new Promise((resolve, reject) => {
    fs.readFile('./run/readyfiles/heseq001.csv', 'utf8', function(err, data) {
        if (err) {
            reject(err);
        }

        csv.parse(data, {}, function(err, output) {
            if (err) {
                reject(err);
            }

            var cut_last = output.map(function(d) {
                return d.slice(0, -1);
            });
            
            resolve(cut_last);
        });

    });
});

var file2 = new Promise((resolve, reject) => {
    fs.readFile('./run/readyfiles/heseq002.csv', 'utf8', function(err, data) {
        if (err) {
            reject(err);
        }

        csv.parse(data, {}, function(err, output) {
            if (err) {
                reject(err);
            }

            var sliced = output.map(function(d) {
                return d.slice(54, -1);
            });

            resolve(sliced);
        });

    });
});

var file3 = new Promise((resolve, reject) => {
    fs.readFile('./run/readyfiles/heseq003.csv', 'utf8', function(err, data) {
        if (err) {
            reject(err);
        }

        csv.parse(data, {}, function(err, output) {
            if (err) {
                reject(err);
            }


            var sliced = output.map(function(d) {
                return d.slice(54, -1);
            });

            resolve(sliced);
        });

    });
});


Promise.all([file1, file2, file3]).then(function(data) {

    const combined = data[0].map((d, i) => {
        return d.concat(data[1][i]).concat(data[2][i]);
    });

    console.log(combined[0]);

    csv.stringify(combined, function(err, data) {
        if (err) {
            return console.log(err);
        }

        fs.writeFile("./result/test.csv", data, function(err) {
            if (err) {
                return console.log(err);
            }

            console.log("The file was saved!");
        });
    });

});
