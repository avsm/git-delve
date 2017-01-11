import numpy as np
import pylab as plt
import csv

import datetime

times = []
repos = {}
fname='loc.txt'
with open(fname, 'r') as csvfile:
  r = csv.reader(csvfile, delimiter=' ', quotechar='"')
  for row in r:
    print row
    if int(row[1]) not in times:
      times.append(int(row[1]))
    if row[0] not in repos.keys():
      repos[row[0]] = []
    repos[row[0]].append(int(row[2]))

X = map(lambda x: datetime.datetime.fromtimestamp(x), times)
Xyear = map(lambda x: x.strftime('%b %Y'), X)
Y = []
labels = []
for key,value in repos.iteritems():
  Y.append(value)
  labels.append(key)

plt.stackplot(X, *Y, baseline="zero", labels=labels)
plt.title("MirageOS 3 lines of code")
plt.legend(loc=(0.25,0.4))
plt.xticks(X, Xyear, rotation='vertical', fontsize='small')
plt.tight_layout()
plt.savefig("loc.pdf", format="pdf")
