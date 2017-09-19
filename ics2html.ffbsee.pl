#!/usr/bin/perl
#
# Konvertiere das ICS von https://bodensee.space/calendarfeeds/ffbseepublic.ics in HTML foo für die Homepage
#
use strict;         # Good Practice
use warnings;       # Good Practice
use LWP 5.64;       # Download from web
use Data::Dumper;   # For Debugging
use HTML::Entities; # understand HTML
use Data::ICal;     # Kalender ...
use Data::ICal::DateTime;
use DateTime;       # It's about time...
use DateTime::Format::Duration;

our $icsfile = "https://bodensee.space/calendarfeeds/ffbseepublic.ics";
our $replace = "<!--ICS-Parser-String-->";
our $index_html = "/var/www/ffbsee.de/web/start.html";
#
# Download ICS feed
#
my $browser = LWP::UserAgent->new();
my $seite = $browser->get("$icsfile");
my $seite_code = $seite->decoded_content();

#
# Parse Kalender
#
my $cal = Data::ICal->new(data => "$seite_code");
my @events = $cal->events();

my $now = DateTime->now;
our $counter = 0;
our $content = "";
foreach my $event (@events) {
    #
    # Ermittle Tage bis zum Event
    #
    my $foo= $event->start->subtract_datetime($now);
    my $format = DateTime::Format::Duration->new(
        pattern => '%e'
        # pattern => '%Y years, %m months, %e days, %H hours, %M minutes, %S seconds'
    );
    my $tage_bis_event = $format->format_duration($foo);
    #
    # Fuehre Schleife aus, wenn $tage_bis_event mindestens 0
    #
    if (int($tage_bis_event) >= 0){
        $counter++;
        $content .= "<a><b>". $event->property('summary')->[0]->value. "</b>";
        if (defined  $event->property('location')){
            my $raw_location = $event->property('location');
            my @l = split("'value' => '", Dumper($raw_location));
            my @lo = split("',", $l[1]);
            $content .= $lo[0];
        }
        $content .= "am ". $event->start. "</a><br/>\n";
        if (defined  $event->description){ $content .= "<a style='font-size: 0.6em;'> ". $event->description. "</a>\n<br/><br/>\n"; } 
    }
}
if ($counter eq 0){
    $content = "<a><b>Derzeit keine Termine geplant</b></a><br/><a style='font-size:0.6em;'>Hast du nich Lust auf ein Community-Treffen bei dir in der Gegend? Freifunk Bodensee hat nicht umsonst den Bodensee im Namen. Kennst du eine gute Location bei dir in der Gegend? Dann veranstalte doch mal selber ein Community-Treffen! Sprich uns einfch an!</a>";
}

#
# open index.html from git
#
my $w = "";
open (DATEI, "$index_html") or die $!;
   while(<DATEI>){
     $w = $w.$_;
   }
close (DATEI);

#
# Find Marker and split HTML there
#
my @a = split("$replace", $w);

#
# Write as start.html
#
sleep(0.2);
open FH, ">", "$index_html" or die "Error writing 'start.html': $!\n";
#
print FH $a[0];
print FH encode_entities($content, '^\n\x20-\x25\x27-\x7e');
print FH $a[1];

close FH;

