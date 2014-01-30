Run `install.sh` to install to your home directory, **overwriting all required
files.** If you run it as root, it will install to `/etc/skel` so that new
users get a copy.

The `master` branch installs a version which is not user-specific. Create a
branch with the same name as your username to add user-specific things such as
git email configuration and authorised keys.

Menlo/Meslo/Consolas is the recommended font. Discussion and documentation is
heavily commented within each configuration file.

Requirements:

  * tmux 1.8+ (which is automatically launched, but only when it's needed)
  * vim 7.3+
  * fish >2.0 (bash, if you don't have fish > 2.0)
  * Dark xterm-256color compatible UTF-8 terminal, SGR 1006 mouse enabled
    (iTerm2, xterm, urxvt-unicode). Urxvt is good.
  * [Mouse support in large terminals][4] is broken with most terminal
    emulators, including PuTTY, except (at least) iTerm2, recent xterms (>277)
    and urxvt. SGR1006 mode is required, and is implemented in [this fork of
    PuTTY][5].
  * [Flow control disabled][2] as it causes unexpected terminal freezing.
    Switched off in bashrc, [now fixed in in fish][3]


![Screenshot](screenshot.png "Why do all terminal screenshots show top or htop running?")


[2]: http://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
[3]: https://github.com/fish-shell/fish-shell/issues/814
[4]: http://superuser.com/questions/413351/weird-insertion-from-vim-on-mouse-click
[5]: https://github.com/unphased/putty-X
