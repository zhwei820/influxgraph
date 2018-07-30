import statsd
import random
import time
c = statsd.StatsClient('10.9.141.21', 8125, prefix='foo')
for ii in range(1000000):
    time.sleep(0.01)
    
    c.incr('foo.bar.counter')  # Will be 'foo.bar' in statsd/graphite.