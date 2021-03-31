# duplicatated-pages-detection
Implemented simhash technique to estimate duplicated pages in a given dataset. University project for Information Retrieval (Spring 2015)

Final report can be found [here](https://github.com/pnikitakis/duplicatated-pages-detection/blob/main/Final%20Report%20%5BGR%5D.pdf) **in Greek**.

## Prerequisites
- Matlab 2012b+
- Matlab: 'Statistics and Machine Learning Toolbox
- Java 1.6 (Matlab 2012b needs that version) 

## How to run
The main program is `proj.m`
1. In `DataHasher.java` on lines **45** and **48** insert path for Desktop. 
2. Compile with `javac -source 1.6 -target 1.6 DataHasher.java`.
3. In Matlab workspace run `which classpath.txt` and we add the path to the directory of `DataHasher.class`.
4. Run `proj.m` and choose whether the input is from a .csv file or from an [online source](http://commoncrawl.org/the-data/get-started/).

## Authors
- [Panagiotis Nikitakis](https://www.linkedin.com/in/panagiotis-nikitakis/)

## Course website
[ECE328 Information Retrieval](https://www.e-ce.uth.gr/studies/undergraduate/courses/ece328/?lang=en)  
