#!/bin/sh

# Copyright (c) 2020, Fabio Muratore, Honda Research Institute Europe GmbH and
# Technical University of Darmstadt. All rights reserved.
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement: This product includes
#    software developed by the Honda Research Institute Europe GmbH.
# 4. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Assumptions:
# Equal user names and paths on both machines
# Assuming you are in PROJECT_DIR/remotelaunch and want to run SCRIPT_NAME.py
# Anaconda is installed at $HOME/Software/anaconda3/bin/conda

# Usage:
# bash remotelaunch_TEMPLATE.sh python PROJECT_DIR/Pyrado/scripts/training/SCRIPT_NAME.py

CMD="$@"

DSTHOST="..." # ADD NAME OF THE COMPUTER
PROOT="..." # ADD PATH TO PROJECT ROOT DIR, I.E. PATH TO SimuRLacra

RLAUNCH_DIR="$PROOT/remotelaunch"

RCS_SRC_DIR="$PROOT/Rcs" # path to Rcs source dir
RCS_BUILD_DIR="$PROOT/Rcs/build" # path to Rcs build dir

RCSPYSIM_SRC_DIR="$PROOT/RcsPySim"
RCSPYSIM_BUILD_DIR="$RCSPYSIM_SRC_DIR/build"

CONDA_ENV_NAME="pyrado"
# may need before activating
# eval "$($HOME/Software/anaconda3/bin/conda shell.bash hook)"

# Synchronize code
$RLAUNCH_DIR/sync_to_host.sh $DSTHOST "$PROOT"

# Now, run all this on the remote host
ssh -t -t $DSTHOST << EOF
shopt -s expand_aliases

mkdir -p "$RCS_BUILD_DIR"
cd "$RCS_BUILD_DIR"
cmake "$RCS_SRC_DIR"
make -j8

conda activate "$CONDA_ENV_NAME"

cd "$PROOT"
mkdir -p "$RCSPYSIM_BUILD_DIR"
cd "$RCSPYSIM_BUILD_DIR"
cmake "$RCSPYSIM_SRC_DIR/build"
make -j8

$CMD

exit
EOF
