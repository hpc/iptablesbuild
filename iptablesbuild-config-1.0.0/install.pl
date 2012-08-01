#!/usr/bin/perl
# Copyright (c) 2011-2012 Los Alamos National Security, LLC. All rights reserved.

# This program was prepared by Los Alamos National Security, LLC at Los Alamos 
# National Laboratory (LANL) under contract No. DE-AC52-06NA25396 with the U.S. 
# Department of Energy (DOE). All rights in the program are reserved by the DOE and 
# Los Alamos National Security, LLC.  Permission is granted to the public to copy and
# use this software without charge, provided that this Notice and any statement of 
# authorship are reproduced on all copies.  Neither the U.S. Government nor LANS 
# makes any warranty, express or implied, or assumes any liability or responsibility 
# for the use of this software.
#
# @author Graham Van Heule
#
#############
# install.sh
# Installs iptablesbuild's configuration files

use Getopt::Long;

@bin_files = ();
@bin_md5s=();


## Grabs the configure options
local $opt_help = undef;
local $opt_conf = undef;
local $opt_bin = undef;
local $opt_perl = undef;

GetOptions(
	'h|help'	=> \$opt_help,
	'conf=s'	=> \$opt_conf,
	'bin=s'		=> \$opt_bin,
	'perl=s'	=> \$opt_perl,
	'root=s'	=> \$opt_root,
	'docs=s'	=> \$opt_docs,
	'man=s'		=> \$opt_man,
	'force|f'	=> \$opt_force
);


# Help
if (defined $opt_help) {
	print "install.sh - Installs iptablesbuild on the given system\n";
	print "Options:\n";
	print "--conf - Defines the Configuration directory (Default is /etc)\n";
	print "--bin - Defines the location of the iptbalesbuild binary directory (Default is /usr/sbin)\n";
	exit 0;
}


# Sets Default values to the variables or uses what the user has given.

if (defined $opt_conf) {
	$conf = $opt_conf;
}
else {
	$conf = "/etc";
}

if (defined $opt_bin) {
	$bin = $opt_bin;
}
else {
	$bin = "/usr/sbin";
}
if (defined $opt_perl) {
	$perl = $opt_perl;
}
else {
	$perl = "/usr/bin/perl";
}
if (defined $opt_root) {
	$root = $opt_root;
}
else {
	$root = "/";
}
if (defined $opt_docs) {
	$docs = $opt_docs;
}
else {
	$docs = "/usr/share/doc";
}
if (defined $opt_man) {
	$man = $opt_man;
}
else {
	$man = "/usr/share/man";
}

if (!(defined $opt_force)) {
	print "iptablesbuild is Sane? ";
	$sanity = `$root/$bin/iptablesbuild -v`;
	
	while (!( $sanity =~/iptablesbuild Version/i) && $cont ne "y") {
		print "$root/$bin/iptablesbuild does not appear to exist. Would you like to enter an alternate path? (y/n) [y] ";
		chop($inp = <STDIN>);
		if ($inp ne "n") {
			print "Enter a path to the bin directory containing iptablesbuild:";
			chop($perl = <STDIN>);
		}
		else {
			print "Would you like to continue anyway? (y/n) [n]: ";
			chop($cont = <STDIN>);
			if ($cont ne "y") {
				exit 0;
			}
		}
	}
	if ($sanity =~/iptablesbuild version/i) {
		print "iptablesbuild is sane\n";
	}
}

#######
#Installation Script
#
# Copies the scripts to their designated locations


print `mkdir -p $root/$conf/iptablesbuild/Templates 2>&1`;
print `cp -ir etc/* $root/$conf/ 2>&1`;
print `chown -R root:root $root/$conf/iptablesbuild 2>&1`;


print "Installation Completed Successfully!\n";
exit 0;

