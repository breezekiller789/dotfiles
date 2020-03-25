" https://github.com/sontek/dotfiles/
" ==========================================================
" Dependencies - Libraries/Applications outside of vim
" ==========================================================
" Pep8 - http://pypi.python.org/pypi/pep8
" Pyflakes
" Ack
" nose, django-nose

" ==========================================================
" Plugins included
" ==========================================================
" Pathogen
"     Better Management of VIM plugins
"
" GunDo
"     Visual Undo in vim with diff's to check the differences
"
" Pytest
"     Runs your Python tests in Vim.
"
" Commant-T
"     Allows easy search and opening of files within a given path
"
" Snipmate
"     Configurable snippets to avoid re-typing common comands
"
" PyFlakes
"     Underlines and displays errors with Python on-the-fly
"
" Fugitive [Removed by Happyholic1203]
"    Interface with git from vim
"
" Git
"    Syntax highlighting for git config files
"
" Pydoc
"    Opens up pydoc within vim
"
" Surround
"    Allows you to surround text with open/close tags
"
" Py.test
"    Run py.test test's from within vim
"
" MakeGreen
"    Generic test runner that works with nose
"
" ==========================================================
" Shortcuts
" ==========================================================
set nocompatible              " Don't be compatible with vi
let mapleader=","             " change the leader to be a comma vs slash

" Seriously, guys. It's not like :W is bound to anything anyway.
command! W :w

" fu! SplitScroll()
"     :wincmd v
"     :wincmd w
"     execute "normal! \<C-d>"
"     :set scrollbind
"     :wincmd w
"     :set scrollbind
" endfu

" <C-O> is used by tmux
inoremap <C-\> <C-X><C-O>

" Go to last active tab
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <leader>; :exe "tabn ".g:lasttab<CR>
vnoremap <silent> <leader>; :exe "tabn ".g:lasttab<CR>

"<CR><C-w>l<C-f>:set scrollbind<CR>

" sudo write this
cmap W! w !sudo tee % >/dev/null

" Toggle the tagbar
map <leader>tt :TagbarToggle<CR>

" Toggle the tasklist
map <leader>td <Plug>TaskList

" Run pep8
let g:pep8_map='<leader>8'

" Go to the last active tab
let g:lasttab = 1
nmap <leader>; :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" run py.test's
nmap <silent><Leader>tf <Esc>:Pytest file<CR>
nmap <silent><Leader>tc <Esc>:Pytest class<CR>
nmap <silent><Leader>tm <Esc>:Pytest method<CR>
nmap <silent><Leader>tn <Esc>:Pytest next<CR>
nmap <silent><Leader>tp <Esc>:Pytest previous<CR>
nmap <silent><Leader>te <Esc>:Pytest error<CR>

" Run django tests
map <leader>dt :set makeprg=python\ manage.py\ test\|:call MakeGreen()<CR>

" Reload Vimrc
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" open/close the quickfix window
nmap <leader>co :copen<CR>
nmap <leader>cc :cclose<CR>:pclose<CR>

" for when we forget to use sudo to open/edit a file
cmap w!! w !sudo tee % >/dev/null

" ctrl-jklm  changes to that split
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" and lets make these all work in insert mode too ( <C-O> makes next cmd
"  happen as if in command mode )
" imap <C-W> <C-O><C-W>

" Open NerdTree
map <leader>n :NERDTreeToggle<CR>

if executable('fzf')
    set rtp+=~/.fzf
    map <leader>f :FZF<CR>
else
    map <leader>f :CtrlP<CR>
endif
map <leader>b :CtrlPBuffer<CR>

" Tab navigation
map <leader>h :tabprevious<CR>
map <leader>l :tabnext<CR>

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-follow
    nmap <leader>g <Esc>:Lines<Cr>
    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --ignore-case '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)
    nmap <leader>s <Esc>:Rg<Cr>

    " bind \ to grep word under cursor
    nnoremap \ :Rg <C-R><C-W><CR>
elseif executable('ag')
    " https://robots.thoughtbot.com/faster-grepping-in-vim
    " Use ag over grep
    set grepprg=ag\ --nogroup\ --nocolor

    " Use ag in CtrlP for listing files. Lightning fast and respects
    " .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0

    " Ag searching
    nmap <leader>s <Esc>:Ag!<SPACE>
    set runtimepath^=~/.vim/bundle/ag

    " bind \ to grep word under cursor
    nnoremap \ :Ag! "\b<C-R><C-W>\b"<CR>:cw<CR>
