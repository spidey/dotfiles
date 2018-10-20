#!/bin/sh

mkdir -p ~/.config/git
mkdir -p ~/.config/glogg

ln -sfr ./vimrc ~/.vimrc
ln -sfr ./gitignore ~/.config/git/ignore
ln -sfr ./glogg.conf ~/.config/glogg/glogg.conf
