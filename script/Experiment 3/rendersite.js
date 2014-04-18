//PhantomJS Script for render a site
//Usage:
//  phantomjs rendersite.js METHOD SITE OUTPUTFILE


var system = require('system');
var args = system.args;

var urlmethod = args[1];
var site = args[2];
var dest = args[3];

var page = require('webpage').create();
page.open(urlmethod + '://' + site, function() {
    page.render(dest);
    phantom.exit();
});
