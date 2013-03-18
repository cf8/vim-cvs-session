function FindProjectName()
	let g:project_name = ""
python << EOF
import sys, os, vim

dcvs_list = ('.hg', '.svn', '.git')

def check_dvcs(d):
    for dcvs in dcvs_list:
        if os.path.exists(os.path.join(d,dcvs)):
            return True 
    return False

def walk_up(cwd):
    new_path = os.path.realpath(os.path.join(cwd, '..'))
    yield new_path

    if new_path == cwd:
        return

    for x in walk_up(new_path):
        yield x

def main(cwd):
    cwd = os.path.abspath(cwd)
    result = ''
    if check_dvcs(cwd):
        result = os.path.basename(cwd)
    else:
        for i in walk_up(cwd):
            if check_dvcs(i): result = os.path.basename(i)

    vim.command('let g:project_name="%s"' % result)

main(os.getcwd())
EOF
	return g:project_name
endfunction

" Sessions only restored if we start vim without args.
function! RestoreSession(name)
	unlet g:project_name
	if a:name != ''
		if filereadable($HOME . '/.vim/sessions/' . a:name)
			execute 'source ' . $HOME . '/.vim/sessions/' . a:name
		end
	end
endfunction

" Sessions only saved if we start vim without args.
function! SaveSession(name)
	unlet g:project_name
	if a:name != ''
		execute 'mksession! ' . $HOME . '/.vim/sessions/' . a:name
	end
endfunction

"
" Restore and save sessions.
"
if argc() == 0
	autocmd VimEnter * call RestoreSession(FindProjectName())
	autocmd VimLeave * call SaveSession(FindProjectName())
end
