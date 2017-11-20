" 2017-10-02_18.24.17 

" ####################################################################################################
" # Todo 
" #################################################################################################### 
    " s0 If the line has a comment like fu! myfunction() " blabla then I should be able to wrap it and replacing the " by " = ... for now it is only treating it as a comment line.
    " s0 Add a mapping that will make sure there is the correct spacing before and after the boxes, like for example there shouldn't be 2 boxes one after another without spacing but there should be no spacing between the box and text.
    " s0 After wrapping with a box, if I press u several times to undo I see that one undo as the comment with lowercaps... try to fix that.
    " s0 Remove the remnants of the wf comment boxes // and * if any.

" ####################################################################################################
" # Documentation
" #################################################################################################### 
    " Description: This plugin is to help draw quickly comment boxes and manage them. 

" ####################################################################################################
" # History
" #################################################################################################### 
    " 2017-10-09_14.01.20: Added the possibility to use . instead of · to avoid encoding issues if needed.

" ####################################################################################################
" # Todo
" #################################################################################################### 
    " s0 There is an issue with some lines that should not be in the grep results, specially in batch files, lines like: elif [ "$SHELL" # "/bin/zsh" ]; then
    " s0 Add a mapping with + and - to increase or decrease the level of the selected box
    " s0 Maybe change the middle dot char because it is hard to differenciate with the dash in linux vm font 
    " s0 Maybe add support for boxes that have no comment char before the boxes, like for simple text files?

" ####################################################################################################
" # Variables 
" #################################################################################################### 
    let g:dotChar = '·'
    " let g:dotChar = '.'

" ####################################################################################################
" Utility functions " #
" #################################################################################################### 

    " ====================================================================================================
    fu! s:AdaptBoxChar(boxChar) " = Adapt the chars according to things like the filetype (some files have standard box chars)
    " ==================================================================================================== 
        let boxChar = a:boxChar
        let extension = expand("%:e")
        " if (extension == 'wf') " Comment chars specific to that file type 
        "     if (boxChar =~ '#')
        "         let boxChar = substitute(boxChar, '#', '/', '')
        "     elseif (boxChar == '=')
        "         let boxChar = substitute(boxChar, '=', '*', '')
        "     endif
        " endif
        return boxChar
    endfu

    " ====================================================================================================
    fu! s:CommentBoxChar() " = Set the comment char according to the filetype
    " ==================================================================================================== 
            if (&filetype == 'vim')
                let commentChar = '"'
            elseif (&filetype == 'sql')
                let commentChar = '--'
            elseif (&filetype == 'sh')
                let commentChar = '#'
            elseif (&filetype == 'autohotkey')
                let commentChar = ';'
            else 
                let commentChar = '//'
            endif
            return commentChar
        endfu

    " ====================================================================================================
    fu! s:ReplaceSelectedCommentBoxes(boxCharOld, boxCharNew) " = Replace box chars by another box chars. Will find the chars.
    " ==================================================================================================== 
        let commentBoxChar = s:CommentBoxChar()
        " Escape the box chars that are also regexes chars 
            let boxCharOld1 = a:boxCharOld
            let boxCharOld2 = a:boxCharOld
            if (a:boxCharOld == '*')
                let boxCharOld1 = '\*'
            elseif (a:boxCharOld == '.')
                let boxCharOld1 = '\.'
            endif
        " Replace the box lines
            let s = "silent! s:" . commentBoxChar . '\s\zs\(' . boxCharOld1 . '\{100}\):\=substitute(submatch(0),"' . boxCharOld2 . '","' . a:boxCharNew . '","g"):'
            exe s
        " Replace the char for the line in the middle of the box
            let s = "silent! s:" . commentBoxChar . '\s\zs' . boxCharOld1 . '\ze\(\s\|$\):' . a:boxCharNew . ':'
            exe s
        endfu

    " ====================================================================================================
    fu! s:OpenLocationWindow() " = Will open the location window to the left of the screen
    " ==================================================================================================== 
        " Open on the side
            " lopen
            " wincmd H
            " vertical resize 70
            " norm $
        lopen 25
    endfu

    " ====================================================================================================
    fu! g:UpgradeBoxes() " = Will change the box char to the char below for all lines selected. It will find the boxes.
    " ==================================================================================================== 
        let extension = expand("%:e")
        " if (extension == 'wf') " Comment chars specific to that file type 
        "     cal s:ReplaceSelectedCommentBoxes('*', '/')
        "     cal s:ReplaceSelectedCommentBoxes('-', '*')
        " else
            cal s:ReplaceSelectedCommentBoxes('=', '#')
            cal s:ReplaceSelectedCommentBoxes('-', '=')
            cal s:ReplaceSelectedCommentBoxes(g:dotChar, '-')
        " endif
    endfu
    vnoremap ,q :cal g:UpgradeBoxes()<cr>

    " ====================================================================================================
    fu! g:DowngradeBoxes() " = Will change the box char to the char below for all lines selected. It will find the boxes.
    " ==================================================================================================== 
        let extension = expand("%:e")
        " if (extension == 'wf') " Comment chars specific to that file type 
        "     cal s:ReplaceSelectedCommentBoxes('*', '-')
        "     cal s:ReplaceSelectedCommentBoxes('/', '*')
        " else
            cal s:ReplaceSelectedCommentBoxes('-', g:dotChar)
            cal s:ReplaceSelectedCommentBoxes('=', '-')
            cal s:ReplaceSelectedCommentBoxes('#', '=')
        " endif
    endfu
    vnoremap ,z :cal g:DowngradeBoxes()<cr>

    " ====================================================================================================
    " = Correct dot chars · if they are displayed as Â·
    " ==================================================================================================== 
        " This may happen after a file is encoded to UTF-8
        map ,c :%s,Â·,·,g<cr>

