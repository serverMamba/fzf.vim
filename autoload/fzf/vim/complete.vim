" Copyright (c) 2015 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

let s:cpo_save = &cpo
set cpo&vim

function! fzf#vim#complete#word(...)
  return fzf#vim#complete(extend({
    \ 'source': 'cat /usr/share/dict/words'},
    \ get(a:000, 0, g:fzf#vim#default_layout)))
endfunction

" ----------------------------------------------------------------------------
" <plug>(fzf-complete-path)
" <plug>(fzf-complete-file)
" <plug>(fzf-complete-file-ag)
" ----------------------------------------------------------------------------
function! s:file_split_prefix(prefix)
  let expanded = expand(a:prefix)
  return isdirectory(expanded) ?
    \ [expanded,
    \  substitute(a:prefix, '/*$', '/', ''),
    \  ''] :
    \ [fnamemodify(expanded, ':h'),
    \  substitute(fnamemodify(a:prefix, ':h'), '/*$', '/', ''),
    \  fnamemodify(expanded, ':t')]
endfunction

function! s:file_source(prefix)
  let [dir, head, tail] = s:file_split_prefix(a:prefix)
  return printf(
    \ "cd %s && ".s:file_cmd." | sed 's:^:%s:'",
    \ shellescape(dir), empty(a:prefix) || a:prefix == tail ? '' : head)
endfunction

function! s:file_options(prefix)
  let [_, head, tail] = s:file_split_prefix(a:prefix)
  return printf('--prompt %s --query %s', shellescape(head), shellescape(tail))
endfunction

function! s:complete_file(command, extra_opts)
  let s:file_cmd = a:command
  return fzf#vim#complete(extend({
  \ 'prefix':  '\S*$',
  \ 'source':  function('s:file_source'),
  \ 'options': function('s:file_options')}, get(a:extra_opts, 0, g:fzf#vim#default_layout)))
endfunction

function! fzf#vim#complete#path(...)
  return s:complete_file("find . -path '*/\.*' -prune -o -print \| sed '1d;s:^..::'", a:000)
endfunction

function! fzf#vim#complete#file(...)
  return s:complete_file("find . -path '*/\.*' -prune -o -type f -print -o -type l -print \| sed '1d;s:^..::'", a:000)
endfunction

function! fzf#vim#complete#file_ag(...)
  return s:complete_file("ag -l -g ''", a:000)
endfunction

" ----------------------------------------------------------------------------
" <plug>(fzf-complete-line)
" <plug>(fzf-complete-buffer-line)
" ----------------------------------------------------------------------------
function! s:reduce_line(lines)
  return join(split(a:lines[0], '\t\zs')[2:], '')
endfunction

function! fzf#vim#complete#line(...)
  return fzf#vim#complete(extend({
  \ 'prefix':  '^.*$',
  \ 'source':  fzf#vim#_lines(),
  \ 'options': '--tiebreak=index --ansi --nth 3..',
  \ 'reducer': function('s:reduce_line')}, get(a:000, 0, g:fzf#vim#default_layout)))
endfunction

function! fzf#vim#complete#buffer_line(...)
  call fzf#vim#complete(extend({
  \ 'prefix': '^.*$',
  \ 'source': s:uniq(getline(1, '$'))}, get(a:000, 0, g:fzf#vim#default_layout)))
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

