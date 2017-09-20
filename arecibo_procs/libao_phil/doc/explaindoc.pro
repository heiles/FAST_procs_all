;+
;NAME:
;explain - list documentation
;SYNTAX: explain,{subject_document or routine_name}
;
;ARGS:
; None   :         If no arguments, display the list of subject documents.
; namedoc:string   If namedoc is provided then display the documentation
;                  for this subject. It will be a list of routine names 
;                  with 1 line descriptions (eg cordoc) or a just a list
;                  of the routine names (cordocnames).
;routine :string   If the name of a routine is entered, display the
;                  complete documentation for the routine.
;EXAMPLES:
;   explain             - list the topics available
;   explain,cordoc      - 1 line description of the correlator routines.
;   explain,cordocnames - list the names of all of the correlator routines.
;   explain,corplot     - list the documentation for corplot.
;
;CURRENT TOPICS: 
;
;  agcdoc          - 1 line description of az,gr,ch (vertex) routines
;  agcdocnames     - agc routine names
;
;  alfamondoc      - 1 line description of alfamon dewar monitoring routines
;  alfamondocnames - alfamon routine names
;
;  atmdoc          - 1 line description of atmospheric routines
;  atmdocnames     - atm routine names
;
;  bdwfdoc          - 1 line description of mock brown dwarf routine
;  bdwfdocnames     - bdwf routine names
;
;  cordoc          - 1 line description of correlator routines
;  cordocnames     - correlator routine names
;
;  cormapdoc       - 1 line description of correlator mapping routines
;  cormapdocnames  - correlator mapping routine names
;
;  galdoc          - 1 line description for galfa routines
;  galdocnames     - galfa routine names
;
;  gendoc          - 1 line description for generic routines
;  gendocnames     - generic routine names
;
;  lrdoc           - 1 line description for laser ranging routines
;  lrdocnames      - laser ranger routine names
;
;  masdoc          - 1 line description of mas spectrometer routines (fits)
;  masdevnames     - mas routine names
;
;  pdevdoc          - 1 line description of pdev (jeffs' formmat) routines
;  pdevnames        - pdev routine names
;
;  pntdoc          - 1 line description of pointing transformation routines
;  pntdocnames     - pointing transmformation routine names
;
;  psrfdoc         - 1 line description of pdev  psrfits routines
;  psrfdocnames    - psrfits routine names
;
;  pulsardoc        - 1 line description of pulsar related idl routines
;  pulsardocnames  - pulsar routine names
;
;  rcvmon          - 1 line description of dewar monitoring routines
;  rdevnames        - rcvmon routine names
;
;  rdevdoc          - 1 line description of rdev radar routines
;  rdevnames        - rdev routine names
;
;  rfidoc          - 1 line description of rfi routines 
;  rfidocnames     - rfi routine names
;
;  satdoc          - 1 line description of sattelite trackng routines 
;  satdocnames     - sattrakcing routine names
;
;  usrprojdoc      - 1 line description of user proj routines
;  userprojdocnames- user project routine names
;
;  wappdoc         - 1 line description of wapp (pulsar data) routines
;  wappdocnames    - wapp pulsar routine names
;
;  wasdoc          - 1 line description of was2 (wapp fits) routines
;  wasdocnames     - was2 (wapp fits) routine names
;-
;  topgen          - list interim correlator/was commands
;  explWas         - list the routines that are specific to the 
;                    was (wapps).
;  routinename     - list documenation of this routine.
;
;   The following are not yet implemented.
;       
;  explIO          - input/output of correlator data
;  explDisplay     - display single spectra or images.
;  explMath        - perform math operations on spectra:
;                    +,-,/,*,avg,subset,smooth,rms
;  explBaseline    - baselining of data
;  explMisc        - digFilter bandpass, masking,recomblineFreq,
;                    manipulate data structures,anything else.
;  explHdrinfo     - extract header information  about a record/scan.
;  explSpecArchive - Using the data archive of the raw spectra
;  explCalibArchive- Using the archive of the processed calibration runs.
;   
;  explOnoff          process position switch data
;  explCals           cal record processing.
;  explOnsrc          process data taken with only on source scans
;  explStokes         process stokes data with no off source positions.
;  explAuto           automated processing of datafiles
;
;  explCormap     - correlator mapping commands
;
; EXAMPLE:
;   explain              - list this file
;   explain,corposonoff  - list corposonoff documentation.
;   
; 
