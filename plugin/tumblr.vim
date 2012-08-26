" tumblr.vim - Tumblr
" Maintainer:   Travis Jeffery <eatsleepgolf@gmail.com>
" Time-stamp: <Mon Sep  1 15:50:46 EDT 2008 Travis Jeffery>
"
"Exit quickly when:
"- this plugin was already loaded (or disabled)
"- when 'compatible' is set
if !has('python')
    finish
endif
if (exists("g:loaded_tumblr") && g:loaded_tumblr) || &cp
    finish
endif

let g:loaded_tumblr = 1

"let s:cpo_save = &cpo
"set cpo&vim

" Code {{{1
command! -nargs=0 TumblrNew exec("py new_post()")
command! -nargs=0 TumblrPost exec("py post_normal()")
command! -nargs=0 TumblrClearConfig exec("py clear_config()")
command! -nargs=0 TumblrSwitchGroup exec("py switch_group()")
" }}}1

" let &cpo = s:cpo_save

if !exists('g:tumblr_email')
    let g:tumblr_email = ""
endif

if !exists('g:tumblr_password')
    let g:tumblr_password = ""
endif

if !exists('g:tumblr_group')
    let g:tumblr_group = ""
endif

:python <<EOF
import vim
from urllib import urlencode, urlopen

def new_post():
    cb = vim.current.buffer
    vim.command("set ft=mkd") # set filetype as markdown

def get_title():
    first_line = vim.current.buffer[0]
    title = first_line.strip()
    return title

def get_tags():
    first_line = vim.current.buffer[1]
    title = first_line.strip()
    return title

def get_body():
    body = "\n".join(vim.current.buffer[2:])
    return body

def post_normal():
    title = get_title()
    tags = get_tags()
    body = get_body()
    send_post(title, body, tags)

def clear_config():
    vim.command('let g:tumblr_email = ""')
    vim.command('let g:tumblr_password = ""')
    vim.command('let g:tumblr_group = ""')

def switch_group():
    new_group = vim_input('new group')
    vim.command('let g:tumblr_group = "%s"' % new_group)
    vim.command('redraw!')
    print "changed to " + new_group

def send_post(title, body, tags):
    url = "http://www.tumblr.com/api/write"
    email = vim.eval("g:tumblr_email")
    password = vim.eval("g:tumblr_password")
    group = vim.eval("g:tumblr_group")
    enc = vim.eval('&encoding')
    body = body.decode(enc).encode('utf-8')

    if email == '':
	email = vim_input('mail')
	vim.command('let g:tumblr_email = "%s"' % email)

    if password == '':
	password = vim_input('password')
	vim.command('let g:tumblr_password = "%s"' % password)

    if group == '':
	data = urlencode({"email" : email, "password" : password, "title" : title, "body" : body, "format": "markdown", "tags":tags})
    else:
	data = urlencode({"email" : email, "password" : password, "title" : title, "body" : body, "format": "markdown", "tags":tags, "group": group})
    res = urlopen(url, data)

    vim.command('redraw!')

    if res.code == 201:
	print "Posted"
    if res.code == 403:
	print "Bad Authentication"
    if res.code == 400:
	print "Bad Request"

def vim_input(message = 'input', secret = False):
    vim.command('call inputsave()')
    vim.command("let s:user_input = %s('%s :')" % (("inputsecret" if secret else "input"), message))
    vim.command('call inputrestore()')
    return vim.eval('s:user_input')

EOF

" vim:set ft=vim ts=8 sw=4 sts=4:
