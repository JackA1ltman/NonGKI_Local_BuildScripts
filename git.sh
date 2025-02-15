#!/bin/sh
GIT_BRANCH="4.19.325"
GIT_TURBO="https://gh-proxy.com"
GIT_PROJECT="AK-Papon/oneplus_sm8250"
GIT_FOLDER="tpkernel_oos13_a13_op8"
git clone --recursive -b $GIT_BRANCH "$GIT_TURBO"/github.com/"$GIT_PROJECT".git $GIT_FOLDER --depth=1
