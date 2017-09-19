#!/usr/bin/perl
#
# Konvertiere das RSS von https://ffbsee.de/feed.rss in HTML foo für die Homepage
#
use strict;         # Good Practice
use warnings;       # Good Practice
use LWP 5.64;       # Download from web
use XML::Simple;    # Parse XML
use Data::Dumper;   # For Debugging
use HTML::Entities; # understand HTML

#
# create XML object
#
my $xml = new XML::Simple;
#
# Download RSS feed
#
my $browser = LWP::UserAgent->new();
my $seite = $browser->get('https://ffbsee.de/feed.rss');
my $seite_code = $seite->decoded_content();
#
# uncomment for debugging
#
#print $seite_code;

#
# read XML file
#
my $data = $xml->XMLin("$seite_code");
#
# uncomment for debugging
#
# print output
# print Dumper($data);

#
# Parse die letzten News
#
my $news_count=0;
while (defined ($data->{"channel"}->{"item"}->[$news_count])){
    $news_count++;
}
# print $news_count; # wie viele news exestieren... <- uncomment for debugging

#
# open index.html from git
#
my $w = "";
open (DATEI, "/var/www/ffbsee.de/home/web20/static_startpage/index.html") or die $!;
   while(<DATEI>){
     $w = $w.$_;
   }
close (DATEI);

#
# Find Marker and split HTML there
#
my @a = split('<!--PERL-RSS-FEED-->', $w);

#
# Write as start.html
#
open FH, ">", '/var/www/ffbsee.de/web/start.html' or die "Error writing 'start.html': $!\n";

print FH $a[0];
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-1]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a style='color: #de2c68;' href='$data->{'channel'}->{'item'}->[$news_count-1]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-2]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a style='color: #de2c68;' href='$data->{'channel'}->{'item'}->[$news_count-2]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-3]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a style='color: #de2c68;' href='$data->{'channel'}->{'item'}->[$news_count-3]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH $a[1];

close FH;

#
# Kopiere die CSS in den Webserver, falls Sie sich hier im Git geupdatet hat
#
`cp /var/www/ffbsee.de/home/web20/static_startpage/style.css /var/www/ffbsee.de/web/`
