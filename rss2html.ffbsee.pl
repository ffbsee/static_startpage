#!/usr/bin/perl
# Konvertiere das RSS von https://ffbsee.de/feed.rss in HTML foo für die Homepage
use strict;
use warnings;
use LWP 5.64;
use XML::Simple;
use Data::Dumper;
use HTML::Entities;

# create object
my $xml = new XML::Simple;

my $browser = LWP::UserAgent->new();
my $seite = $browser->get('https://ffbsee.de/feed.rss');
my $seite_code = $seite->decoded_content();
#print $seite_code;

# read XML file
my $data = $xml->XMLin("$seite_code");

# print output
# print Dumper($data);

my $news_count=0;
while (defined ($data->{"channel"}->{"item"}->[$news_count])){
    $news_count++;
}
# print $news_count; #wie viele news exestieren...

my $w = "";
open (DATEI, "index.html") or die $!;
   while(<DATEI>){
     $w = $w.$_;
   }
close (DATEI);

my @a = split('<!--PERL-RSS-FEED-->', $w);

open FH, ">", 'newsfeed.html' or die "Error writing 'newsfeed.html': $!\n";

print FH $a[0];
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-1]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a style='color: #de2c68;' href='$data->{'channel'}->{'item'}->[$news_count-1]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-2]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a  style='color: #de2c68;' href='$data->{'channel'}->{'item'}->[$news_count-1]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH encode_entities($data->{'channel'}->{'item'}->[$news_count-3]->{'description'}, '^\n\x20-\x25\x27-\x7e');
print FH "\n<a h style='color: #de2c68;' ref='$data->{'channel'}->{'item'}->[$news_count-1]->{'link'}'>Link zum Artikel</a><br/>\n<hr/>\n";
print FH $a[1];

close FH;


`cp style.css /var/www/ffbsee.de/web/`

