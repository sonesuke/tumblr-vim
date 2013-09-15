" tumblr.vim - Tumblr
" Maintainer:   sonesuke<iamsonesuke@gmail.com>

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

let s:configfile = expand('~/.tumblr-vim')

" Load config file.
function! s:load_settings() "{{{
  silent! unlet s:settings
  if filereadable(s:configfile)
    let s:settings = {}
    silent! sandbox let s:settings = eval(join(readfile(s:configfile), ''))
  else
  endif

  if exists('s:settings')
    let s:token = {}
    let s:token.consumer_key = s:settings.consumer_key
    let s:token.consumer_secret = s:settings.consumer_secret
    let s:token.access_token = s:settings.access_token
    let s:token.access_token_secret = s:settings.access_token_secret
    let s:token.host_name = s:settings.host_name
  else 
    let s:token = {}
    let s:token.consumer_key = ""
    let s:token.consumer_secret = ""
    let s:token.access_token = ""
    let s:token.access_token_secret = ""
    let s:token.host_name = ""
    let s:settings = {}
  endif
endfunction"}}}

" Save settings to config file.
function! s:save_settings() "{{{
  call writefile([string(s:settings)], s:configfile)
endfunction"}}}

" Delete setting file.
function! s:clear_settings() "{{{
  call delete(s:configfile)
endfunction"}}}

"let s:cpo_save = &cpo
"set cpo&vim

" Code {{{
command! -nargs=0 TumblrNew exec("py new_post()")
command! -nargs=0 TumblrPost exec("py post_normal()")
command! -nargs=0 TumblrClearConfig exec("py clear_config()")
" }}}1

" let &cpo = s:cpo_save

:python <<EOF
import vim 
from rauth import OAuth1Service
import re
import webbrowser
import urlparse
from urllib import urlencode, urlopen 


def clear_config():
    vim.eval("s:clear_settings()")

def new_post():
    cb = vim.current.buffer
    for i in range(3):
	cb.append("")
    cb[0] = "replace this title"
    cb[1] = "tag1, tag2, ...."
    cb[2] = "body"
    vim.command("set ft=markdown") # set filetype as html

def get_title():
    first_line = vim.current.buffer[0]
    val = first_line.strip()
    return val


def get_tags():
    first_line = vim.current.buffer[1]
    val = first_line.strip()
    return val


def get_body():
    body = "\n".join(vim.current.buffer[2:])
    return body


def post_normal():
    title = get_title()
    tags = get_tags()
    body = get_body()
    send_post(title, body, tags)


def send_post(title, body, tags): 
    session = get_auth()

    host_name = vim.eval("s:token.host_name")
    url = 'blog/%s/post' % host_name
    body = body.encode('utf-8')

    params = {
	'type': "text",
	'title': title,
	'body': body,
    }
    r = session.post(url, data=params)


def get_auth():
    REQUEST_TOKEN_URL = 'http://www.tumblr.com/oauth/request_token'
    AUTHORIZE_URL = 'http://www.tumblr.com/oauth/authorize'
    ACCESS_TOKEN_URL = 'http://www.tumblr.com/oauth/access_token'
    BASE_URL = 'https://api.tumblr.com/v2/'

    vim.eval("s:load_settings()")

    consumer_key = vim.eval("s:token.consumer_key")
    if consumer_key == '':
	consumer_key = vim_input('consumer key')

    consumer_secret = vim.eval("s:token.consumer_secret")
    if consumer_secret == '':
	consumer_secret = vim_input('consumer secret')

    tumblr = OAuth1Service(
	consumer_key=consumer_key,
	consumer_secret=consumer_secret,
	name='tumblr',
	request_token_url=REQUEST_TOKEN_URL,
	access_token_url=ACCESS_TOKEN_URL,
	authorize_url=AUTHORIZE_URL,
	base_url=BASE_URL)

    access_token = vim.eval("s:token.access_token")
    access_token_secret = vim.eval("s:token.access_token_secret")
    if access_token == '':
	request_token, request_token_secret = tumblr.get_request_token()
	authorize_url = tumblr.get_authorize_url(request_token)
	print 'Visit this URL in your browser: ' + authorize_url
	webbrowser.open(authorize_url)
	authed_url = vim_input("Copy URL from address bar")
	oauth_verifier = re.search('\oauth_verifier=([^#]*)', authed_url).group(1)
	session = tumblr.get_auth_session(request_token,
				      request_token_secret,
				      method='POST',
				      data={'oauth_verifier': oauth_verifier})
	access_token = session.access_token
	access_token_secret = session.access_token_secret
    else:
	session = tumblr.get_session((access_token, access_token_secret))

    host_name = vim.eval("s:token.host_name")
    if host_name== '':
	host_name = vim_input('host name')

    vim.command("silent! unlet s:settings")
    vim.command("let s:settings = {}")
    vim.command('let s:settings.consumer_key = "%s"' % consumer_key)
    vim.command('let s:settings.consumer_secret= "%s"' % consumer_secret)
    vim.command('let s:settings.host_name = "%s"' % host_name)
    vim.command('let s:settings.access_token = "%s"' % access_token)
    vim.command('let s:settings.access_token_secret = "%s"' % access_token_secret)
    vim.command("call s:save_settings()")

    return session


def vim_input(message = 'input', secret = False):
    vim.command('call inputsave()')
    vim.command("let s:user_input = %s('%s :')" % (("inputsecret" if secret else "input"), message))
    vim.command('call inputrestore()')
    return vim.eval('s:user_input') 
 
 
EOF

" vim:set ft=vim ts=8 sw=4 sts=4:
