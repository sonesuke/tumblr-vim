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
" if (exists("g:loaded_tumblr") && g:loaded_tumblr) || &cp
"     finish
" endif

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

if !exists('g:tumblr_consumer_key')
    let g:tumblr_consumer_key = ""
endif

if !exists('g:tumblr_consumer_secret')
    let g:tumblr_consumer_secret = ""
endif 

if !exists('g:tumblr_base_hostname')
    let g:tumblr_base_hostname = ""
endif

if !exists('g:tumblr_oauth_verifier')
    let g:tumblr_oauth_verifier = ""
endif

if !exists('g:tumblr_group')
    let g:tumblr_group = ""
endif

:python <<EOF
import vim 
import oauth2
import urlparse
from urllib import urlencode, urlopen 

REQUEST_TOKEN_URL = 'http://www.tumblr.com/oauth/request_token'
AUTHORIZE_URL = 'http://www.tumblr.com/oauth/authorize'
ACCESS_TOKEN_URL = 'http://www.tumblr.com/oauth/access_token'

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
    vim.command('let g:tumblr_consumer_key = ""')
    vim.command('let g:tumblr_consumer_secret = ""')
    vim.command('let g:tumblr_base_hostname = ""')
    vim.command('let g:tumblr_oauth_verifier = ""')

def send_post(title, body, tags): 
    consumer_key = vim.eval("g:tumblr_consumer_key")
    consumer_secret = vim.eval("g:tumblr_consumer_secret")
    base_hostname = vim.eval("g:tumblr_base_hostname")
    oauth_verifier = vim.eval("g:tumblr_oauth_verifier")

    body = body.encode('utf-8')

    if consumer_key == '':
	consumer_key = vim_input('consumer_key')
	vim.command('let g:tumblr_consumer_key = "%s"' % consumer_key)

    if consumer_secret == '':
	consumer_secret = vim_input('consumer_secret')
	vim.command('let g:tumblr_consumer_secret = "%s"' % consumer_secret) 

    if base_hostname == '':
	base_hostname = vim_input('base_hostname')
	vim.command('let g:tumblr_base_hostname = "%s"' % base_hostname)   


    consumer = oauth2.Consumer(key = consumer_key, secret = consumer_secret) 

    request_token = get_request_token(consumer)  
    if len(request_token) == 0:
        print "consumer_key or consumer_secret is invalid"          
        return 
 
    if oauth_verifier == '':
        oauth_verifier = get_verifier(request_token) 
        vim.command('let g:tumblr_oauth_verifier = "%s"' % oauth_verifier)    

    access_token = get_access_token(consumer, request_token, oauth_verifier)  
    print access_token

    url = 'http://api.tumblr.com/v2/blog/%s/post' % base_hostname
    token = oauth2.Token(key = access_token['oauth_token'], secret = access_token['oauth_token_secret']) 

    params = {
        'type': 'text',
        'state': 'draft',
        'title': title,
        'body': body,
    }
    client = oauth2.Client(consumer, token)
    resp, content = client.request(url, method = 'POST', body = urlencode(params)) 


def vim_input(message = 'input', secret = False):
    vim.command('call inputsave()')
    vim.command("let s:user_input = %s('%s :')" % (("inputsecret" if secret else "input"), message))
    vim.command('call inputrestore()')
    return vim.eval('s:user_input') 

def get_request_token(consumer):
    client = oauth2.Client(consumer)
    resp, content = client.request(REQUEST_TOKEN_URL, 'GET')
    return dict(urlparse.parse_qsl(content))
 
def get_verifier(request_token):   
    auth_url = '%s?oauth_token=%s' % (AUTHORIZE_URL, request_token['oauth_token'])   
    print "access verifier url and get oauth verifier:  %s"  % auth_url
    oauth_verifier = vim_input('oauth_verifier')
    return oauth_verifier
 
def get_access_token(consumer, request_token, oauth_verifier):
    token = oauth2.Token(request_token['oauth_token'],
                         request_token['oauth_token_secret'])
    token.set_verifier(oauth_verifier)
    client = oauth2.Client(consumer, token)
    resp, content = client.request(ACCESS_TOKEN_URL, 'POST') 
    return dict(urlparse.parse_qsl(content))

EOF

" vim:set ft=vim ts=8 sw=4 sts=4:
