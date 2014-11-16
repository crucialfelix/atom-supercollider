

# CONTRIBUTING

First submit an issue with any idea so I can help you to find the best way to make it happen.

clone https://github.com/crucialfelix/supercolliderjs

learn about https://www.npmjs.org/doc/cli/npm-link.html

and link supercollider.js

this will link the cloned copy of supercolliderjs so that your atom-supercollider uses that instead of checking out its own copy

then the atom-supercollider source that I work with is directly inside ~/.atom/packages/atom-supercollider

but its probably better to do this:

https://atom.io/docs/v0.144.0/contributing-to-packages

because you will want to have your own github fork and link that copy into atom.

then make a test project just for doing development and open that in development mode.

use https://atom.io/packages/project-manager and set that test project to always open in development mode.

do "Window: reload" to get any changes and restart.

There are unit tests in spec/ but only for easily testable things like the rendering/formatting code.

Submit a pull request !
