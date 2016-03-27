#
# http://eli.thegreenplace.net/2013/12/18/makefile-functions-and-color-output
define colorecho
      @/bin/echo -ne "\e[1;32m[$@]\e[1;34m $1\e[m\n"
endef
