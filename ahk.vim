" Autohotkey main code
    " Sleep (useful for automation, maybe include in the future autohotkey plugin)
        " NOTE: It is possible to use the 'gs' command to sleep like: normal 3gs to sleep 3 seconds.
        fu! s:sleep(duration, type)
            if a:duration <= 0
                return
            endif
            let l:duration = 0
            if a:type == 'mili' " No conversion needed
                let l:duration = a:duration
            elseif a:type == 'sec' " Convert the 'sec' duration to miliseconds
                let l:duration = a:duration * 1000
            elseif a:type == 'min' 
                let l:duration = a:duration * 60 * 1000 " Convert the 'min' duration to miliseconds
            elseif a:type == 'hour'
                let l:duration = a:duration * 60 * 60 * 1000 " Convert the 'hour' duration to miliseconds
            endif
            " Duration here should be in seconds
                exe 'sleep ' . l:duration . 'm'
            endfu
            " SleepMili (sleep a number of miliseconds)
                com! -nargs=1 SleepMili call s:sleep(<args>, 'mili')
                    com! Sleep25 SleepMili '25'
                    com! Sleep50 SleepMili '50'
                    com! Sleep75 SleepMili '75'
                    com! Sleep100 SleepMili '100'
                    com! Sleep200 SleepMili '200'
                    com! Sleep300 SleepMili '300'
                    com! Sleep400 SleepMili '400'
                    com! Sleep500 SleepMili '500'
                    com! Sleep1000 SleepMili '1000'
                    com! Sleep1500 SleepMili '1500'
            " SleepSec (sleep a number of seconds)
                com! -nargs=1 SleepSec call s:sleep(<args>, 'sec')
            " SleepMin (sleep a number of minutes)
                com! -nargs=1 SleepMin call s:sleep(<args>, 'min')
            " SleepHour (sleep a number of hours)
                com! -nargs=1 SleepHour call s:sleep(<args>, 'hour')

        "Example: call g:AhkExeCode(['msgbox 1', 'msgbox 2', 'msgbox 3'])
        " Pass lines of code in an array
        " TOFIX: These commands that receive a list as input parameters don't seem to work, but only the function
            com! -nargs=1 AHExeCode call g:AHExeCode([<args>])
                com! -nargs=1 A AHExeCode <args>
                    fu! g:AHExeCode(lines)
                        call writefile(a:lines, 'c:\temp\tmp.ahk')
                        silent !start c:\vimfiles\AutoHotkey32.exe c:\temp\tmp.ahk
                            endfu 
        " Message box (Ex: M 'test')
            com! -nargs=1 AHMsgbox call g:AHMsgbox(<args>)
                com! -nargs=1 Msgbox AHMsgbox <args>
                com! -nargs=1 M AHMsgbox <args>
                    fu! g:AHMsgbox(message)
                        if a:message == ''
                            call g:AHExeCode(['msgbox ,,'])
                        else
                            call g:AHExeCode(['msgbox , ' . a:message])
                        endif
                        endfu
        " Send text to clipboard
            com! -nargs=1 AHClipboard call g:AHClip(<args>)
                com! -nargs=1 Clipboard call g:AHClip(<args>)
                    fu! g:AHClipboard(text)
                        call g:AHExeCode(['clipboard = ' . a:text])
                        endfu
        " Activate a window
            com! -nargs=1 AHActivate call g:AHActivate(<args>)
                fu! g:AHActivate(class)
                    call g:AHExeCode([
                        \'IfWinExist, ahk_class ' . a:class, 
                        \'WinActivate, ahk_class ' . a:class
                        \])
                    SleepMili '200'
                    endfu
            com! -nargs=1 AHActivateByTitle call g:AHActivateByTitle(<args>)
                fu! g:AHActivateByTitle(title)
                    call g:AHExeCode([
                        \'SetTitleMatchMode 2',
                        \'IfWinExist, ' . a:title, 
                        \'WinActivate, ' . a:title
                        \])
                    SleepMili '200'
                endfu
                    " Some predefine activations
                        " Previous application
                            com! APrevious Send '!{Tab}'
                        com! AEverything AHActivate 'EVERYTHING'
                        com! AFirefox AHActivate 'MozillaWindowClass'
                        " com! AFreeplane AHActivate 'SunAwtFrame'
                        com! AFreeplane AHActivateByTitle '- Freeplane -'
                        com! AOutlook AHActivate 'rctrl_renwnd32'
                        com! APowergrep AHActivate 'PowerGrep'
                        com! APowergrep AHActivate 'PROCEXPL'
                        com! ASkype AHActivate 'tSkMainForm'
                        com! AVim AHActivate 'Vim'
                        com! ARun AHActivate '#32770' " Windows run box
                        com! AAvidRescue AHActivate 'LMITC_DialogStandaloneRescueFrame'
        " Mouse
            com! -nargs=* MouseMove call s:mouseMove(<f-args>)
                fu! s:mouseMove(x, y)
                    A 'DllCall("SetCursorPos", int, ' . a:x . ', int, ' . a:y . ')'
                    SleepMili '50'
                endfu
            com! MouseClickLeft cal s:mouseClick('left')
            com! MouseClickRight cal s:mouseClick('right')
            com! MouseClickMiddle cal s:mouseClick('middle')
                fu! s:mouseClick(button)
                    A 'MouseClick, ' . a:button 
                    SleepMili '50'
                endfu
        " Misc windows command
            com! AlwaysOnTop call s:alwaysOnTop()
                fu! s:alwaysOnTop()
                    A 'WinSet, AlwaysOnTop, Toggle, A'
                    SleepMili '200'
                    endfu
            com! -nargs=1 Transparent call s:transparent(<args>)
                fu! s:transparent(degree)
                    A 'WinSet, Transparent, ' . a:degree . ' , A'
                    SleepMili '200'
                endfu
            com! Minimize call s:minimize()
                fu! s:minimize()
                    A 'WinMinimize, A'
                    SleepMili '200'
                    endfu
            com! Maximize call s:maximize()
                fu! s:maximize()
                    A 'WinMaximize, A'
                    SleepMili '200'
                    endfu
            com! Restore call s:restore()
                fu! s:restore()
                    A 'WinRestore, A'
                    SleepMili '200'
                    endfu
        " Send (send a hotkey for example)
            com! -nargs=1 AHSend call g:AHSend(<args>)
                com! -nargs=1 Send call g:AHSend(<args>)
                    fu! g:AHSend(key)
                        A 'Send ' . a:key
                        SleepMili '200'
                        endfu
        " SendRaw (send text for example)
            com! -nargs=1 AHSendRaw call g:AHSendRaw(<args>)
                com! -nargs=1 SendRaw call g:AHSendRaw(<args>)
                    fu! g:AHSendRaw(text)
                        A 'SendRaw ' . a:text
                        endfu
