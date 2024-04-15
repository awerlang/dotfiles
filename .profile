# This file is read each time a login shell is started.
# All other interactive shells will only read .bashrc; this is particularly
# important for language settings, see below.

test -z "$PROFILEREAD" && . /etc/profile || true

# Most applications support several languages for their output.
# To make use of this feature, simply uncomment one of the lines below or
# add your own one (see /usr/share/locale/locale.alias for more codes)
# This overwrites the system default set in /etc/sysconfig/language
# in the variable RC_LANG.
#
#export LANG=de_DE.UTF-8	# uncomment this line for German output
#export LANG=fr_FR.UTF-8	# uncomment this line for French output
#export LANG=es_ES.UTF-8	# uncomment this line for Spanish output

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# Some people don't like fortune. If you uncomment the following lines,
# you will have a fortune each time you log in ;-)

#if [ -x /usr/bin/fortune ] ; then
#    echo
#    /usr/bin/fortune
#    echo
#fi

NEW_PATHS="$HOME/src/containers/bin"
if [[ ! :$PATH: == *:"$NEW_PATHS":* ]] ; then
    export PATH="$NEW_PATHS:$PATH"
fi
unset NEW_PATHS

for WORKSPACE_PATH in $HOME/src/*/workspace/bin; do
    if [[ ! :$PATH: == *:"$WORKSPACE_PATH":* ]] ; then
        export PATH="$PATH:$WORKSPACE_PATH"
    fi
done
unset WORKSPACE_PATH

export NO_AT_BRIDGE=1
export MESA_DEBUG=silent
export QT_LOGGING_RULES='*=false'
export PYTHONPATH="$(python3 -m site --user-site)"
export VISUAL='micro'
