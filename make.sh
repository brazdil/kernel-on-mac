#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAKE_BIN_DIR=$SCRIPT_DIR/bin
MAKE_INCLUDE_DIR=$SCRIPT_DIR/include

# Load config file

source $SCRIPT_DIR/config.inc

# Prepare headers for native tools

if [ ! -d "$MAKE_INCLUDE_DIR" ]
then
  mkdir -p "$MAKE_INCLUDE_DIR"

  # Create symlinks to Linux-specific headers
  for hfolder in asm asm-generic bits gnu linux
  do
    mkdir -p "$MAKE_INCLUDE_DIR/$hfolder"
  done
  for hfile in byteswap.h \
               elf.h \
               features.h \
               asm/bitsperlong.h \
               asm/types.h \
               asm-generic/bitsperlong.h \
               asm-generic/int-ll64.h \
               asm-generic/types.h \
               bits/byteswap.h \
               bits/wordsize.h \
               gnu/stubs.h \
               gnu/stubs-32.h \
               gnu/stubs-64.h \
               linux/elf.h \
               linux/elf-em.h
  do
    ln -s "$COMPILER_INCLUDE_DIR/$hfile" "$MAKE_INCLUDE_DIR/$hfile"
  done

  # Create endian.h which includes the native header
  echo '#include <machine/endian.h>' > "$MAKE_INCLUDE_DIR/endian.h"
fi

# Create GNU tools symlinks

rm -rf "$MAKE_BIN_DIR" && mkdir -p "$MAKE_BIN_DIR"

ln -s "$TOOL_AWK" "$MAKE_BIN_DIR/awk"
ln -s "$TOOL_CHOWN" "$MAKE_BIN_DIR/chown"
ln -s "$TOOL_DATE" "$MAKE_BIN_DIR/date"
ln -s "$TOOL_FIND" "$MAKE_BIN_DIR/find"
ln -s "$TOOL_SED" "$MAKE_BIN_DIR/sed"
ln -s "$TOOL_XARGS" "$MAKE_BIN_DIR/xargs"

# Invoke GNU Make

export PATH="$MAKE_BIN_DIR":"$PATH"
make ARCH=$MAKE_ARCH \
     CROSS_COMPILE=$GCC_LINUX_BIN_DIR/$GCC_LINUX_PREFIX \
     HOSTCC="$MAKE_HOST_GCC -I$MAKE_INCLUDE_DIR" \
     SHELL="`which bash`" \
     $@
