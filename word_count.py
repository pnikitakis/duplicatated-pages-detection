from collections import Counter
###
from mrcc import CCJob


class WordCount(CCJob):
  def process_record(self, record):
    if record['Content-Type'] != 'text/plain':
      return
    f1 = open('example.txt','w',encoding='utf-8', errors='ignore')
    data = record.payload.read()
    #for word in data.split():
    #  yield word, 1
    for word, count in Counter(data.split()).iteritems():
      f1.write( word + '\n')
      yield word, 1
    self.increment_counter('commoncrawl', 'processed_pages', 1)
    f1.close()

if name == '__main__':
WordCount.run()
