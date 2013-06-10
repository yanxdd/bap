#!/bin/sh

# "prefix" path for installing "piqi" and "piqic" executables
PREFIX=/usr/local

# path for installing Piqi OCaml libraries. If not set, the ocamlfind
# destination directory path will be used. Such path is determined by
# OCAMLFIND_DESTDIR environment variable or by ocamlfind config. You can run
# "ocamlfind printconf destdir" to see the current setting.
OCAML_LIBDIR=


usage() {
echo "
Configuration:
  -h, --help              display this help and exit

Installation directories:
  --prefix PREFIX         install piqi executables in PREFIX/bin/
                          [/usr/local]
  --ocaml-libdir DIR      install OCaml libraries to DIR
                          [\`ocamlfind printconf destdir\`]
"
}


while [ "$#" != "0" ]
do
    opt="$1"
    case "$opt" in
        --*=*)
            opt_value=`expr "X$opt" : '[^=]*=\(.*\)'`
            ;;
        --*)
            shift
            opt_value="$1"
            ;;
    esac

    case "$opt" in
        --prefix | --prefix=*)
            PREFIX="$opt_value"
            ;;
        --ocaml-libdir | --ocaml-libdir=*)
            OCAML_LIBDIR="$opt_value"
            ;;
        -h|-help|--help)
            usage
            exit 0
            ;;
        *)
            echo "configure: run 'configure -h' to get help" 1>&2
            exit 1
            ;;
    esac

    shift
done


OCAMLFIND="`which ocamlfind`"
if [ $? -ne 0 ]
then
    echo "configure: error: ocamlfind is required. See INSTALL for details" 1>&2
    exit 1
fi


M=Makefile.config

# configure options
echo "# Makefile.config generated by ./configure" > $M
echo >> $M
echo "PIQI_PREFIX=$PREFIX" >> $M
echo "PIQI_OCAML_DESTDIR=$OCAML_LIBDIR" >> $M
echo >> $M

# build environment
echo "export PIQI_ROOT = `pwd`" >> $M
# temporary build directory
echo "export PIQI_BUILD = \$(PIQI_ROOT)/build" >> $M
# path to .piqi files
echo "export PIQI_PATH = \$(PIQI_ROOT)" >> $M
echo >> $M

# figure out which dependencies we need to build
echo "checking whether necessary dependencies are already installed..."
for i in xmlm ulex easy-format
do
    dir="`ocamlfind query $i 2>/dev/null`"
    if [ $? -eq 0 ]
    then
        echo "$i is installed in $dir"
        echo "SKIP-$i = 1" >> $M
    else
        echo "$i is not installed; it will be built during \"make deps\""
    fi
done


# ex: sw=4 ts=4 et