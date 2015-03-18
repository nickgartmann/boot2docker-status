#Boot2Docker Status

An OSX menu bar application for monitoring the state of your [boot2docker](http://boot2docker.io) 
virtual machine so you don't waste sweet, sweet memory on a VM you aren't using.

![](http://i.imgur.com/XTUnd4y.gif?1)

Just click the whale, and you're off to the races.

## Installation

[Download the app](http://boot2docker-status.nickgartmann.com/Boot2Docker%20Status-v1.0.0.zip), unzip it,
and move it to your `/Applications` directory. Then just launch the app. Use `cmd+click` on the menu bar icon 
to change preferences or quit.

## What it does

Boot2Docker Status constantly monitors (every 2 seconds) the state of `boot2docker status` to see if the VM is running and gives a visual representation of the state of the VM. Then by clicking the icon you can toggle the state of the VM.

To toggle the state, the app will emit `boot2docker up` or `boot2docker down` accordingly. **NOTE: It does not set your environment variables in your term, so you will still need to run `$(boot2docker shellinit)`**
