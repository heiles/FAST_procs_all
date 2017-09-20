;=================================================================

function which_find_routine, proname, _REF_EXTRA=_extra
; LOOKS FOR A MATCH BETWEEN ROUTINE INFORMATION AND
; AN IDL MODULE NAME...
; CLEVERLY, COMPILATION OF WHICH GUARANTEES THAT THERE WILL ALWAYS
; BE AT LEAST ONE PROCEDURE (WHICH) AND FUNCTION (WHICH_FIND_ROUTINE)...
compile_opt idl2, hidden
return, strmatch(routine_info(_EXTRA=_extra), proname, /FOLD_CASE)
end; which_find_routine

;=================================================================

pro which, name
;+
; NAME:
;       WHICH
;
; PURPOSE: 
;       To search for any file in the IDL !path that contains the
;       user-supplied IDL routine (procedure or function) name.  Also
;       returns compilation status of each routine (in IDL lingo,
;       whether or not the routine is "resolved".)
;
; CALLING SEQUENCE:
;       WHICH, name
;
; INPUTS:
;       name - module name to search for, a scalar string.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       The IDL !path is searched for file names that are simply the
;       module (in IDL documentation, "module" and "routine" are used
;       interchangeably) name with a ".pro" suffix appended to them.
;       A module stored inside a file whose name is different than the
;       module name (followed by a ".pro") will not be found UNLESS
;       that module happens to be the currently-resolved module!
;       E.g., if the module "pro test_proc" lives in a file named
;       "dumb_name.pro", then it will not be found:
;
;       IDL> which, 'test_proc'
;       Module TEST_PROC Not Compiled.
;       % WHICH: test_proc.pro not found on IDL !path.
;
;       unless it happens to be resolved:
;
;       IDL> .run dumb_name
;       % Compiled module: TEST_PROC.
;       IDL> which, 'test_proc'
;       Currently-Compiled Module TEST_PROC in File:
;       /home/robishaw/dumb_name.pro
;
;       However, this is terrible programming style and sooner or
;       later, if you hide generically-named modules in
;       inappropriately-named files, bad things will (deservedly)
;       happen to you.
;
;       The routine further assumes that a file named "dumb_name.pro"
;       actually contains a module named "dumb_name"!  If it doesn't,
;       then you are a bad programmer and should seek professional
;       counseling.
;
;       Finally, if the user has somehow compiled a module as a procedure
;       and then compiled a module of the same name as a function, they
;       will both be available to the user, therefore both are listed.
;       This situation should probably be avoided.
; 
; PROCEDURES CALLED:
;       STRSPLIT(), WHICH_FIND_ROUTINE()
;
; EXAMPLES:
;       You haven't yet resolved (compiled) the routine (module)
;       DEFROI.  Let's look for it anyway:
;
;         IDL> which, 'defroi
;         Module DEFROI Not Compiled.
;
;         Other Files Containing Module DEFROI in IDL !path:
;         /usr/local/rsi/idl/lib/defroi.pro
;
;       For some reason you have two modules with the same name.
;       (This can occur in libraries of IDL routines such as the
;       Goddard IDL Astronomy User's Library; an updated version of a
;       routine is stored in a special directory while the old version
;       is stored in its original directory.) Let's see which version
;       of the module ADSTRING we are currently using:
;
;         IDL> which, 'adstring.pro'
;         Currently-Compiled Module ADSTRING in File:
;         /home/robishaw/idl/goddard/pro/v5.4+/adstring.pro
;
;         Other Files Containing Module ADSTRING in IDL !path:
;         /home/robishaw/idl/goddard/pro/astro/adstring.pro
;
; NOTES:
;       First, all currently-compiled procedures and functions are
;       searched.  Then the remainder of the IDL !path is searched.  The
;       current directory is searched before the IDL !path, whether or not
;       the current directory is in the IDL !path, because this is the
;       behavior of .run, .compile, .rnew, DOC_LIBRARY, etc.
;
; MODIFICATION HISTORY:
;   30 May 2003  Written by Tim Robishaw, Berkeley
;   17 Feb 2004 T. Robishaw. Fixed oddity where user tries to call a
;               function as if it were a procedure, thus listing the 
;               module in both the Compiled Functions and Compiled 
;               Procedures list.  
;   03 May 2006 T. Robishaw. Fixed scenario where two modules with
;               the same name are compiled, one as a procedure, the
;               other as a function.
;               Add current directory to the top of the path and make sure
;               the path is a unique list of directories. 
;               Added capability to cope with symbolic links.
;   11 May 2006 T. Robishaw. Fixed up warning and documentation for the
;               strange case of having both a procedure and function of the
;               same name compiled.
;-

