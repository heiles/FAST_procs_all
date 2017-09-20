pfcalonoff     - given []{pfhdrstr} of headers from a file, compute
				 cal on/off-1 and tsys for cal recs.
				 and tsys for all the cal records.
pfchkcalonoff  - find indices in {pfhdrstr} array that have valid calonoff.
pfplot         - plot a set of sources given {pfsrcinfo}, and {pfsrcout} 
				 arrays.
procfile.h     - define structures
procfiles		
pfinphdrs      - input all scan headers from a file computing summary power.
pfsrc          - process a contigous set of position on/off pairs.
procfile       
procftsys

pftsysdisp     - after inputing hdrscns (pfinpfiles) and extracting cals
				 (pfcalonoff) plot tsys vs za for a given receiver and
				 freq range, and fit a polynomial.

