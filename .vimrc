syn on                    " Set syntax highlighting on
set number                " Show line numbers
set lazyredraw            " Don't redraw while executing macros
set scrolloff=4           " Set 4 lines to the cursor
set ruler                 " Show cursor position
set colorcolumn=73        " Right margin (git commit messages max width)
set title                 " Set the terminal's title
set showcmd               " Display incomplete commands
set showmode              " Display the mode you're in

set autoindent            " Indentation settings
set smartindent
set tabstop=4
set expandtab
set shiftwidth=4
set wrap                  " Word wrap

set t_Co=256              " Colorscheme
set background=dark

set encoding=utf8 nobomb  " Use UTF-8 without BOM
set ffs=unix,dos,mac      " Use Unix as the standard file type

set list                  " Highlight problematic whitespace
set listchars=tab:\ \ ,trail:\ ,extends:#,nbsp:.