on_error, 2
resolve_routine, 'strsplit', /IS_FUN, /NO_RECOMPILE

; MAKE SURE THE INPUT IS A SINGLE STRING...
if (N_params() lt 1) then begin
    message, 'syntax: which, name', /INFO
    return
endif
sz = size(name)
if (sz[0] gt 1) then message, 'NAME must be a scalar string.'
if (sz[sz[0]+1] ne 7) then message, 'NAME must be a string.'
proname = name

; WHAT IS THE PATH SEPARATOR ON THIS OS...
psep = path_sep()

; IF .PRO SUFFIX INCLUDED, DROP IT...
proname = strtrim(proname,2)
if strmatch(proname,'*.pro', /FOLD_CASE) $
  then proname = strmid(proname,0,strlen(proname)-4)

; SEARCH THE CURRENTLY-COMPILED PROCEDURES AND FUNCTIONS FIRST...
pindx = where(which_find_routine(proname),presolved)
findx = where(which_find_routine(proname,/FUNCTIONS),fresolved)

; IF PROCEDURE OR FUNCTION WAS FOUND, IS IT UNRESOLVED...
punresolved = total(which_find_routine(proname,/UNRESOLVED))
funresolved = total(which_find_routine(proname,/UNRESOLVED,/FUNCTIONS))

; WE NEED TO HANDLE BIZARRO CASES OF HAVING A FUNCTION THAT THE USER TRIES
; TO CALL AS A PROCEDURE, THUS TRICKING IDL INTO THINKING IT HAS ON ITS
; HANDS A RESOLVED FUNCTION, A RESOLVED PROCEDURE AND AN UNRESOLVED
; PROCEDURE...
if (presolved AND punresolved AND fresolved) then begin
   presolved = 0 & punresolved = 0
endif

; AND WHILE WE'RE AT IT, WE TAKE CARE OF THE CONVERSE... A PROCEDURE
; THAT HAS BEEN CALLED AS A FUNCTION BEFORE COMPILATION...
if (fresolved AND funresolved AND presolved) then begin
   fresolved = 0 & funresolved = 0
endif

; PRINT THE FULL PATH TO THE RESULTING RESOLVED ROUTINE...
if (presolved and not punresolved) OR $
   (fresolved and not funresolved) then begin

   ; THE PROCEDURE OR FUNCTION WAS FOUND...
   resolved_routine = (presolved AND fresolved) ? $
                      [(routine_info(/SOURCE))[pindx].PATH, $
                       (routine_info(/SOURCE,/FUNCTIONS))[findx].PATH] : $
                      (presolved ? (routine_info(/SOURCE))[pindx].PATH : $
                       (routine_info(/SOURCE,/FUNCTIONS))[findx].PATH)

   ; CHECK BIZARRO CASE OF USER HAVING COMPILED A PROCEDURE AND
   ; FUNCTION OF THE SAME NAME...
   if (presolved XOR fresolved) $
      then print, strupcase(proname), resolved_routine, $
                  FORMAT='("Currently-Compiled Module ",A," in File:",'+$
                         '%"\N",A,%"\N")' $
      else print, strupcase(proname),resolved_routine[0],resolved_routine[1],$
                  FORMAT='("Identically-named modules have been compiled as'+$
                  ' a procedure and a function!",%"\N",'+$
                  '"The Currently-Compiled Modules ",A," Are in These'+$
                  ' Files:",%"\N","PROCEDURE: ",A,%"\N"," FUNCTION: ",A,%"\N")'
endif $
else print, strupcase(proname), format='("Module ",A," Not Compiled.",%"\N")'

