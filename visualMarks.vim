" Documentation
    " Name: visualMarks.vim
    " Description: Simple plugin to show file marks visually
    " Author: Alexandre Viau (alexandreviau@gmail.com)
    " Installation: Copy the plugin to the vim plugin directory.

" Usage:
    " Simply use vim marks like usually doing
    " ma, mb, mc...mz
    " or
    " mA, mB, mC...mZ
    " to marks positions in files.
    " NOTE: Only new marks are shown visually, this means that the marks already in the viminfo file will not be showned visually.
    " <tab>m To show the marks log file (in a split view)
    " f3 To show the marks log file (in current buffer)
    " <tab>f3 To show the marks log file (in a new tab)
    " <s-tab>f3 Open and grep the marks log file
    " <tab>g To grep the marks log file
    " All files opened in vim are added to the log file

" Todo:
    " 1. Load the marks from vim info and show them visually.
    " 2. Add mapping to automatically mark with next unused mark.
    " 3. Show warning if mark already used somewhere to prevent overwriting marks.
    " 4. s0 Add the possibility to select a log in the log file and then go to that position in the file
    " 5. s0 Le type the recherche ne devrait pas etre regex car s'il y a des [ ou ] alors la chaine n'est pas trouvee
    " 6. s0 Fix the mapping for the search for the line number it is not working now, everything I put is not working
    " 7. s0 This seems not working: <s-tab>f3 Open and grep the marks log file 
    " 8. s0 Maybe have a way to press enter and open in the current buffer and not on the other window under..? but still keep the enter to open like it is now, simple have another mapping.
    " 9. s0 VisualMarks should ask if we want to overwrite the current mark if it is already allocated, if not then it should choose the first available mark starting from a or A depending if we pressed a minuscule or majuscule letter.

    " History:
    " 1.0 Initial release
    " 1.1 Removed the space in the mappings that where moving the cursor to the right after execution
    " 1.2 Change the file format for unix
    "     Added a fold to history
    " 1.3 Added 2 mappings (commented, to uncomment if you want to) to remap ` on ' and ' on `, because ` is more useful and ' more close
    " 1.4 Now the marks are saved to a log file so that it can be viewed to remember the previous marked positions. Also the line logged is copied to the clipboard. Later I will add the possibility go to the positions marked in the log file.
    " 2.0 I added a log file where each mark location is saved to it. And doing <tab>m will show the log file and allow to choose one of the previously logged location. Also, all files opened in vim are added to the log file, so it is like an history of files opened and locations in files. Tab<f3> will run grep to search the log file.
    " 2.1 I added and modified mappings
    " 2.2 I added 't' to open a file in another tab and I removed the '!' in the 2nd autocommand because it suppressed the first autocommand (thanks to Xaizek for that tip)
    " 2.3 I removed BufRead from the autocommand, because if vimgrep is used, all the files read by vimgrep were added to the visualMarks.log
    " 2.4 Some extra lines are added to the log every time, this is fixed 
    "       I remove error message if search string not found.
    " 2017-11-20_10.09.06 Removed the BufEnter as it was adding too many entries. 

