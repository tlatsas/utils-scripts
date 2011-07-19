#!/usr/bin/python2

# author: Tasos Latsas
#
# tzone-conv.py:
#   convert time between timezones

from sys import exit
import argparse
import time
from datetime import datetime
from datetime import date

try:
    from pytz import timezone, all_timezones
except ImportError:
    print "This utility needs the pytz package"
    print "install using easy_install or your distribution's package manager"
    exit(1)

# handy functions
def list_zones():
    for zone in all_timezones:
        print zone


def check_valid_time(t):
    try:
        time.strptime(t, '%H:%M')
        return True
    except ValueError:
        return False


# create command line parser
parser = argparse.ArgumentParser(description='Quickly convert time between zones.')

g_time = parser.add_argument_group('Time conversion')
g_time.add_argument('time', default=None, nargs='?', 
                    help="Time in H:M format [default: current time]")
g_time.add_argument('-f', '--from-tz', dest='from_tz', default='UTC',
                    help='Convert from timezone [default: UTC]')
g_time.add_argument('-t', '--to-tz', dest='to_tz', default='UTC',
                    help='Convert to timezone [default: UTC')
g_time.add_argument('-d', '--show-date', action='store_true', default=False,
                    help='Show current date in the output.')

g_list = parser.add_argument_group('Listing')
g_list.add_argument('-l', '--list', action='store_true', default=False,
                    help='List all time zones and exit.')

args = parser.parse_args()


if args.list:
    list_zones()
    exit(0)

if all(tz in all_timezones for tz in (args.from_tz, args.to_tz)) is False:
    print "ERROR: timezone argument not valid.\
Use -l to list available timezones"
    exit(1)

if args.time is None:
    t = datetime.now(timezone(args.from_tz))
else:
    if check_valid_time(args.time) is False:
        print "ERROR: wrong time format, use H:M format"
        exit(1)
    t_str = date.today().strftime("%Y-%m-%d")
    t_str = "%s %s" % (t_str, args.time)
    t = datetime.strptime(t_str, "%Y-%m-%d %H:%M").replace(tzinfo=timezone(args.from_tz))


# convert and print
converted_time = t.astimezone(timezone(args.to_tz))

print "%s '%s' is : " % (args.from_tz, args.time),
if args.show_date:
    print converted_time.strftime("%R%z (%x)"),
else:
    print converted_time.strftime("%R%z"),
print " %s" % args.to_tz

exit(0)

# vim: set sw=4 ts=4 sts=4 et:
