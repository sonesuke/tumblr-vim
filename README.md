# tumblr.vim
Script that allows you to post regular type posts to Tumblr.

## Features
- Begin a new post by opening a buffer and using the :TumblrNew command.
- when finished use the :TumblrPost command.

## Requrements
Compiling Vim with +Python is required.
It can be confirmed by :echo has('python') == 1.

## Details
You can set your account informations as follows.
~~~vim
let g:tumblr_email="YOUR EMAIL"
let g:tumblr_password="YOUR PASSWORD"
~~~

If you'd like to post it to a secondary blog on your account, set the following parameter. e.g. yourgroup.tumblr.com(for public groups only)
~~~vim
let g:tumblr_group="yourgroup.tumblr.com"
~~~

If you don't set these, you will be asked them on first post.

## Acknowledgements
This plugin is based on [Travis Jeffery's script](http://www.vim.org/scripts/script.php?script_id=2329) and [nihitok's gist](https://gist.github.com/2179770).
