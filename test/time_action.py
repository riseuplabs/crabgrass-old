#!/usr/bin/python
"""
cg_time: measure the time an action takes in crabgrass logs

Usage:
    cg_time Controller action log_file[s]
   
For example:
    cg_time GroupsController search /var/log/rails.log
    cg_time WikiPageController edit /var/log/rails.log.1.gz /var/log/rails.log.2.gz
"""

import sys
import gzip

if __name__ == '__main__':
    ie, args = "InputError", sys.argv
    try:
        if len(args) < 3: raise ie, "insufficient args"
        controller, action, logfiles = args[1], args[2], args[3:]

        search_str = "%s#%s" % (controller, action)
        print search_str
        time_str = "Completed in "
        
        x = []

        for fname in logfiles:
            if fname.endswith('.gz'):
                f = gzip.open(fname)
            else:
                f = open(fname)

            l = "(null)"
            while l:
                l = f.readline()
                if l.find(search_str) != -1:
                    print l
                    found_time = False
                    while not found_time:
                        l = f.readline()
                        i = l.find(time_str)
                        if i != -1:
                            print l
                            found_time = True
                            i += len(time_str)
                            x.append(float(l[i:(i+7)]))
                        
        for n in x:
            print n
    except ie, e:
        print "E:", e
        print
        print __doc__  
