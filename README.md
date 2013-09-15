# tumblr.vim
Script that allows you to post regular type posts to Tumblr.

## Install
Install python rauth package:

 $ pip install rauth

Get an Tumblr's OAuth key: [register an application](http://www.tumblr.com/oauth/apps).
They are required to enter for the first post.

If you are a Vundle user:

1. run :BundleInstall sonesuke/tumblr-vim within Vim
1. add Bundle 'sonesuke/tumblr-vim' to your Vundle powered .vimrc

## Features
- Begin a new post by opening a buffer and using the :TumblrNew command.
- when finished use the :TumblrPost command.

For the first post, you will need to enter CONSUMER KEY and CONSUMER SECRET.

## Requrements
Compiling Vim with +Python is required.
It can be confirmed by :echo has('python') == 1.


## Acknowledgements
This plugin is based on [Travis Jeffery's script](http://www.vim.org/scripts/script.php?script_id=2329) and [nihitok's gist](https://gist.github.com/2179770).