" Variables
    let g:visualMarksLogFilePath = substitute($vim, '\', '/', 'g') . '/visualMarks.Log'
    let g:vm_nolog = 0 " This variable is to prevent files being added to the log on opening

" Settings
    " Remove all signs
        sign unplace *

" Mappings
    " Add mappings
        " If you want you may uncomment these 2 mappings to remap ` on ' and ' on `, because ` is more useful and ' more close
        " nnoremap ` '
        " nnoremap ' `

        " Uses nnoremap not to have a recursive mapping
        " Letters
        for n in range(1, 26)
            " Uppercase (A-Z)
            let l = nr2char(n + 64)
            exe 'nnoremap <silent> m' . l . ' m' . l . ':cal g:VmAddSignToMark("' . l . '")<cr>'
            " Lowercase (a-z)
            let l = nr2char(n + 96)
            exe 'nnoremap <silent> m' . l . ' m' . l . ':cal g:VmAddSignToMark("' . l . '")<cr>'
        endfor
        
    " Show and select marks
        com! ShowMarks :exe 'split ' . g:visualMarksLogFilePath | exe 'norm GzR'
        com! ShowMarksFullScreen :exe 'e! ' . g:visualMarksLogFilePath | exe 'norm GzR'
            nmap <tab>m :ShowMarks<cr> 
        
    " Log a line position without a mark
        nmap <leader>l :call g:VmLogToFile('', 0)<cr>
        autocmd! BufReadPre * :call g:VmLogToFile('', 0)

    " Get the current line (function name) to paste in other applications
        nmap <leader>f :let @* = getline('.')<cr>

    " Go to the line number in the selected log item in the log file
        " BUG: s0 It seems I cannot have c-enter and enter at the same time, they don't work together, only one defined works. https://groups.google.com/forum/#!topic/vim_use/y9qYhazt1Ls
        " s0 Change this mapping so it doesn't use the @f and @n registries
        "autocmd! BufNewFile,BufRead,BufEnter visualMarks.Log nmap <buffer> <s-Enter> :exe 'norm 0f]wvf:f:h"fy' \| exe 'norm EF:l"nyw' \| exe 'wincmd j' \| exe 'edit! ' . @f \| exe 'norm ' . substitute(@n, ' ', '', 'g') . 'GzR'<cr>
        " \| exe 'wincmd k'<cr>

    " Go search the line from the log file in the selected file
        " s0 Change this mapping so it doesn't use the @f and @l registries
        " s0 This function seems to have difficulty to find strings with ' and inside... or it cannot find some lines (strings)
        "autocmd! BufNewFile,BufRead,BufEnter visualMarks.Log nmap <buffer> <Enter> :exe 'norm 0f]wvf:f:h"fy' \| exe 'norm W"ly$' \| exe 'wincmd j' \| exe 'edit! ' . @f \| let @/ = @l \| exe 'norm ggnzR'<cr>
        com! OpenMark exe 'norm 0f];wvf:f:h"fy' | exe 'norm W"ly$' | exe 'wincmd j' | silent! exe 'edit! ' . @f | let @/ = @l | exe 'norm ggnzR'
            "au! BufNewFile,BufRead,BufEnter visualMarks.Log nmap <buffer> <Enter> :OpenMark<cr>
            "au! BufNewFile,BufEnter visualMarks.Log nmap <buffer> <Enter> :OpenMark<cr>
            au! BufNewFile visualMarks.Log nmap <buffer> <Enter> :OpenMark<cr>
        com! OpenMarkInTab exe 'norm 0f];wvf:f:h"fy' | exe 'norm W"ly$' | silent! exe 'tabe! ' . @f | let @/ = @l | exe 'norm ggnzR'
            "au BufNewFile,BufRead,BufEnter visualMarks.Log nmap <buffer> t :OpenMarkInTab<cr>
            "au BufNewFile,BufEnter visualMarks.Log nmap <buffer> t :OpenMarkInTab<cr>
            au BufNewFile visualMarks.Log nmap <buffer> t :OpenMarkInTab<cr>
        
    " Find a file that I previously used
        nmap <f3> :exe 'ShowMarksFullScreen'<cr>
        nmap <tab><f3> :tabe \| exe 'ShowMarksFullScreen'<cr>
        nmap <tab><s-f3> :tabe \| exe 'ShowMarksFullScreen' \| exe "call g:grep('')"<cr>
        nmap <tab>g :call g:grep('')<cr>

" Functions
    fu! g:VmAddSignToMark(m) " Show the marks visually on a column at the left of the screen
        " Create an id {{{3
        " Uppercase (A-Z) {{{4
            if char2nr(a:m) >= 65 && char2nr(a:m) <= 90
                " The id is global to all buffers like the marks using uppercase letters are global to all buffers
                    let id = char2nr(a:m)
            " Lowercase (a-z) {{{4
                else
                    " The id is local to the current buffer like the marks using lowercase letters and numbers are local to the current buffer
                    let id = bufnr('%') . char2nr(a:m)
                endif
            " Remove sign if already added {{{3
                exe 'sign unplace ' . id
            " Define the sign {{{3
                exe 'sign define ' . a:m . ' text=' . a:m . ' texthl=Search'
            " Add the sign {{{3
                exe 'sign place ' . id . ' line=' . line('.') . ' name=' . a:m . ' file=' . expand('%:p')
            " Log the position that was marked
                call g:VmLogToFile(a:m, 0)
            endfu

    fu! g:VmLogToFile(m, show) " Log the position that was marked
            if g:vm_nolog == 1 " This variable is to prevent files being added to the log on opening
                return
                endif
            let l:path = substitute(expand("%:p:h") . '/' . expand("%:t"), '\', '/', 'g')
            " Don't add a marker on entering the visual marks log itself
                if l:path == g:visualMarksLogFilePath
                    return
                    endif
            let l:mark = a:m
            let l:dateTime = strftime("%Y-%m-%d_%H:%M:%S")
            let l:lineNum = line('.') 
            let l:line = getline('.')
            let l:log = l:dateTime . ' [' . l:mark . '] [' . expand("%:t") . '] ' . l:path . ':' . l:lineNum . ' ' . l:line
            " Append the log to the log file
                let l:file = readfile(g:visualMarksLogFilePath)
                call add(l:file, l:log)
                call writefile (l:file, g:visualMarksLogFilePath)
            if a:show != 0 
                " Just to show the file where the mark is logged
                    exe 'split ' . g:visualMarksLogFilePath
                    norm G
                " Copies the log line to the clipboard so that it is possible to paste it somewhere
                    let @* = l:log
            endif
        endfu

    function! g:grep(keywords)
        if a:keywords == ''
            let l:input = input('grep: ', '') 
        else
            let l:input = a:keywords
        endif
        if l:input != '' 
            " Replace the / by \/
                let l:input = substitute(l:input, '/', '\\/', 'ge')
            " Replace the \ by \\
                let l:input = substitute(l:input, '\\', '\\\', 'ge')
            " Replace regex chars
                let l:input = substitute(l:input, '\[', '\\[', 'ge')
                let l:input = substitute(l:input, '\]', '\\]', 'ge')
                let l:input = substitute(l:input, '(', '\(', 'ge')
                let l:input = substitute(l:input, ')', '\)', 'ge')
            silent! exe 'lvimgrep! /' . l:input . '/%' 
            "exe 'lvimgrep! /' . l:input . '/%' 
            lopen 
        endif
    endfunction
