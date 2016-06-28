# SuperCollider for Atom

A SuperCollider development environment for Atom.io

    apm install supercollider

---

SuperCollider is a programming language for real time audio synthesis and algorithmic composition.

https://supercollider.github.io

---

1. SuperCollider comes with a cross platform **IDE** (OS X/Linux/Windows) which communicates with the language interpreter.

2. The language interpreter runs in a separate process (**sclang**) and includes comprehensive bindings for making Qt based GUIs. sclang compiles and executes SuperCollider code, manages event schedulers (for making music) and creates GUIs. It can also send and receive OSC (Open Sound Control) and MIDI.

3. The SuperCollider synthesis server (**scsynth**) runs in a separate process or even on a separate machine so it is ideal for realtime networked music. It just makes music, its quite efficient and the audio quality is very high. Communication between sclang and scsynth is via OSC (Open Sound Control).

SuperCollider Atom is an alternative to the IDE. Atom is free, open source and very hackable.


## Features

### Quarks and classlib automatically added to your project

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/project-folders.png" style="max-width: 500px; margin:auto; display: block;" />

If you add Quarks (class library extensions) they are added to your project when you recompile.
You can turn this feature off in settings if you want.

### Lookup classes and methods using shift-cmd-R

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/lookup-classes-methods.png" style="max-width: 500px; margin:auto; display: block;" />

Use atom-ctags and

### Clear readable call stacks for errors

Clicking on one of the debug frames will open the source code in the left pane.
You can click on any classname to open it's source code.

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/callstack.png" />

#### Click to see contents of objects in Args or Vars

The formatting strives to have a high data-ink ratio by removing extraneous and useless information from the callstack.

The call stack in atom-supercollider includes *more* information than the standard supercollider call stack does. Each variable and function is included and even the contents of each member variable of each object shown. Click the triangles to open deeper detail when you need it.

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/sc-atom-fold-out.gif" />

### Syntax errors in your code are highlighted

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/scatom-syntax-error.png" />


### System/Growl notifications on error

<img src="https://raw.githubusercontent.com/crucialfelix/atom-supercollider/master/docs/images/growl-notification.png" style="width: auto; max-width: 400px;" />

Very useful if you are busy making music in another window or another application and want to know why the music just stopped.

Uses system notification on OS X 10.8+  Earlier OS X versions, Linux and Windows can install Growl:

https://github.com/visionmedia/node-growl

---


### Installation

##### 1. Install this package:

using Atom's 'Install Packages', search for "supercollider"

##### 2. Download and install SuperCollider:

https://supercollider.github.io

##### 3. It should work

If you've installed SuperCollider in a non-standard place or have a development build, then you can set that path in the settings. (Settings View: Open)

See also "Preferences" below.

##### 4. Open an .scd file in an Atom project, and then open a post window (shift-cmd-k)


---

### Commands

Open commands in Atom with `command-shift-P` and type `superc` to filter by supercollider commands.

- 'supercollider:recompile'
- 'supercollider:open-post-window'
- 'supercollider:clear-post-window'
- 'supercollider:cmd-period'
- 'supercollider:eval'
- 'supercollider:open-help-file'
- 'supercollider:manage-quarks'

Some commands are also available if you right-click on a word and check the context menu.

### REPL

| key              | command                                         |
| ---------------- | ----------------------------------------------- |
| `shift-cmd-K`    | Compile library (open window if needed)         |
| `shift-enter`    | Evaluate selection or current line              |
| `shift-cmd-C`    | Clear post window                               |
| `cmd-.`          | Panic ! Stop all music                          |


You may customize these in your own Keymap file.


### Lookup classes and methods with `shift-cmd-r`

Lookup is done using Atom's Symbol View which is powered by the venerable ctags.
Its quite fast and uses fuzzy finder.

When you recompile supercollider all compile paths including the SCClassLibrary and all of your quarks are added to your current atom project as folders. atom-ctags will then run ctags on all of the .sc sourcecode files so that lookup and auto-complete work.

I also recommend the [https://atom.io/packages/atom-ctags](atom-ctags) package with autocomplete-plus.

Install ctags if you need to:

os x

    brew install ctags

ubuntu

    sudo apt-get install exuberant-ctags

windows

    http://ctags.sourceforge.net/


Add support for the supercollider language by making a file called ~/.ctags

    --langdef=supercollider
    --langmap=supercollider:.sc
    --regex-supercollider=/^([A-Z]{1}[a-zA-Z0-9_]*)[ \[]{1}/\1/c,class/
    --regex-supercollider=/^[[:space:]]*(\*[a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/
    --regex-supercollider=/^[[:space:]]*([a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/

- Select a classname, `alt-cmd-down_arrow` to go to the definition
  You can also right-click and "Go to definition"

### GUI

SuperCollider has a comprehensive Qt based gui toolkit.  GUIs in SuperCollider Atom work just as they do with the SCIDE: they run in the separate language process.

    Server.default.makeWindow

### Help files:

Select a class name and `cmd-shift-p` and type "help file"

Or use the context menu (right-click) on the class name or method name to lookup.

The help browser will open in a new window.

(TODO: open help files directly in Atom)

## Preferences

See the settings in Atom settings > Packages > Supercollider

You can set the path to sclang (the supercollider language interpreter) if it is in a non-standard place or if you want to use a custom build.

You can also set the path to your `sclang_config.yaml` file which stores the compile paths including which Quarks you have installed.

If you have a `.supercollider.yaml` in your current atom project root or in your home directory (`~/.supercollider.yaml`) that will override the Atom settings. This allows you to have different settings for each project you work on. These files are how you configure supercollider.js projects which can be run outside of atom-supercollider.

See the [supercollider.js configuration documentation](http://supercolliderjs.readthedocs.org/en/latest/configuration.html)

##### Default paths:

**OS X**

`"/Applications/SuperCollider/SuperCollider.app/Contents/Resources/sclang"`

**Linux**

`"/usr/local/bin/sclang"`

**Windows**

`"C:\Program Files\SuperCollider\sclang.exe"`


## Missing Features

#### Built in server window

    s = Server.default;

    // but its easy to make a server window
    s.makeWindow


#### Native Auto-complete

There are many Atom packages for auto-complete. However they use text matching and not direct introspection. It would be possible to dump the class/method interface to a JSON file and then load that into auto-complete-plus. This would provide pretty good auto-complete with argument names and everything.


## Support

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/crucialfelix/atom-supercollider?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Issues and pull requests welcome.
