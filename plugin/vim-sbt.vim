let s:bundle_path = expand('<sfile>:p:h:h') . '/'
let g:sbt_errors_status = "sbt running..."

func! RunBundleShellScript(filename, callback)
	let l:command = '/bin/bash ' . s:bundle_path . a:filename
	let l:options = {"exit_cb": a:callback}
	call job_start(l:command, l:options)
endfunc

func! OnLoadErrorsDone(job, status)
	if a:status != 0
		echoerr "Loading errors from sbt failed with status code " . a:status
		return
	endif
	call s:LoadErrors()
	if !len(getqflist())
		call RunBundleShellScript('test_errors.sh', 'OnLoadTestErrorsDone')
	endif 
endfunc

func! OnLoadTestErrorsDone(job, status)
	if a:status != 0
		echoerr "Loading testherrors from sbt failed with status code " . a:status
		return
	endif
	call s:LoadErrors()
endfunc

func! s:LoadErrors()
	" SBT 1
	setlocal errorformat=%E\ %#[error]\ %#%f:%l:%c:\ %m,%-Z\ %#[error]\ %p^,%-C\ %#[error]\ %m,%C\ %m
	setlocal errorformat+=%W\ %#[warn]\ %#%f:%l:%c:\ %m,%-Z\ %#[warn]\ %p^,%-C\ %#[warn]\ %m,%C\ %m

	" SBT 0
	setlocal errorformat+=%E\ %#[error]\ %#%f:%l:\ %m,%-Z\ %#[error]\ %p^,%-C\ %#[error]\ %m,%C\ %m
	setlocal errorformat+=%W\ %#[warn]\ %#%f:%l:\ %m,%-Z\ %#[warn]\ %p^,%-C\ %#[warn]\ %m,%C\ %m

	setlocal errorformat+=%-G%.%#
	cg ./target/errors.err
	cw
endfunc

func! LoadSbtErrors()
	call setqflist([])
	call RunBundleShellScript('errors.sh', 'OnLoadErrorsDone')
endfunc

func! SbtCallback(channel, msg)
	if a:msg =~ "Waiting for source changes"
		let g:sbt_errors_status = "sbt waiting..."
		AirlineRefresh
		let g:changed = 1
		call LoadSbtErrors()
	else
		let g:sbt_errors_status = "sbt running..."
		if exists('g:changed') && g:changed
			AirlineRefresh
			let g:changed = 0
		endif
	endif
endfunc

func! s:SbtStop()
	if exists('s:job')
		job_stop(s:job)
	endif
endfunc

func! s:SbtStart()
	call s:SbtStop()
	let g:airline_section_x = '%{g:sbt_errors_status}'
	let g:airline_section_error = '%{len(getqflist()) ? len(getqflist()) : ""}'
	AirlineRefresh
	let s:job = job_start("sbt ~test:compile", {"callback": "SbtCallback"})
endfunc
		
command! Sbtstart call s:SbtStart()
command! Sbtstop call s:SbtStop()
command! Sbtcg call LoadSbtErrors()
