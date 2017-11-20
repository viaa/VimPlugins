" sqlite.vim

" Version 1.0

" Description: Plugin that provides sqlite database access to vimscripts. The script was not tested in Linux, but it does work in Windows.
" Usage: Change the s:SqlitePath variable in this script to the path of your sqlite3 executable, then in your script set this variable to the path of your database let g:SVDbPath = '<path to my database>'. After that you can use any of the functions in this script to access sqlite.

" Search
    " silent echo 'Functions' | exe 'norm zMzrzr' | lvimgrep '^\s*fu!' % | lopen
        " silent echo 'Calls' | lvimgrep '\(call\|cal\)\s' % | lopen
            " silent echo 'Calls to this script' | lvimgrep '\(call\|cal\)\s\(s:\|g:CV\)' % | lopen
    " silent echo 'Commands' | lvimgrep '^\s*com!' % | lopen
    " silent echo 'Mappings' | lvimgrep '^.\{-}map!\?.\{-}\<cr>' % | lopen
    " silent echo 'Autocommands' | lvimgrep '^.\{-}\(au\|autocmd\|autocommand\)!\?\s.*' % | lopen
    " silent echo 'Variables' | lvimgrep '^\s*let \(s\|g\):' % | lopen
" Todo:
    " s0 Faire une fonction sqlite qui retourne un dataset, qui retourne les rows mais avec les columns names dedans ou un dictionnary... donc j'aurais pas besoin de callback mais je ferait un loop
    " s0 Add a query log file where all queries would be appended too (c:\temp\sqliteVim.log)
    " s0 SVExe() avec une requete like et des '%.....%' ne fonctionne pas, meme '%%.....%%', ne fonctionne pas... c'est a cause du passage de la requete en dos
    " s0 Il semble que le fichier l:out de SVExe() ne se cree pas, le SVScr.txt... meme si le delete est pas commente ca fonctionne pas
    " s0 faire un export dans sqlite.vim qui export en csv et en tab delimited
    " s0 Do function that returns rows from sqlexe or columns... like to do datasets... see what was done in caseviews.vim (backup) with columns and rows like this:
        " Add links to the merged pdf with the shortname and case num
    "            let l:rows = g:SVExe('sql', '', "select IfNull([Case Graphics Card Driver], 'FILLER') ShortName, [Case number] from [* - Opened]")
    "            if !empty(l:rows) 
    "                for l:row in l:rows
    "                    let l:values = split(l:row, '|')
    "                    let l:shortName = substitute(l:values[0], 'FILLER', '', '')
    "                    let l:caseNum = l:values[1]
    "                    let l:pdfPath = 'file://d:/Dropbox/CasesPages/' . l:shortName . '_' . l:caseNum . '.pdf'
    "                    exe '%s#>' . l:shortName . '<#><a href=' . l:pdfPath . '>' . l:shortName . '</a><#ge'
    "                endfor
" vimgrep ' fu!' % | copen " Functions
" vimgrep ' com!' % | copen " Commands
" vimgrep ' com!\|fu!' % | copen " Commands and functions
" vimgrep ' let s:' % | copen " Variables
" Local variables
    let s:SqlitePath = 'D:\Projects\Tools\sqlite3.exe'
    "let s:SqlitePath = 'c:\temp\mt\sqlite3.exe'
    let s:TempPath = 'c:\Temp\'
    "let s:TempPath = 'c:\Temp\mt\'
    " let s:LogPath = 'd:\work\Caseviews\CaseViews.log'
    "let g:SVDbPath = '' " This variable is set in the client script
    " Debug flags
        let s:DebugRunImport = 1 " To actually do or not do the import of the CSV file
        let s:loggingEnabled = 1
    " Execution settings
        let s:DelScr = 0 " Delete the script after its execution
" Global variables
    " Contains instruction to do extra processing after an html file is exported. For example to add links to a page.
        let g:SVExportPostProcessing = ''
    " Contains instructions to format a CSV file before being imported in the database.
        let g:SVImportPreProcessing = ''
    " Instructions after the import like for example to add nulls to where fields are ''
        let g:SVImportPostProcessing = ''
