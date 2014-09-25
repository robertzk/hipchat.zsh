hipchat.zsh

A zsh plugin to send messages over Hipchat to your friends through shell. You should have `curl`
installed set the environment variable `HIPCHAT_API_TOKEN`.
Then you can send quick pings from the command line!

```bash
hipchat your@friend.com Hey buddy
```

If you run into trouble you can also use the `-d` to output the URL and POST 
parameters that are sent to the [Hipchat API](https://www.hipchat.com/docs/apiv2/method/private_message_user).

*Note*: If no `@` character is detected in the first argument, it will assume
you would like to [send to a room](https://www.hipchat.com/docs/apiv2/method/send_room_notification) instead.

Installation
--------

Assuming you have [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), you can
simply write

```bash
git clone git@github.com:robertzk/hipchat.zsh.git ~/.oh-my-zsh/custom/plugins/hipchat
echo "plugins+=(hipchat)" >> ~/.zshrc
```

(Alternatively, you can place the `sudo` plugin in the `plugins=(...)` local in your `~/.zshrc` manually.)

Usage
------

```bash
Usage: hipchat [-d] <email or room> <message>
-d: debug (more verbose output)
```