else
    set grepprg=ack         " replace the default grep program with ack
    " Makes CtrlP index faster in linux
    " ref: http://freehaha.blogspot.tw/2012/11/ctrlpvim.html
    " Ignores the files specified in .ctrlpignore
    let g:ctrlp_user_command = {
        \ 'types': {
        \ 1: ['.git', 'cd %s && git ls-files -c -o --exclude-standard | egrep -v "\.(png|jpg|jpeg|gif)$|node_modules|.*\.swp"'],
        \ 2: ['.hg', 'hg --cwd %s locate -I . | egrep -v "\.(png|jpg|jpeg|gif)$|node_modules|.*\.swp)"'],
        \ },
        \ 'fallback': 'find %s -type f | egrep -v "\.(png|jpg|jpeg|gif)$|node_modules|.*\.swp"'
        \ }

    " Ack searching
    nmap <leader>s <Esc>:Ack!
endif

" ==========================================================
" Pathogen - Allows us to organize our vim plugins
" ==========================================================
" Load pathogen with docs for all plugins
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Done by YouCompleteMe
" autocmd VimEnter * imap <expr> <Tab> pumvisible() ? "<C-N>" : "<Tab>"
" autocmd VimEnter * imap <expr> <S-Tab> pumvisible() ? "<C-P>" : "<S-Tab>"

let g:UltiSnipsExpandTrigger = "<C-J>"
let g:UltiSnipsListSnippets = "<C-L>"
let g:UltiSnipsJumpForwardTrigger = "<C-J>"
let g:UltiSnipsJumpBackwardTrigger = "<C-K>"

" Disable paste mode when leaving insert mode
au InsertLeave * set nopaste

" ==========================================================
" Basic Settings
" ==========================================================
syntax on                     " syntax highlighing
filetype on                   " try to detect filetypes
filetype plugin indent on     " enable loading indent file for filetype
set number                    " Display line numbers
set numberwidth=1             " using only 1 column (and 1 space) while possible
set relativenumber
set background=dark           " We are using dark background in vim
set title                     " show title in console title bar
set wildmenu                  " Menu completion in command mode on <Tab>
set wildmode=full             " <Tab> cycles between all matching choices.

