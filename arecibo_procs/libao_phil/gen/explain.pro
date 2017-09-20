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
;-
pro explain,arg1,print=print
;
    lastcmd=recall_commands()
    lastcmd=lastcmd[0]
    lastcmd=strsplit(lastcmd,',',/extract)
    if (n_elements(lastcmd) eq 1) or (n_params() eq 0)  then begin
        doc_library,'explaindoc',print=print
        goto,done
    endif
    routine=lastcmd[1]
;
; strip off any quotes
;
   routine=lastcmd[1]
    if strmid(routine,0,1) eq '"' then routine=strmid(routine,1)
    if strmid(routine,0,1,/reverse) eq '"' then $
            routine=strmid(routine,0,strlen(routine)-1)
    if strmid(routine,0,1) eq "'" then routine=strmid(routine,1)
    if strmid(routine,0,1,/reverse) eq "'" then $
            routine=strmid(routine,0,strlen(routine)-1)
    doc_library,routine,print=print
done:
    return
end
