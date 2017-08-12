#!/usr/bin/perl
# Konvertiere das RSS von https://ffbsee.de/feed.rss in HTML foo für die Homepage
use strict;
use warnings;
use LWP 5.64;
use XML::Simple;
use Data::Dumper;

# create object
my $xml = new XML::Simple;

my $browser = LWP::UserAgent->new();
my $seite = $browser->get('https://ffbsee.de/feed.rss');
my $seite_code = $seite->decoded_content();
#print $seite_code;

# read XML file
my $data = $xml->XMLin("$seite_code");

# print output
print Dumper($data);


