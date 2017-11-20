" Documentation
    " Name: quickBuf.vim
    " Version: 2.1.2.1
    " Description: Simple and quick buffer explorer
    " Author: Alexandre Viau (alexandreviau@gmail.com)
    " Thanks to: Xaizek
    " Installation: Copy the plugin to the vim plugin directory.

" Usage:
    " Press <leader>b to show the buffer list in the current window
    " Press <leader>B to show the buffer list in a new tab
    " Press <Enter> or 'o' once on the buffer list to open a buffer
    " Press <Del> or dd once on the buffer list to delete a buffer
    " Press 't' once on the buffer list to view buffer in a tab
    " Press ctrl-o after selecting a buffer to return to the buffer list
" Todo:
"   s0 Add to delete multiple buffers
"   s0 When they are more than 1 match for a buffer, delete all

" History:
    " 1.0 Initial release
    " 1.1 Switched <tab>b for <tab>B
    " 1.2 I changed the fixed path c:/temp/buffers.txt to $tmp/buffers.txt
    " 1.2.1 I put the buffers.txt path to a variable
    " 1.2.2 I added 'dd' to delete the buffer under the current line and fixed error messages delete some buffers
    " 1.2.3 I changed the mappings <tab>b to open the buffer list in the current buffer, <tab>B to open the buffer list in a new tab
    " 2.0 Many changes from Xaizek (thanks!). He remove the usage of the paste register, added unix line endings and changed the commands so the buffers are managed by their numbers, which is better than name, so now it works with buffers like [Scratch]
    " 2.1 I added commands to delete the empty lines and the current buffer and remove some commands from being registered to the jump list (thanks to Xaizek for this tip). I replaced also 0w by 0^ in the commands to get the numbers if they start at the beginning of the line.
    " 2.1.1 Xaizek: There were also issues with temporary file as $TMP is not always defined and header wasn't updated to mention <leader> and fixed the t mapping.
    " 2.1.2 Added a mapping to 'o' to open the current buffer under the cursor
    " 2.1.2.1 I updated the version number in the file

let s:tmpPath = empty($TMP) ? "/tmp" : $TMP
let s:bufPath = substitute(s:tmpPath, '\', '/', 'g') . '/buffers.txt'

com! OpenBuffer exe "norm ^:buffer!\<c-r>\<c-w>\<cr>"
com! DeleteBuffer exe "norm ^:silent! bd!\<c-r>\<c-w>\<cr>" | delete
com! OpenBufferTab exe "norm ^:tabnew | buffer!\<c-r>\<c-w>\<cr>"

fu! g:ShowBuffers(winType)
    " Redirect the buffers command output to the bufvar variable
        redir! => bufvar
            " Run the buffer command to and output via redirection to the bufvar variable
            silent buffers
        redir END
    " Open a the current window or a new tab for display
        exe a:winType
    " Paste the buffer list to the new buffer/tab
        0put = bufvar
    " Delete the current buffer (buffers.txt)
        keepjumps silent g/^\s*\d\+\s#/d
    " Delete the empty last and first lines and go to first line. 'keepjumps' Command modifier prevents modification of jump history.
        keepjumps $d
        keepjumps 1d
    " Write the buffers list to disk, so after selecting a file we can go back to the buffer list with ctrl+o
        exe 'silent! w!' s:bufPath
    " Add a mapping to Enter to open the buffer on the current line
        nnoremap <buffer> <Enter> :OpenBuffer<cr>
    " Add a mapping to o to open the buffer on the current line
        nnoremap <buffer> o :OpenBuffer<cr>
    " Add a mapping to open the buffer in new tab
        nnoremap <buffer> t :OpenBufferTab<cr>
    " Add a mapping to Del to delete the buffer on the current line
        nnoremap <buffer> <Del> :DeleteBuffer<cr>
        nnoremap <buffer> dd :DeleteBuffer<cr>
    endfu

"nnoremap <leader>b :call g:ShowBuffers('enew')<cr>
"nnoremap <leader>B :call g:ShowBuffers('tabe')<cr>
nnoremap <tab>b :call g:ShowBuffers('enew')<cr>
nnoremap <tab>B :call g:ShowBuffers('tabe')<cr>

" Mappings I used before this plugin
    " Open a buffer
        " nmap <tab>B :b!
    " Show the list of buffers from the command window and open one (this is the mapping I used before this plugin)
        " nmap <tab>b :buffers<CR>:b!
