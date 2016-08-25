live-cd2
========

[![CircleCI](https://circleci.com/gh/tork-a/live-cd2.svg?style=svg)](https://circleci.com/gh/tork-a/live-cd2)

This is 2nd generaiton of live-cd

Contents
--------

  README.md  This file
  Makefile   Commands to create live-cd
  indigo/
      Dockerfile : Docker images to be installed in live-cd
  vagrant/
      Vargantfile: Commands to setup vargant
  builder/
      Makefile   : Commands to build iso from Docker using vagrant



References:
- http://github.com/mbentley/overclockix
- http://github.com/znz/rubylive
- http://blog.n-z.jp/blog/2015-10-26-rubylive-builder.html
- http://docs.kali.org/development/live-build-a-custom-kali-iso
- http://github.com/debian-live/live-build
- http://yakushi.shinshu-u.ac.jp/robotics/?DebianLive%2FBuild-HOWTO