" ####################################################################################################
" #  Grep the comment boxes (to navigate them)
" #################################################################################################### 

    " ====================================================================================================
    " = Grep all comment boxes
    " ==================================================================================================== 
        com! GrepCommentBox :lclose | silent w! | silent! lvimgrep ,\(//\|"\|--\|#\|;\)\s\(#\|/\|=\|-\|\*\|·\|\.\)\(\s\|$\), % | cal s:OpenLocationWindow()
            nmap ,` :GrepCommentBox<cr>

    " ====================================================================================================
    fu! g:GrepCommentBoxByLevel(boxChar) " = Grep only some comment box by level
    " ==================================================================================================== 
            lclose 
            silent w! 
            let boxChar = s:AdaptBoxChar(a:boxChar)
            exe 'silent! lvimgrep ,\(//\|"\|--\|#\|;\)\s\(' . boxChar . '\)\(\s\|$\), %'
            echo 'lvimgrep ,\(//\|"\|--\|#\|;\)\s\(' . boxChar . '\)\(\s\|$\), %'
            cal s:OpenLocationWindow()
        endfu
        " Here multiple box chars are passed so that a level is shown with its parents, for structure and so in a way to limit detail level 
        nmap ,1 :cal g:GrepCommentBoxByLevel('#')<cr>
        nmap ,2 :cal g:GrepCommentBoxByLevel('#\\|=')<cr>
        nmap ,3 :cal g:GrepCommentBoxByLevel('#\\|=\\|-')<cr>
        nmap ,4 :cal g:GrepCommentBoxByLevel('#\\|=\\|-\\|·\\|\.')<cr>

    " ====================================================================================================
    " = Grep all comments
    " ==================================================================================================== 
        com! GrepCommentsAll :lclose | silent w! | silent! lvimgrep ,^\s*\(//\|"\), % | cal s:OpenLocationWindow()
            nmap ,0 :GrepCommentsAll<cr>

" ####################################################################################################
" # Draw comment boxes
" #################################################################################################### 

        " " ====================================================================================================
        " fu! s:DrawLine(boxChar, nbChar) " = Draw a comment box line of n number of characters specified by nbChar
        " " ==================================================================================================== 
        "     let line = ''
        "      for i in range(1, a:nbChar)
        "          let line .= a:boxChar
        "      endfor
        "     return line
        " endfu

        " ====================================================================================================
        fu! g:DrawCommentBox(boxChar) " = Draw a comment box of the specified box char.
        " ==================================================================================================== 
            set formatoptions-=r formatoptions-=c formatoptions-=o " To make sure the line is cleared and there is no autocomment
            let commentChar = s:CommentBoxChar()
            let boxChar = s:AdaptBoxChar(a:boxChar)
            norm o
            norm o
            " Line1
                exe 'norm i' . commentChar . ' '
                exe 'norm 100a' . boxChar
            " Line2
                exe 'norm o '
                exe 'norm i' . commentChar . ' '
                exe 'norm i ' . boxChar
            " Line3
                exe 'norm o '
                exe 'norm i' . commentChar . ' '
                exe 'norm 100a' . boxChar
            norm kk
        endfu

        " ====================================================================================================
        fu! g:WrapCommentBox(boxChar) " = To put a comment box around an existing line.
        " ==================================================================================================== 
            let commentChar = s:CommentBoxChar()
            let hasComment = 0
            "if (getline('.') =~ '^\s*' . commentChar)
            if getline('.') =~ commentChar
                let hasComment = 1
            endif
            cal g:DrawCommentBox(a:boxChar) 
            " Put the line inside the box
                norm kkddjjpkJX
            if hasComment == 1
                " Delete the comment char
                    norm dw
            else
                " Put the comment part at the end of the line
                    norm XD0Pa 
            endif
            " Put back the box at the position the line was
                norm kkdd
            " Select the box
                norm jjVkk
            endfu

            " ----------------------------------------------------------------------------------------------------
            " - Mappings to draw boxes (the select it)
            " ---------------------------------------------------------------------------------------------------- 
                nmap \# :cal g:DrawCommentBox('#') \| norm jjVkk<cr>
                nmap \= :cal g:DrawCommentBox('=') \| norm jjVkk<cr>
                    nmap \+ :cal g:DrawCommentBox('=') \| norm jjVkk<cr>
                nmap \- :cal g:DrawCommentBox('-') \| norm jjVkk<cr>
                    nmap \_ :cal g:DrawCommentBox('-') \| norm jjVkk<cr>
                nmap \. :cal g:DrawCommentBox(g:dotChar) \| norm jjVkk<cr>
                    nmap \< :cal g:DrawCommentBox(g:dotChar) \| norm jjVkk<cr>

            " ----------------------------------------------------------------------------------------------------
            " - Mappings to wrap boxes around an existing commented line
            " ---------------------------------------------------------------------------------------------------- 
                nmap ,# :cal g:WrapCommentBox('#')<cr>
                nmap ,z :cal g:WrapCommentBox('/')<cr>
                nmap ,= :cal g:WrapCommentBox('=')<cr>
                    nmap ,+ :cal g:WrapCommentBox('=')<cr>
                nmap ,- :cal g:WrapCommentBox('-')<cr>
                    nmap ,_ :cal g:WrapCommentBox('-')<cr>
                nmap ,. :cal g:WrapCommentBox(g:dotChar)<cr>
                    nmap ,< :cal g:WrapCommentBox(g:dotChar)<cr>