; EXTRACT THE !PATH INTO A STRING ARRAY...
path = strsplit(!path, path_sep(/SEARCH_PATH), /EXTRACT)

; GET RID OF "." IF USER INCLUDES THIS IN PATH...
path = path[where(path ne '.')]

; WHAT IS THE CURRENT DIRECTORY...
cd, CURRENT=current

; GET TARGET OF ANY SYMBOLIC LINKS IN THE IDL !PATH...
path_syml = path
for i = 0, N_elements(path_syml)-1 do begin
   d = path_syml[i]
   if not file_test(d,/DIRECTORY) then continue
   cd, d & cd, CURRENT=dnew
   if not strmatch(d,dnew) then path_syml[i] = dnew
endfor

; REMOVE ANY DUPLICATE PATH ELEMENTS, KEEPING ONLY THE ONE CLOSEST TO THE
; TOP...
rev_path_syml = reverse(path_syml)
rind = reverse(lindgen(N_elements(path_syml)))
u = uniq(rev_path_syml,sort(rev_path_syml))
path_syml = reverse(path_syml[rind[u[sort(u)]]])
path = reverse(path[rind[u[sort(u)]]])

; IF THE CURRENT DIRECTORY IS ANYWHERE IN THE PATH, THEN MOVE IT TO THE
; FRONT OF THE PATH, SINCE THE CURRENT PATH WILL BE SEARCHED FIRST BY .RUN,
; .COMPILE, .RNEW, ETC...
cpath = where(strmatch(path_syml,current) eq 1,n_cpath,COMPLEMENT=rpath)
path_syml = [current,path_syml[rpath]]
path = [(n_cpath gt 0) ? path[cpath] : current, path[rpath]]

; ADD THE FILENAME TO EACH PATH DIRECTORY...
filenames = path + psep + proname + '.pro'

; DOES ANY SUCH FILE EXIST IN THE CURRENT PATH...
; THIS WAS WRITTEN BACK IN V5.4, BEFORE FILE_SEARCH, LEAVE IT ALONE...
file_exists = where(file_test(filenames), N_exists)

; IF THERE IS NO SUCH FILE THEN SPLIT...
if (N_exists eq 0) then begin
    if (N_elements(resolved_routine) eq 0) then $
        message, proname + '.pro not found on IDL !path.', /INFO
    cd, current & return
endif

; GET TARGET OF A SYMBOLIC LINK IN THE PATH OF THE RESOLVED ROUTINE...
; ALSO HANDLES INDIRECT MOUNT POINTS ON LINUX SYSTEMS...
for i = 0, N_elements(resolved_routine)-1 do begin
   ; GET THE PATH TO THE RESOLVED ROUTINE...
   p = strsplit(resolved_routine[i],psep,COUNT=np,/EXTRACT)
   d = psep+((np gt 1) ? strjoin(p[0:np-2],psep,/SINGLE) : '')
   cd, d & cd, CURRENT=dnew
   if not strmatch(d,dnew) $
      then resolved_routine = [resolved_routine,dnew+psep+p[np-1]]
endfor
cd, current

; PULL OUT ALL THE FILES THAT EXIST...
filenames = filenames[file_exists]
filenames_syml = path_syml[file_exists] + psep + proname + '.pro'

; TAKE RESOLVED ROUTINE OUT OF THE LIST...
if (N_elements(resolved_routine) gt 0) then begin

   ; GET THE INDICES OF THE UNRESOLVED ROUTINES...
   find_resolved = strmatch(filenames_syml,resolved_routine[0])
   for i = 1, N_elements(resolved_routine)-1 do $
      find_resolved = find_resolved OR $
                      strmatch(filenames_syml,resolved_routine[i])
   file_exists = where(find_resolved eq 0, N_exists)

   ; WAS THE RESOLVED ROUTINE THE ONLY ONE...
   if (N_exists eq 0) then return

   ; PRINT OUT FILES RELATIVE TO IDL !PATH, NOT LINK TARGETS...
   filenames = filenames[file_exists]
endif

; PRINT THE REMAINING ROUTINES...
print, 'Other Files Containing Module '+strupcase(proname)+' in IDL !path:'
print, transpose(filenames)
print

end; which