" Specific to applications
    " Pentadactly
        " Send pentadactyl hint number
            com! -nargs=1 SendP call s:sendP(<args>)
                fu! s:sendP(hint)
                    Send 'f'
                    SleepMili '200'
                    exe 'SendRaw ' . a:hint
                    SleepMili '225'
                    endfu
" Excel automation
    fu! g:XlsToCsv(xlsPath, sheetName, srcRange, destRange, csvPath) " Convert a excel file file, sheet or range of cells to a csv file
        let c = []
            cal add(c, 'oExcel := ComObjCreate("Excel.Application")')
            cal add(c, 'oExcel.Visible := False')
            cal add(c, 'oExcel.DisplayAlerts := False ; Don''t show excel dialogs with confirmation to save etc')
            cal add(c, 'oExcel.Workbooks.Open("' . a:xlsPath . '")')
            " Export only a full sheet (don't specify a range if doing this)
                if a:sheetName != ""
                    cal add(c, 'oExcel.Sheets("' . a:sheetName . '").Activate')
                    endif
            " Export only a range of values
                if a:srcRange != ""
                    cal add(c, 'oRange := oExcel.ActiveWorkbook.ActiveSheet.Range("' . a:srcRange . '").Value')
                    endif
                if a:destRange != ""
                    " Add the destination temp sheet
                        cal add(c, 'oWorkbookDest := oExcel.Workbooks.Add')
                    " Add the data
                        cal add(c, 'oWorkbookDest.activeSheet.Range("' . a:destRange . '").Value := oRange')
                    endif
            cal add(c, 'oExcel.ActiveWorkbook.SaveAs("' . a:csvPath . '", 6) ; 6 = xlCSV')
            cal add(c, 'oExcel.Quit')
            cal add(c, 'exitapp')
        call g:AHExeCode(c)
        " Delete empty lines from the csv if the range was greater than the data (it may be useful to specify a greater range in case we want to get all the data if fields are added to a table, but still not get the empty lines and columns)
            " Wait a little bit until the file is created
                SleepMili '1500'
            exe 'tabe ' . a:csvPath
            " Delete the lines like ,,,,,,,,,,,,,,,,,,
                silent! %g/^,\+$/d
            " Delete the lines like #N/A,#N/A,#N/A,#N/A,#N/A,#N/A,#N/A,#N/A,#N/A,#N/A,#N/A
                silent! %g/^\(#N\/A,\)\+#N\/A$/d
            " Delete last , of each lines not to have an extra field
                silent! %s/,$//
            " Save and close
                w!
                tabclose!
        endfu
" codeNav
    " Autocommands
        au BufNewFile,BufEnter *.ahk nmap <buffer> <backspace>s :Ws<cr>
        au BufNewFile,BufEnter *.ahk nmap <buffer> <backspace>t :Wt<cr>
            au BufNewFile,BufEnter *.ahk nmap <buffer> <backspace>g :Wt<cr>
        au BufNewFile,BufEnter *.ahk nmap <buffer> <backspace>o :Wo<cr>

    " Commands

        " Grep the lines to keep by type
            com! Wt cal s:codeNavInit() | cal g:CNGrepByType()

        " Grep the lines to keep but keep the file structure
            com! Ws cal s:codeNavInit() | cal g:CNGrepByStruct()

        " Create a stripped down version of the code file, removing extra lines, to make the code file easier to oversee
            com! Wo cal s:codeNavInit() | cal g:CNOverview('.cs')

    " Local functions
        " Initialize the codeNav plugin
            fu! s:codeNavInit()
                let g:CN_REGEX_KEEP = []
                    let s:WINACTIVE = 0 | call add(g:CN_REGEX_KEEP, '#IfWinActive\sahk_class\s\w\+')
                    let s:HOTKEY = 1 | call add(g:CN_REGEX_KEEP, '\(\s\|^\)\zs\(\w\+\s&\)\{,1}\W\{1,3}\w\+::')
                    " let s:BLOCK = 0 | call add(g:CN_REGEX_KEEP, '\[\[\w.*\]\]')
                    " let s:SUB = 1 | call add(g:CN_REGEX_KEEP, '^\w\+:\s*$')
                    " let s:GOSUB = 2 | call add(g:CN_REGEX_KEEP, 'gosub\s*\w.*\ze;') " Gosub
                    " let s:GOTO = 3 | call add(g:CN_REGEX_KEEP, 'goto\s*\w.*\ze;') " Goto
                    " let s:FUNCTION = 4 | call add(g:CN_REGEX_KEEP, '\w\+\s*(.*)\ze;') " Function
                    " let s:WEBMETHOD = 5 | call add(g:CN_REGEX_KEEP, '\w\+\s*(.\{-})\s*@\s*\w\{-1,}\ze;') " Web method
                    " let s:SECTION = 6 | call add(g:CN_REGEX_KEEP, '^\s\{-}///') " Custom section

                let g:CN_REGEX_REMOVE = []
                    " let s:COMMENT = 0 | call add(g:CN_REGEX_REMOVE, '^\s*\/\/') " Lines with only comments
                    " let s:DECLARE = 1 | call add(g:CN_REGEX_REMOVE, '^\s*declare')
                    " let s:ERROREXIT = 2 | call add(g:CN_REGEX_REMOVE, 'goto\s\+ErrorExit;')
                    " let s:STATUS = 3 | call add(g:CN_REGEX_REMOVE, 'gosub\s\+.\{-}Status') " Like for example: gosub UpdateWFWarningStatus;
                    " let s:UPDATESTATUS = 4 | call add(g:CN_REGEX_REMOVE, '^\s*Update.\{-}Status') " Like for example: UpdateWFErrorStatus:
                    " let s:WHILE = 4 | call add(g:CN_REGEX_REMOVE, 'while.\{-};') " For example: while (success != "true"); 
                endfu