" Ignore these files when completing
set wildignore+=*.o,*.obj,.git,*.pyc
set wildignore+=eggs/**
set wildignore+=*.egg-info/**

" Set working directory
nnoremap <leader>. :NERDTreeFind<CR>

" Keep search pattern at the center of the screen
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Easier moving of code blocks (better indentation)
vnoremap < <gv
vnoremap > >gv

" Disable the colorcolumn when switching modes.  Make sure this is the
" first autocmd for the filetype here
"autocmd FileType * setlocal colorcolumn=0

""" Insert completion
" don't select first item, follow typing in autocomplete
set completeopt=menuone,longest,preview
set pumheight=6             " Keep a small completion window


""" Moving Around/Editing
set cursorline              " have a line indicate the cursor location
set ruler                   " show the cursor position all the time
set nostartofline           " Avoid moving cursor to BOL when jumping around
set virtualedit=block       " Let cursor move past the last char in <C-v> mode
set scrolloff=3             " Keep 3 context lines above and below the cursor
set backspace=2             " Allow backspacing over autoindent, EOL, and BOL
set showmatch               " Briefly jump to a paren once it's balanced
set nowrap                  " don't wrap text
set linebreak               " don't wrap textin the middle of a word
set autoindent              " always set autoindenting on
set smartindent             " use smart indent if there is no indent file
set tabstop=4               " <tab> inserts 4 spaces 
set shiftwidth=4            " but an indent level is 2 spaces wide.
set softtabstop=4           " <BS> over an autoindent deletes both spaces.
set expandtab               " Use spaces, not tabs, for autoindent/tab key.
set shiftround              " rounds indent to a multiple of shiftwidth
set matchpairs+=<:>         " show matching <> (html mainly) as well
set foldmethod=indent       " allow us to fold on indents
set foldlevel=99            " don't fold by default

" don't outdent hashes
inoremap # #

" close preview window automatically when we move around
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"""" Reading/Writing
set noautowrite             " Never write a file unless I request it.
set noautowriteall          " NEVER.
set noautoread              " Don't automatically re-read changed files.
set modeline                " Allow vim options to be embedded in files;
set modelines=5             " they must be within the first or last 5 lines.
set ffs=unix,dos,mac        " Try recognizing dos, unix, and mac line endings.

"""" Messages, Info, Status
set ls=2                    " always show status line
set vb t_vb=                " Disable all bells.  I hate ringing/flashing.
set noerrorbells            " don't bell or blink
set confirm                 " Y-N-C prompt if closing with unsaved changes.
set showcmd                 " Show incomplete normal mode commands as I type.
set report=0                " : commands always print changed line count.
set shortmess+=a            " Use [+]/[RO]/[w] for modified/readonly/written.
set ruler                   " Show some info, even without statuslines.
set laststatus=2            " Always show statusline, even if only 1 window.

" displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,eol:$,trail:-,precedes:<,extends:>
"set list

""" Searching and Patterns
set ignorecase              " Default to using case insensitive searches,
set smartcase               " unless uppercase letters are used in the regex.
set smarttab                " Handle tabs more intelligently 
set hlsearch                " Highlight searches by default.
set incsearch               " Incrementally search while typing a /regex

"""" Display
if has("gui_running")
    " Remove menu bar
    set guioptions-=m

    " Remove toolbar
    set guioptions-=T
endif

colorscheme vividchalk
" colorscheme molokai
set t_Co=256
set background=dark
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE

" Python-mode
" Activate rope
" Keys:
" K             Show python docs
" [[            Jump on previous class or function (normal, visual, operator modes)
" ]]            Jump on next class or function (normal, visual, operator modes)
" [M            Jump on previous class or method (normal, visual, operator modes)
" ]M            Jump on next class or method (normal, visual, operator modes)
" <Ctrl-]>      Jump to definition
" <leader>r     Run python code
" <leader>R     Rename a class/function/variable

let g:pymode = 1
let g:pymode_rope = 1
let g:pymode_rope_completion = 1
let g:pymode_rope_completion_bind = '<C-\>'
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_autoimport = 0
let g:pymode_rope_lookup_project = 0

" Drags down speed too much
let g:pymode_folding = 0

let g:pymode_syntax = 1

" Override go-to.definition key shortcut to Ctrl-]
let g:pymode_rope_goto_definition_bind = "<C-]>"
let g:pymode_rope_rename_bind = "<leader>R"

" Load run code plugin
let g:pymode_run = 1
let g:pymode_run_key = "<leader>r"
let g:pymode_debug = 0

" "Linting
let g:pymode_lint = 1
let g:pymode_lint_on_fly = 0
let g:pymode_lint_on_write = 1
let g:pymode_lint_checkers = ["pyflakes", "pep8", "pylint"]
let g:pymode_lint_ignore = 'C0111,F0401,W0703,W1201'

let g:pymode_breakpoint = 0

" ==========================================================
" YouCompleteMe Settings
" ==========================================================
" with YouCompleteMe, ctags is no longer needed: replace with YCM functions
au FileType c,cpp,h,hpp nnoremap <C-]> :sp<CR>:YcmCompleter GoTo<CR>
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_filetype_whitelist = { 'cpp': 1, 'c': 1 }
" use python-mode
let g:ycm_filetype_blacklist = { 'python': 1 }

" Copy to clipboard
vnoremap <C-c> "*y

" Paste from clipboard
map <leader>p "+p

" Quit window on <leader>q
nnoremap <leader>q :q<CR>

" hide matches on <leader>space
nnoremap <leader><space> :nohlsearch<cr>

" Remove trailing whitespace on <leader>S
nnoremap <leader>S :%s/\s\+$//<cr>:let @/=''<CR>

" Select the item in the list with enter
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" ==========================================================
" Javascript
" ==========================================================
au BufRead *.js set makeprg=jslint\ %

let g:acp_completeoptPreview=1

let g:jsx_ext_required = 0

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" XXX quickfix for 'error| Unknown directive type "toctree"'
let g:syntastic_mode_map = { 'passive_filetypes': ['rst'] }
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
" Avoid slow open
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

" npm install -g jsxhint
let g:syntastic_javascript_checkers = ['eslint']

" ===========================================================
" FileType specific changes
" ============================================================
" Mako/HTML
autocmd BufNewFile,BufRead *.html set filetype=htmldjango
autocmd BufNewFile,BufRead *.mako,*.mak,*.jinja2 setlocal ft=html
autocmd FileType html,xhtml,xml,css setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType javascript.jsx setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml,yml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

" xm/m
autocmd BufNewFile,BufRead *.xm setlocal ft=objc

" Python
"au BufRead *.py compiler nose
au FileType python set omnifunc=pythoncomplete#Complete
au FileType python setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4 cindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
au FileType coffee setlocal expandtab shiftwidth=4 tabstop=8 softtabstop=4 smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class,with
au BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
" Don't let pyflakes use the quickfix window
let g:pyflakes_use_quickfix = 0

" Add the virtualenv's site-packages to vim path
if has('python')
py << EOF
import os.path
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF
endif

" Load up virtualenv's vimrc if it exists
if filereadable($VIRTUAL_ENV . '/.vimrc')
    source $VIRTUAL_ENV/.vimrc
endif

if exists("&colorcolumn")
   set colorcolumn=79
endif

" Extension to read pdf files
" NOTE: need to install [xpdf](http://www.foolabs.com/xpdf/download.html)
:command! -complete=file -nargs=1 Rpdfraw :tabe|r !pdftotext -nopgbrk <q-args> -
:command! -complete=file -nargs=1 Rpdf :tabe|r !pdftotext -nopgbrk <q-args> - |fmt -sw78

set fileencodings=utf-8,big5
set fileencoding=utf8
" Fix docker container mount volume problem
" https://forums.docker.com/t/modify-a-file-which-mount-as-a-data-volume-but-it-didnt-change-in-container/2813/10
set backupcopy=yes

" Enable syntax-aware folding in json files
autocmd BufNewFile,BufRead *.json setlocal foldmethod=syntax

" Enable syntax highlight for thrift files
au BufRead,BufNewFile *.thrift set filetype=thrift
au! Syntax thrift source ~/.vim/plugin/thrift.vim
autocmd BufNewFile,BufRead *.c,*.cpp,*.cc,*.h,*.hpp nnoremap <silent><buffer>K :MMan3<CR>:redraw!<CR>

nnoremap <leader>p :!which ipython && ipython \|\| python<CR><CR>:redraw!<CR>

" Compatible with ranger 1.4.2 through 1.7.*
"
" Add ranger as a file chooser in vim
"
" If you add this code to the .vimrc, ranger can be started using the command
" ":RangerChooser" or the keybinding "<leader>r".  Once you select one or more
" files, press enter and ranger will quit again and vim will open the selected
" files.

function! RangeChooser()
    let temp = tempname()
    " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
    " with ranger 1.4.2 through 1.5.0 instead.
    "exec 'silent !ranger --choosefile=' . shellescape(temp)
    if has("gui_running")
        exec 'silent !xterm -e ranger --choosefiles=' . shellescape(temp)
    else
        exec 'silent !ranger --choosefiles=' . shellescape(temp)
    endif
    if !filereadable(temp)
        redraw!
        " Nothing to read.
        return
    endif
    let names = readfile(temp)
    if empty(names)
        redraw!
        " Nothing to open.
        return
    endif
    " Edit the first item.
    exec 'edit ' . fnameescape(names[0])
    " Add any remaning items to the arg list/buffer list.
    for name in names[1:]
        exec 'argadd ' . fnameescape(name)
    endfor
    redraw!
endfunction
command! -bar RangerChooser call RangeChooser()
nnoremap <leader>r :<C-U>RangerChooser<CR>

" Go to last active tab
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <leader>; :exe "tabn ".g:lasttab<CR>
vnoremap <silent> <leader>; :exe "tabn ".g:lasttab<CR>

" We can easily indent by ourselves: ctrl-d, ctrl-t in insert mode
" set indentexpr=

let NERDTreeIgnore = ['\.pyc$', '\.egg-info$', '__pycache__']

""""""""""""
"  Golang  "
""""""""""""

" Open :GoDeclsDir with ctrl-g
nmap <C-g> :GoDeclsDir<cr>
imap <C-g> <esc>:<C-u>GoDeclsDir<cr>

augroup go
    autocmd FileType go nnoremap <leader>r :GoRun<CR>
    autocmd FileType go nnoremap <leader>t :GoTest<CR>
    autocmd FileType go nnoremap <leader>i :GoImports<CR>
    autocmd FileType go inoremap <C-i> <C-O>:GoImport
    " :GoCoverageToggle
    autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
    " :GoDef but opens in a vertical split
    autocmd FileType go nmap <Leader>v <Plug>(go-def-vertical)
augroup END

let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_fields = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_function_arguments = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
" let g:go_def_mode = 'godef'
" let g:rehash256 = 1
" let g:molokai_original = 1
" colorscheme molokai