" Commands
    " norm zzMzrk
    " -- SVTables 'C:\Tools\FirefoxPortable\Data\profile\places.sqlite'
    " -- SVSchema 'C:\Tools\FirefoxPortable\Data\profile\places.sqlite'
    " -- SVExeCurrent 'C:\Tools\FirefoxPortable\Data\profile\places.sqlite'
    "     -- Then have this is the file to execute for example
    "         select * from moz_places;
    " 
    " -- The cases.sqlite here is just for example, because I may use the predefined CVTables, CVSchema, CVExeCurrent
    "     -- CVExeCurrent
    "     -- CVTables
    "     -- CVSchema
    " -- SVTables 'c:\Work\CaseViews\Cases.sqlite'
    " -- SVSchema 'c:\Work\CaseViews\Cases.sqlite'
    " -- SVExeCurrent 'c:\Work\CaseViews\Cases.sqlite'
    "     -- Then have this is the file to execute for example
    "     select * from cases;
    " Select the data
        " Tofix: I don't know how to get 2 arguments
        com! -nargs=1 SVSelect exe "call g:SVExe('sql', 'new', 'SELECT * FROM " . <args> . ";')" 
        " | norm ggdd
    " Execute a given file
        " Tofix: I don't know how to get 2 arguments
        "com! -nargs=* SVExe 'echo ' . <args>
        "let g:SVDbPath = '" . <args> . "'" | w! | call g:SVExe('scr', 'new', <args>)
    " Execute current file (.sql file)
        com! -nargs=1 SVExeCurrentFile exe "let g:SVDbPath = '" . <args> . "'" | w! | call g:SVExe('scr', 'new', expand('%'))
    " Execute selected sql
        com! -nargs=1 SVExeSelection exe 'split c:/temp/' . strftime("%Y%m%d%H%M%S") . '.sql' | put | exe 'norm zRggdd' | exe "SVExeCurrentFile '" . <args> . "'"
    " Execute current query (execute the query under the cursor)
        com! -nargs=1 SVExeCurrentQry exe 'norm w' | call search('\(select\|create\|drop\|update\|insert\|delete\)\s', 'bW') | exe 'norm v' | call search(';') | exe 'norm y' | silent exe "SVExeSelection '" . <args> . "'"
    " Show table list from the database passed as the parameter
        com! -nargs=1 SVTables exe "let g:SVDbPath = '" . <args> . "'" | call g:SVTables('new')
    " Show database structure
        com! -nargs=1 SVSchema exe "let g:SVDbPath = '" . <args> . "'" | call g:SVSchema('new', '')
    " Open in firefox
        com! -nargs=1 SVFirefox exe 'silent ! D:\Projects\Tools\FirefoxPortable\App\Firefox\firefox.exe "file:///' . substitute(<args>, '\', '/', 'g') . '"'
" Local Functions
    " norm zzMzrzrk
        fu! s:SlashD(path) " Change the slashes in a path to double-slashes, ex: c:\temp -> c:\\temp
            return substitute(a:path, '\', '\\\\', 'ge')
            endfu
        fu! s:SlashF(path) " Change the slashes in a path to forward-slashes, ex: c:\temp -> c:/temp
            return substitute(a:path, '\\', '/', 'ge')
            endfu
        fu! s:Log(filePath, stringToAppend) " Function to write commands to log files for debugging
            exe 'redir >> ' . a:filePath
                silent! exe "echo '" . strftime("%Y-%m-%d_%H:%M:%S") . "' '" . a:stringToAppend . "'"
            redir END
            endfu
" Global Functions
    " norm zzMzrzrk
        fu! g:SVReplaceChars(fileName) " Replace invalid filename characters
            " call s:Log(s:LogPath, 'g:SVReplaceChars()')
            return substitute(a:fileName, "\\s\\|\/\\|\\*\\|\\!\\|\\-\\|\\#\\|\\,", '_', 'ge') " Replace the spaces, /, !, - and , by _ to create a valid filename
            endfu
        fu! g:SVFormatCSVDates(monthPos) " Format the dates: if a day or month is less than 10 then add a 0 to have it compatible with Sqlite's date format (the dates formatted here have an initial format m/d/yyyy (d/m/yyyy could also be formatted) 
            " call s:Log(s:LogPath, 'g:SVFormatCSVDates()')
            " Date format: Add 0 to months if less than 10. The month is the first date value.
                " Ex. "6/06/2014" will become "06/06/2014"
                "for i in range(1, 9)
                "    " Date format: Add 0 to months if less than 10. The month is the first date value.
                "    " Ex. "6/06/2014" will become "06/06/2014"
                "    exe '%s#,"' . i . '/#,"0' . i . '/#ge'


                "    " Date format: Add 0 to days if less than 10. The day is the second date value.
                "    " Ex. "06/06/2014" will become "06/06/2014"
                "    exe '%s#/' . i . '/201#/0' . i . '/201#ge'
                "endfor
                %s,\(\d\?\d\)/\(\d\?\d\)\ze/\d\d\d\d,\=(len(submatch(1))==2?'':'0').submatch(1).'/'.(len(submatch(2))==2?'':'0').submatch(2),ge

            " Hour format: Change hour format to 24 hours
                " Ex. "06/06/2014 9:29 PM" will become "06/06/2014 21:29"
                " For the AM hours >= 10, simply remove the AM
                %s/\(\d\d:\d\d\) AM/\1/ge
                " For the AM hours < 10, add the 0 and remove the AM, so for example 7:00 AM will become 07:00
                    " Generic break down:
                    " \d\@<!     -- negative look behind for a digit
                    " \(\d\)     -- single digit
                    " \(:\d\d\)  -- colon an two gidits
                    " \s\+PM     -- rest of the string that we do not need
                %s/\d\@<!\(\d\)\(:\d\d\)\(\s\+AM\)/0\1\2/ge
            " To do +12 to the PM hours so that for example 01:00 PM becomes 13:00
                " \=            starts VimL expression which should produce
                "               substitution result
                " submatch({nr})    returns group from a match. See :help sub-replace-expression
                " \@<! is a negative look behind, which matches only if there is no match of the expression to the left of it (see :help \@<!).
                " Everything after \= (which should start replacement part) is a regular expression, so "." is just a concatenation of "(submatch(1) + 12)" and "submatch(2)", which are VimL expressions.
                %s/\(\d\+\)\(:\d\d\)\(\s\+PM\)/\=(submatch(1)==12?'0':'').((submatch(1)+12)%24).submatch(2)/ge

            " Change date format from mm/dd/yyyy to yyyy-mm-dd because when I sort sqlite use a string sort so the year and month should be first. 
                " The julian date function uses the yyyy-mm-dd date format, so no need to convert it
                if a:monthPos == 1
                    " For casesviews it should be (the month is the 1st \(\d\d\))
                        %s,\(\d\d\)/\(\d\d\)/\(\d\d\d\d\),\=submatch(3).'-'.submatch(1).'-'.submatch(2),ge
                elseif a:monthPos == 2
                    " For mamtools and freeplane tasks attributes imported from todolist it should be 2 (the month is the 2nd " \(\d\d\))
                        %s,\(\d\d\)/\(\d\d\)/\(\d\d\d\d\),\=submatch(3).'-'.submatch(2).'-'.submatch(1),ge
                        " This here will convert the remaining date if there are without the 20 before the year like 29/02/16 00:00, where 16 should be 2016, so this will become 2016-02-29
                        %s,\(\d\d\)/\(\d\d\)/\(\d\d\),\='20'.submatch(3).'-'.submatch(2).'-'.submatch(1),ge
                endif
            endfu
        fu! g:SVImportCsv(tbl, path, separator, append, removeColumns, dropTable, createTableFromCsvColumns) " Import a CSV file
            let path = a:path
            " Backup the file before
                let cmd = 'copy /Y ' . path . ' ' . path . '.bak'
                call system(cmd)
            " call s:Log(s:LogPath, 'g:SVImportCsv()')
            " Call to an external format function or command to format the file before to import it.
                if g:SVImportPreProcessing != ''
                    exe g:SVImportPreProcessing
                endif
            " Create the table from the columns in the CSV file
                if a:createTableFromCsvColumns == 1
                    call g:SVCreateTableFromCsvFile(path, ',', a:tbl, a:dropTable)
                else
                    " Drop the table if it exists
                        if a:dropTable == 1
                            call g:SVDropTable(a:tbl)
                            endif
                    endif
            " Remove the columns of the csv file if specified
                if a:removeColumns == 1
                    exe 'tabe ' . path
                    norm dd
                    exe 'w! ' . path
                    tabclose!
                    endif
            " To actually do or not do the import of the CSV file
                if s:DebugRunImport == 1
                    let path = s:SlashF(path)
                    " Build the import script
                        let scr = []
                        call add(scr,  '.separator ' . a:separator) 
                        if a:append != 1
                            call add(scr,  'DELETE FROM ' . a:tbl . ';') 
                        endif
                        call add(scr,  '.import ' . path . ' ' . a:tbl) 
                    " Run the importation
                        " NOTE: The CSV file should ideally be originially created with the UTF-8 encoding to have accents etc displayed correctly. To open it in vim and change its encoding to UTF-8 is not the same.
                        set nomore " To get the script not to pause when it reaches the number of terminal lines 
                        call g:SVExe('scr', '', scr)
                        set more
                endif
            " Call to code after the import is done
                if g:SVImportPostProcessing != ''
                    exe g:SVImportPostProcessing
                endif
            " Restore the csv backuped (use a:path because it is still with backslashes)
                let cmd = 'copy /Y ' . a:path . '.bak ' . a:path
                cal system(cmd)
                cal delete(a:path . '.bak')
            endfu
        fu! g:SVExe(type, out, stm) " Execute a SQL statement or a command script. May return the results if specified.
            " call s:Log(s:LogPath, 'g:SVExe()')
            let l:scr = s:TempPath . 'SVScr.txt'
            let l:out = s:TempPath . 'SVOut.txt'
            " Script or statement
                " If to execute a script
                    if a:type == 'scr'
                        " If cmd is an array of statements
                            if type(a:stm) == type([])
                                call writefile(a:stm, l:scr) " Write it to a file to be read
                        " If cmd is a string, then assume it is a path to a script file
                            else
                                let l:scr = a:stm 
                            endif
                        let l:cmd = '! echo .read ' . s:SlashD(l:scr) . ' | ' . s:SlashD(s:SqlitePath) . ' ' . s:SlashD(g:SVDbPath)
                    elseif a:type == 'sql'
                        let l:stm = a:stm
                        " I need to escape the % that may be used with the LIKE, because when vim send the command to dos, dos expands the % to a file name...
                            if l:stm =~ '%' " If contains %
                                let l:stm = substitute(l:stm, '%', '\\%', 'ge')
                            endif
                        let l:cmd = '! ' . s:SlashD(s:SqlitePath) . ' ' . s:SlashD(g:SVDbPath) . ' "' . l:stm . '"'
                    " Execute a script from a file 
                    elseif a:type == 'file'
                        let l:cmd = '! echo .read ' . s:SlashD(a:stm) . ' | ' . s:SlashD(s:SqlitePath) . ' ' . s:SlashD(g:SVDbPath)
                        C l:cmd
                    endif
                    
            " Output buffer or no
                " If an output buffer is specified
                    if a:out != ''
                        let l:cmd =  'silent ' . a:out . " | exe 'silent r" . l:cmd . "' | exe 'norm ggdd' | exe 'set nowrap'"
                " If no output buffer is specified then output to file
                    else
                        let l:cmd =  'silent ' . l:cmd . ' > ' . l:out
                    endif
            exe l:cmd
            "C l:cmd
            " Get results and cleanup
                let l:arr = []
                if a:out == "" && filereadable(l:out)
                    let l:arr = readfile(l:out)
                    call delete(l:out)
                endif
                " Delete the script after its execution
                    if s:DelScr == 1 && filereadable(l:scr)
                        call delete(l:scr)
                    endif
            " Write the command to the log file
                "if s:loggingEnabled == 1
                    " call s:Log(s:TempPath . 'sqliteVim.log', l:cmd) " Write the command to the log file
                "endif
            return l:arr
            endfu
        fu! g:SVExportCsv(qry, path) " Export the file to csv
            " call s:Log(s:LogPath, 'g:SVExportCsv()')
            let l:path = s:SlashF(a:path)
            " Delete the file if it exists
                if filereadable(l:path)
                    call delete(l:path)
                endif
            " Build the export script
                 " Add the ; to the query in case it is omitted, so the no need to include it in the parameter value 
                let scr=[
                         \'.header on', 
                         \'.mode csv',
                         \'.output ' . l:path,
                         \a:qry . ';'
                        \]
            " Run the exportation
                call g:SVExe('scr', '', scr)
            " Byte order mark prepended to the file so that excel recognizes the file (help bomb). Without this, when the file is opened in Excel, Excel will not recognize the encoding and strange characters will be displayed.
                exe 'edit! ' . l:path
                set bomb
                " Run extra processing on the file (like for example to replace data on the file or run a function
                    if g:SVExportPostProcessing != ''
                        exe g:SVExportPostProcessing
                    endif
                w
                bd!
            endfu
        fu! g:SVExportTab(qry, path) " Export the file to text separated by tabs
            " call s:Log(s:LogPath, 'g:SVExportTab()')
            let l:path = s:SlashF(a:path)
            " Delete the file if it exists
                if filereadable(l:path)
                    call delete(l:path)
                endif
            " Build the export script
                 " Add the ; to the query in case it is omitted, so the no need to include it in the parameter value 
                let scr=[
                         \'.header on', 
                         \'.mode tab',
                         \'.output ' . l:path,
                         \a:qry . ';'
                        \]
            " Run the exportation
                call g:SVExe('scr', '', scr)
            " Byte order mark prepended to the file so that excel recognizes the file (help bomb). Without this, when the file is opened in Excel, Excel will not recognize the encoding and strange characters will be displayed.
                exe 'edit! ' . l:path
                set bomb
                " Run extra processing on the file (like for example to replace data on the file or run a function
                    if g:SVExportPostProcessing != ''
                        exe g:SVExportPostProcessing
                    endif
                w
                bd!
            endfu
        fu! g:SVExportList(qry, path) " Export the file to list (each field is on its own line)
            " call s:Log(s:LogPath, 'g:SVExportList()')
            let l:path = s:SlashF(a:path)
            " Delete the file if it exists
                if filereadable(l:path)
                    call delete(l:path)
                endif
            " Build the export script
                 " Add the ; to the query in case it is omitted, so the no need to include it in the parameter value 
                let scr=[
                         \'.header on', 
                         \'.mode line',
                         \'.output ' . l:path,
                         \a:qry . ';'
                        \]
            " Run the exportation
                call g:SVExe('scr', '', scr)
            " Run extra processing on the file (like for example to replace data on the file or run a function
                if g:SVExportPostProcessing != ''
                    " Fix 2015-09-17_09.13.51
                        " exe 'split ' . l:path
                        exe 'edit! ' . l:path
                    exe g:SVExportPostProcessing
                    silent w!
                    bd!
                endif
            endfu
        fu! g:SVExportListPostProcessing() " Post processing (to make the file with the first field indented and the multiline text fields with all their text lines on the same line, the line of the field)
            " call s:Log(s:LogPath, 'g:SVExportListPostProcessing()')
            " It is not included directly in the g:SVExportList() function because this way export without formatting is possible
            " NOTE: s0 Instead of putting strange chars to do the multiline formatting (to bring to their own lines, I could use the g!, = ,-j command (or something similar instead of " = " to match the fields), it would be more concise and more reliable maybe. It works on my test data, so I could try to do it in this function to see if it works.
            " Add a special char at the beginning of field lines and at their end too
                silent! %s,^\(\s*\w\{-}\(:\d\)*\s=\(\s\|$\).*\),ð\1§,e
            " For the empty line put these special chars, that means it will be split too
                silent! %s,^$,§ð§ð,e
            " For each multiline text lines add a special char at the end to indicate there was a carriage return before
                silent! g!,§,s,$,¬,e
            " Put all lines to the same line
                silent! %s,\n,,g
            " Split to have all fields on its line but the multiline text will not be split, only the field lines
                silent! %s,§ð\|¬ð,,g
            " Equalize the indentation of all lines to one tab
                silent! %s,^\s\{-}\ze\w,\t,
            " Unindent the first line of each record
                silent! %s,ð\s\+,,e
            " Remove these remaining char
                silent! %s,§,,ge
            " Go to top of file
                norm gg
            endfu
        "fu! g:SVExportListPostProcessingMindMap()
        "endfu
        fu! g:SVExportHtml(qry, path, decodeHtml) " Export a table/view to an html file
            "" call s:Log(s:LogPath, 'g:SVExportHtml()')
            let l:path = s:SlashF(a:path)
            " Delete the file if it exists
                if filereadable(l:path)
                    call delete(l:path)
                endif
            " Build the export script
                 " Add the ; to the query in case it is omitted, so the no need to include it in the parameter value 
                let scr=[
                         \'.header on', 
                         \'.mode html',
                         \'.output ' . l:path,
                         \a:qry . ';'
                        \]
            " Run the exportation
                call g:SVExe('scr', '', scr)
                " If the file exists (the file may be locked for some reason, so don't run this code in that case)
                    if filereadable(l:path)
                        " Open the exported file and do some modifications
                            " Fix 2015-09-17_09.14.18
                                " silent exe 'split ' . l:path
                                silent exe 'tabe! ' . l:path
                        " Add some tags and CSS style for the table at the beginning of the file and "press" ESC (to do that, ctrl+q then ESC)
                            exe 'norm ggI<HTML>
                                        \<HEAD>
                                            \<META http-equiv="Content-Type" content="text/html; charset=utf-8">
                                            \<STYLE>td { border: 1px solid #9CC2E5; font-family: calibri; font-size: 10px; vertical-align: top }
                                                \table { border-collapse: collapse; }
                                                \table th { background-color:#5B9BD5; font-family: calibri; font-size: 10px; }
                                                \tr:nth-child(2n){ background-color:#DEEAF6; }
                                                \body { font-family: calibri; font-size: 10px; }
                                            \</STYLE>
                                            \<STYLE type="text/css" media="print">
                                                \@page { size: A4 landscape; prince-shrink-to-fit: auto; }
                                            \</STYLE>
                                        \</HEAD>
                                        \<BODY><p>' . l:path . '</p>
                                            \<TABLE>'
                                    "\tr:nth-child(2n){ background-color:#DEEAF6; }
                        " Add the </TABLE> at the end of the file and "press" ESC (to do that, ctrl+q then ESC)
                            norm GA</BODY></TABLE></HTML>
                        " Un-encode the ", < and > in the file, this way the views could contain html code
                            if (a:decodeHtml == 1)
                                silent %s/&quot;/"/ge
                                silent %s/&lt;/</ge
                                silent %s/&gt;/>/ge
                            endif
                        " Run extra processing on the file (like for example to replace data on the file or run a function
                            if g:SVExportPostProcessing != ''
                                exe g:SVExportPostProcessing
                            endif
                        " Save the file
                            " This could prevent the error at writing, saying that set buftype is set to something
                            set buftype = 
                            w!
                        " Close the file
                            bd!
                    endif
            endfu
        fu! g:SVViewsToHtml(path, decodeHtml) " Export each views to 1 html files and create a frameset to navigate the views with a list (menu)
            " call s:Log(s:LogPath, 'g:SVViewsToHtml()')
            let l:path = s:SlashF(a:path)
            set nomore " To get the script not to pause when it reaches the number of terminal lines 
            "Create the frames html files
                " Fix 2015-09-17_09.18.37
                    " silent new
                    silent! enew!
                exe 'norm i<FRAMESET COLS="10%, 90%">
                        \<FRAME SRC="list.html" NAME="list">
                        \<FRAME SRC="main.html" NAME="view">
                    \</FRAMESET>' | 
                silent exe 'w! ' . l:path . 'frames.html'
                bd!
            " Get the views list
                let l:views = g:SVExe('sql', '', "SELECT name FROM sqlite_master WHERE type = 'view' ORDER BY name;")
            " Create the view list to navigate the view
                " Fix 2015-09-17_09.19.02
                    " silent new
                    silent enew!
                norm i<html><body><style>body {font-family: calibri; font-size: 10px;}</style>
                "let i = 0
                for v in l:views
                    " Replace invalid filename characters
                        let vf = g:SVReplaceChars(v) . '.html'
                    " Create the view files 
                        exe 'call g:SVExportHtml("select * from [' . v . ']", "' . l:path . vf . '", ' . a:decodeHtml . ')' 
                    " Create the list link for that file
                        exe 'norm o<A HREF="' . vf . '" TARGET="view">' . v . '</A><br><br>'
                    "let i = i + 1
                    "if (i == 3)
                    "    break
                    "endif
                endfor
                norm o</body></html>
            " Save the view list to navigate the views
                silent exe 'w! ' . l:path . 'list.html'
                bd!
            set more
            endfu
        fu! g:SVTables(out) " Show table list
            " call s:Log(s:LogPath, 'g:SVTables()')
            silent call g:SVExe('scr', a:out, ['.tables']) 
            silent %s/^/[/e
            silent %s/\s*$/]/e 
            norm ggdd
            endfu
        fu! g:SVSchema(out, tblName) " Show table(s) description(s). If no table name specified then all tables are described.
            " call s:Log(s:LogPath, 'g:SVSchema()')
            call g:SVExe('scr', a:out, ['.schema ' . a:tblName])
            " Replace the " by [ or ]
                silent %s/ "/ [/ge
                silent %s/("/([/ge
                silent %s/",/],/ge
                silent %s/" /] /ge
                silent %s/;/;/ge
            " Add a space between lines (statement)
                "%s/;\n/;/ge
            " Delete blank lines, go to the top of the file, delete first blank line and wrap the statements
                norm ddggdd
                "set nowrap
            endfu
        fu! g:SVConvertListToCsv(path, fieldsToRemove, separator) " Format a file that is exported with g:SVExportList() to a CSV file for import
            " call s:Log(s:LogPath, 'g:SVConvertListToCsv()')
            " Fix 2015-09-17_09.14.39
                " exe 'split ' . a:path 
                exe 'edit! ' . a:path 
            " Remove lines where there are fields not to import
                if a:fieldsToRemove != ""
                    silent! exe 'g/\(' . a:fieldsToRemove . '\)\s=/d'
                endif
            " Replace all commas left that could be found in text by a uncommon character
                silent! %s/,/¸/ge
            " Replace first line by nothing but keep as empty line. There I could simply add a \n before the first field if the first field (line) would be kept.
                silent! %s,^\w.*,
            " Remove all indentation
                silent! %s,^\t,,
            " Put all lines in a csv format delimited by the separator (remove the fieldname and = and keep only the value with the separator after)
                " Don't use , as the expression separator because , could be the value of a:separator
                silent! exe '%s/.\{-}\s=\s\(.*\)/\1' . a:separator
            " Remove all \n in the lines with values delimited with separator
                " Don't use , as the expression separator because , could be the value of a:separator
                silent! exe '%s/' . a:separator . '\n/' . a:separator
            " Remove empty lines
                silent! g,^$,d
            " Remove last , from each lines
                silent! %s/,$//
            " Save and close
                silent w!
                silent bd!
            " Check (run this against the csv file to see where there are more columns)
                " Don't uncomment in this file
                " %s/\(^\|,\)\zs.\{-}\ze,//g
            endfu
        fu! g:SVSqlColumnNames(sql) " Returns a list of column names for the given query
            " WARNING: Make sure that the changes are written (commited) in the database or the database will be locked and the temp table will not be created and an empty list will be returned for the columns. 
            " call s:Log(s:LogPath, '    g:SVSqlColumnNames()')
            " Create a temp table using the sql statement
                let tableName = 'tmp' . strftime("%Y%m%d%H%M%S")
                let scr = [
                    \'drop table ' . tableName . ';', 
                    \'create table ' . tableName . ' as ' . a:sql . ';'
                    \]
                call g:SVExe('scr', '', scr)
            " Get the CREATE statement defined by sqlite for that table
                let createSmt = join(g:SVExe('sql', '', '.schema ' . tableName))
                call g:SVExe('sql', '', 'drop table ' . tableName)
            " Remove the column type, default values etc
                let createSmt = substitute(createSmt, '\s\+TEXT.\{-}\ze,\?', '', 'ge')
                let createSmt = substitute(createSmt, '\s\+INT.\{-}\ze,\?', '', 'ge')
            " Remove the 'CREATE TABLE <tablename> (' part
                let createSmt = substitute(createSmt, '\s*CREATE\s\+TABLE\s\+\S\+\s*(', '', 'ge')
            " Remove the trailing );
                let createSmt = substitute(createSmt, '\s*);', '', 'ge')
            " Remove spaces at the beginning of a column
                let createSmt = substitute(createSmt, '\(^\|,\)\ze\zs \{-}\ze\S', '', 'ge')
            " Put the columns to a list
                let columns = split(createSmt, ',')
            return columns
            endfu
        fu! g:SVSqlLoop(sql, callbackFunction) " Loops the rows returned by a sql statement and for each rows it calls a callback function, passing to it a dictionnary that contains the names and values of each columns in that row.
            " call s:Log(s:LogPath, 'g:SVSqlLoop()')
            let columnNames = g:SVSqlColumnNames(a:sql)
            let rows = g:SVExe('sql', '', a:sql)
            for row in rows
                let columnValues = split(row . '|', '|') " I add the trailing | so that the split has the same number of items as the column
                " Put the column names and values in a dictionnary
                    let i = 0 
                    let columns = {}
                    " Add the columns values to the dictionnary
                        for columnName in columnNames
                            " WARNING: If there are end of line in column values in the database, columnValues[i] will fail, the value could not be retrieved from the array with the indice, so the end of lines should be removed from the values in the database using a view or by changing the data, something like this could be put in a view for example: replace(VerseTextLang1, X'0A', '') VerseTextLang1, ...
                            let columns[columnName] = columnValues[i]
                            let i = i + 1 
                            endfor
                    " Call the callback function passing the dictionnary
                        exe 'call ' . a:callbackFunction . '(columns)'
                endfor
            endfu
                " Sample callback function used by s:SqlLoop() to loop row by row the data retrived from a sql statement (the callback function must be a global function to be called from g:SVSqlLoop())
                " fu! g:ProcessRows(columns)
                "     " Loop the column names
                "         for name in keys(a:columns)
                "             echo name
                "             endfor
                "     " Loop the column values
                "         for value in values(a:columns)
                "             echo value
                "             endfor
                     " Loop column names and values
                "         for [name, value] in items(a:columns)
                "             echo name . ' = ' . value
                "         endfor
                     " Access one value by column name
                "         echo a:columns
                "         echo a:columns['Status']
                "         echo a:columns['CaseID']
                "         echo a:columns['ShortName']
                "         echo a:columns['"Case Quicktime Version"']
                "         echo a:columns['"Case Graphics Card"']
                     " Access the columns by column number
                        "let columnsList = values(a:columns)
                        " But this will get the columns sorted by name I think 
                " endfu
                " Sample usage of the g:SVSqlLoop() with the callback function above (the callback function must be a global function to be called from g:SVSqlLoop())
                    " call g:SVSqlLoop('select * from [UP 10 Nb days opened]', 'g:ProcessRows')
        fu! g:SVSqlToFile(sql, filePath, mapInstructions, filterInstructions) " Write the result of a sql query to a file. The mapInstructions and filterIntstructions are lists of strings that will passed to the map() and filter() functions to do processing on the list before to save it.
            " call s:Log(s:LogPath, 'g:SVSqlToFile()')
            " Example of map instructions, here a list is passed to the mapInstructions with 2 instructions in the list. The list of filter instructions is empty.
                " call g:SVSqlToFile(a:sql, s:tmpDataPath, ['substitute(v:val, " ", "", "ge")', 'substitute(v:val, "|", " ", "ge")'], [])
            " NOTE: If I use regex I should maybe double the \, like \\s\\+ for example, because the regex are between ""
            let rows = g:SVExe('sql', '', a:sql)
                for filterInstruction in a:filterInstructions
                        call filter(rows, mapInstruction)
                    endfor
                for mapInstruction in a:mapInstructions
                        call map(rows, mapInstruction)
                    endfor
                call writefile(rows, a:filePath)
            endfu
        fu! g:SVCreateTableFromCsvFile(path, separator, tbl, dropTable) " Takes the columns on the first line of a csv file and makes a 'create table' statement out of it 
            if filereadable(a:path)
                let columns = split(readfile(a:path)[0], a:separator)
                let sql = 'create table ' . a:tbl . ' ('
                    for c in columns
                        " let sql .=  '`' . c . "` text, \<cr>" 
                        let sql .=  '`' . c . "` text, " 
                    endfor
                    " Remove last comma and last end-of-line, and put );
                        "let sql = substitute(sql, ", \<cr>$", ');', '')
                        let sql = substitute(sql, ', $', ');', '')
                if a:dropTable == 1
                    cal g:SVDropTable(a:tbl)
                    endif
                " Create the table
                    call g:SVExe('sql', '', sql) 
                endif
            endfu
        fu! g:SVDropTable(tbl) " To simply drop a table (helper function)
                let sql = 'drop table ' . a:tbl
                call g:SVExe('sql', '', sql)
                " C sql
            endfu
