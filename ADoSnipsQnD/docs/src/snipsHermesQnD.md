# The SnipsHermesQnD framework

## Julia

This template skill is (like the entire SnipsHermesQnD framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here:
[https://julialang.org/](https://julialang.org/)

### Installation of Julia language

Installation of Julia is simple:
* just download the tar-ball for
  your architecture (most probably Raspberry-Pi/arm).
* save it in an appropriate folder (`/opt/Julia/` might be a good idea).
* unpack: `tar -xvzf julia-<version>.tar.gz`
* make sure, that the julia executable is executable. You find it
  as `/opt/Julia/julia-<version>/bin/julia`.
  If it is not executable run `chmod 755 /opt/Julia/julia-<version>/bin/julia`
* Add a symbolic link from a location which is in the search path, such as
  `/usr/local/bin`:

All together:

```sh
sudo chown $(whoami) /opt    
mkdir /opt/Julia    
mv ~/Downloads/julia-<version>.tar.gz .    
tar -xvzf julia-<version>.tar.gz    
chmod 755 /opt/Julia/julia-<version>/bin/julia    
cd /usr/local/bin    
sudo ln -s /opt/Julia/julia-<version>/bin/julia    
```

  **... and you are done!**

  For a very quick *get into,* see
  [learn Julia in Y minutes](http://learnxinyminutes.com/docs/julia/).

### IDEs

Softwarte development is made comfortable by
IDEs (Integrated Development Environements). For Julia, best choices
include:

* [Atom editor](http://atom.io/) with the
  [Juno package](http://junolab.org) installed (my favourite).
* [Visual Studio Code](https://code.visualstudio.com) also
  provides very good support for Julia.
* Playing around and learning is best done with
  [Jupyter notebooks](http://jupyter.org). The Jupyter stack can be installed
  easily from the Julia REPL by adding the Package `IJulia`.

### Noteworthy differences between Julia and Python

Julia code looks very much like Python code, except of
* there are no colons,
* whitespaces have no meaning; blocks end with an `end`,
* sometimes types should be given explicitly (for performance and
  explicit polymorphism).

However, Julia is a typed language with all advantages; and code is
run-time-compiled only once, with consequences:
* If a function is called for the first time, there is a time lack, because
  the compiler must finish his work before the actual code is executed.
* Future function calls will use the compiled machine code, making Julia
  code execute as fast as compiled c-code!

## Installation

### Installation of the framework

The framework is installed, by adding the app `ADoSnipsHermesQnD` to a
Snips assistant. This will install the library and general `SwitchOnOff` intent.

It is a good idea to install the template skill in addition. The skill is
fully functional and can be used to explore the framework.

MQTT communication is performed via `Eclipse modquitto`,
therefore this must be installed, too. On a Raspberry Pi the packages
`mosquitto` and `mosquitto-clients` are needed:

```sh
sudo apt-get install mosquitto
sudo apt-get install mosquitto-clients
```

### App ADoSnipsHermesQnD

To use skills, developed with SnipsHermesQnD, just add the ADoSnipsHermesQnD
App to your assistant. There are versions in German and English language
(`ADoSnipsHermesQnD_DE` and `ADoSnipsHermesQnD_EN`).

### Adapt timeouts

One major difference between the languages Python and Julia is that
Julia is compiled only once at runtime with a compiler that produces
highly optimised code.

As a result, Julia code runs as fast as other compiled code, such as c code.
The downside is the time necessary for compilation. Whereas Python scripts
just run away when started (because the compile cost is averaged over the
entire runtime), Julia functions need an extra time for compilation, when they
are started for the first time.

In consequence there is a time lack at the start of a Julia program; and
for the same reason additional time is necessary when a function
is executed for the first time.

Some things need to be considered to handle this in the Snips environement:
- When the Snips skill manager starts an assistant, the Julia apps
  will need up to 1 minute on a Rsapberry Pi until they are ready.
  When watching the processes with `top` or `htop`, the Julia-processes
  are visible at the top with 100% CPU load. This is the compiler!
- The settings for `session_timeout` and `lambda_timeout` in the Snips
  configuration file `snips.toml` should be set to a high value
  (such as 1 minute) in order to keep a session alive until the app reacts
  the first time. This is only
  an issue when a function behind an intent is executed for the first time,
  any subsequent call will be very fast.


## Template skill

The template `ADosnipsTemplate` is already a fully functional skill. To test it,
just add the ADoSnipsTemplate-skill to your assistant in the Snips console and
update your assistant with sam (`sam update-assistant`).
The skill is available in English and German and shows how the
multi-language support of the framework works.

During installation with `sam` you will be asked to confirm the settings in
`config.ini`.
- Please set the language to the laguage you need (currently
  `en` and `de` are supported)
- Please give your assistant a name. The Skill will repeat the name, when
  activated in order to show the code necessary to access `config.ini`
  values.

The Template Skill includes the intent `pleaseRepeat` (as `pleaseRepeatDE` and
`pleaseRepeatEN`) which allows to say things like:
```Julia
"please repeat the word holydays"
"please say: movie"
...
```

or in German:
```Julia
"Bitte sprich mit nach: Auto"
"Bitte sage: Kaffeemaschine"
...
```

The app will repeat the word.
