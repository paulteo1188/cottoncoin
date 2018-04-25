
Debian
====================
This directory contains files used to package cottoncoind/cottoncoin-qt
for Debian-based Linux systems. If you compile cottoncoind/cottoncoin-qt yourself, there are some useful files here.

## cottoncoin: URI support ##


cottoncoin-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install cottoncoin-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your cottoncoinqt binary to `/usr/bin`
and the `../../share/pixmaps/cottoncoin128.png` to `/usr/share/pixmaps`

cottoncoin-qt.protocol (KDE)

