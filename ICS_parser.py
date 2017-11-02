import urllib3
import fileinput
from ics import Calendar, Event
from datetime import datetime, timezone

# URL, where to find the ics file
URL = 'https://bodensee.space/calendarfeeds/ffbseepublic.ics'
#file location of HTML file, where calendar data should be inserted
html_file = "/var/www/ffbsee.de/web/start.html";
# String in HTML file, which should be replaced by calendar data
replace_string = "<!--ICS-Parser-String-->";


###############################################################################

# Fetch ICS file from Server
http = urllib3.PoolManager()
try:
    http_request = http.request('GET', URL)
    print('HTTP Response Status:', http_request.status)
except:
    print('Server seems to be down.')
else:
    if http_request.status == 200:
        ics_file = http_request.data.decode('utf-8')
    else:
        print('Server did not deliver ICS file.')

# Create calendar object from ICS file
calendar = Calendar(ics_file)

# Start creation of HTML string, containing the event data
html_str = '<ul class="events">'

i = 0
for event in calendar.events:
    # Only recognize the events
    if event.begin > datetime.now(timezone.utc):
        i = i + 1

        # Check if Description exists and add as tooltip if applicable
        if event.description:
            html_str = html_str + '<li class="event" title="' + str(event.description) + '">'
        else:
            html_str = html_str + '<li class="event">'

        # Add Name of event
        html_str = html_str + '<span class="eventname">' + str(event.name) + '</span>'

        # Add location of event, if exists
        if event.location:
            html_str = html_str + '<span class="eventlocation"> &#64;' + str(event.location) + '</span>'

        # Add date of event
        html_str = html_str + '<br><span class="eventdate">'
        if event.has_end():
            if event.begin.format('DDMM') == event.end.format('DDMM'):
                html_str = html_str + str(event.begin.format('DD.MM.YYYY, HH:mm')) + ' bis ' + str(
                    event.end.format('HH:mm') + ' Uhr')
            else:
                html_str = html_str + str(event.begin.format('DD.MM.YYYY, HH:mm')) + ' Uhr bis ' + str(
                    event.end.format('DD.MM.YYYY, HH:mm') + ' Uhr')
        else:
            html_str = html_str + str(event.begin)
        html_str = html_str + '</span>'

        html_str = html_str + '</li>'

        #Leave loop if 3 events where added
        if i == 3:
            break
else:
    html_str = html_str + 'Keine Termine geplant!'

html_str = html_str + '</ul>'

# edit HTML file
file = open(html_file, 'r+')
for line in fileinput.input( html_file ):
    file.write(line.replace(replace_string, html_str))
file.close()