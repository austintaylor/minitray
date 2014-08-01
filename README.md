minitray
========

Once upon a time I ran Vim all day inside tmux in iTerm 2 in fullscreen, and I tricked out my tmux status
line with the time, my battery status, and the current weather. I became pretty reliant on this, as I could
not see the OS X menu bar while in fullscreen, and I liked being able to see this information without having
to move the mouse or whatever.

Then one day I switched to Emacs.

I decided to run gui Emacs rather than putting inside tmux, for a variety of reasons. For the most part I
have been happy with this setup. I run the Mac version of Emacs in non-Lion fullscreen, the same as I ran
iTerm 2. However, because Emacs doesn't have a global status line like tmux does, I was not able to port
over my fancy status line.

(Emacs does have a way to display the current time in the status line, but this is duplicated for each window,
and frequently obscured if you use a lot of splits.)

Now I went a-googling for a solution early on and all I could find was a thing called
[minibuffer-tray](http://www.emacswiki.org/emacs/MiniBufferTray).
(The minibuffer is the command area at the bottom of the Emacs UI.) This project was implemented in Python
with Qt, had a number of tricky-to-install dependencies, and ultimately didn't work very well once I got
it running. Like my own project, it appears to be a tool one guy wrote to get his own setup just so. I
determined that it would not work for me, but it did give me the idea of creating an overlay window.

I wasn't interested in having actual Emacs state pushed to my status line, so I didn't need any fancy IPC
stuff. Just a little floating window that would display the little pieces of data that I liked to have
available at a glance. I opted to implement this in Swift, just because.

Here is a screenshot:

<img src="https://raw.githubusercontent.com/austintaylor/minitray/master/screenshot.png"/>

It will be shown whenever Emacs is the frontmost application, and hidden otherwise. It prompts for access
to your location so that it can get local weather from darksky. The battery part won't work on non-laptops,
although I haven't even tested this to know if it fails gracefully.
