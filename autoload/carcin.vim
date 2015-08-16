" Name: carcin.vim
" URL: https://github.com/MakeNowJust/carcin.vim
" License: MIT <https://makenowjust.github.io/license/mit?2015>
" Repository: https://github.com/MakeNowJust/carcin.vim
" Maintainer: TSUYUSATO Kitsune <make.just.on@gmail.com>

" plugin's convention (begin) {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" load a vital.vim's module {{{
let s:V = vital#of('carcin')
let s:HTTP = s:V.import('Web.HTTP')
let s:JSON = s:V.import('Web.JSON')
" }}}

let s:languages_cache = []
function carcin#languages() abort " {{{
  if ! len(s:languages_cache)
    let url = g:carcin_url . '/languages'
    let result = s:HTTP.request('GET', url, {
          \ 'client': g:carcin_http_client,
          \ })
    if result.status ==# '200'
      let s:languages_cache = s:JSON.decode(result.content).languages
      return s:languages_cache
    else
      throw "Failure to get languages from '" . url . "'"
    endif
  else
    return s:languages_cache
  endif
endfunction " }}}

function carcin#run(code, ...) abort " {{{
  let language = a:0 >= 2 ? a:2 : carcin#languages()[0].name
  let l:version = a:0 >= 3 ? a:3 : ''
  if ! l:version
    for lang in carcin#languages()
      if lang.name ==# language
        let l:version = lang.versions[0]
        break
      endif
    endfor
  endif

  let url = g:carcin_url . '/run_requests'
  let body = s:JSON.encode({
        \ 'code': a:code,
        \ 'language': language,
        \ 'version': l:version,
        \ })
  let result = s:HTTP.request('POST', url, {
        \ 'contentType': 'application/json',
        \ 'data': body,
        \ 'client': g:carcin_http_client,
        \ })
  return s:JSON.decode(result.content).run_request
endfunction " }}}

function! carcin#complete_languages(language) " {{{
  let candidates = []
  for lang in carcin#languages()
    if lang.name =~? a:language
      call add(candidates, lang.name)
    endif
  endfor

  return candidates
endfunction " }}}

function! carcin#complete_versions(language, version) " {{{
  let candidates = []
  for lang in carcin#languages()
    if lang.name ==# a:language
      for ver in lang.versions
        if ver =~? a:version
          call add(candidates, a:language . ':' . ver)
        endif
      endfor
    endif
  endfor

  return candidates
endfunction " }}}

" plugin's convention (end) {{{
let &cpo = s:save_cpo
" }}}

" vim: fdm=marker fdc=2