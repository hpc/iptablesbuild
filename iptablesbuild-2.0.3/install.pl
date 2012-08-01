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
# Installs iptablesbuild

use Getopt::Long;

@bin_files = ("iptablesbuild", "iptablestest");
@bin_md5s=("d9357784b748f36f96d5ae7004c44295","bf61e0c2b9679ac287fd72397023bd8a");


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
	print "--bin - Defines the place to put the Binaries (Default is /usr/sbin)\n";
	print "--perl - Defines the location of the perl binary (Default is /usr/bin/perl)\n";
	print "--docs - Defines where to place the domumentation for iptablesbuild into (Default is /usr/share/doc)\n";
	print "--root - Defines a chroot directory to install into (Default is /)\n";
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
	print "Perl is Sane? ";
	$sanity = `$perl -v`;
	
	while (!( $sanity =~/This is perl,/i) && $cont ne "y") {
		print "$root/$perl does not appear to exist. Would you like to enter an alternate path? (y/n) [y] fancy!";
		chop($inp = <STDIN>);
		if ($inp ne "n") {
			print "Enter a path to perl:";
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
	if ($sanity =~/This is Perl,/i) {
		print "Perl is Sane.\n";
	}
}

######
# Consistancy Check
#
# Checks to ensure that packages in this source install are valid 
# (wouldn't want you installing gobly gook!)

print "Checking Consistancy of Packages..,\n";
$md5sum_exist = `md5sum -v 2>&1`;

if ($md5sum_exist=~/Command not found/ig) {
	print "Warning! md5sum could not be found in local PATH. Package Consistancy cannot be determined. Continue? (y/n) [y]\n";
	chop($inp = <STDIN>);
	if ($inp eq "n" || $inp eq "N") {
		exit 0;
	}
}
else {
	for ($x=0; $x <= $#bin_files; $x++) {
		chop($real_md5=`md5sum bin/$bin_files[$x] | awk '{print \$1}'`);
		if ($real_md5 ne $bin_md5s[$x]) {
			print "Warning: Packages do no appear to be consistant. Continue anyway? (y/n) [n]: ";
			chop ($inp = <STDIN>);
			if ( $inp ne "y" && $inp ne "Y") {
				exit 3;
			}
		}
	}
}

######
# Package Configuration
#
# Sets the system specific variables in the script (ie conf file location)

print "Configuring Packages...\n";
`mkdir build 2>&1`;
for ($x=0; $x <= $#bin_files; $x++) {
	@file=undef;
	open(file, "bin/$bin_files[$x]") or die "Unable to open bin/$bin_files[$x]";
	@file = <file>;
	close(file);

	for ($y=0; $y <= $#file; $y++) {
		$file[$y]=~s/\%conf%/$conf/g;
		$file[$y]=~s/\%perl%/$perl/g;
	};
	open(build, "> build/$bin_files[$x]");
	print build @file;
	close(build);
	
	# diff check to make sure nothing drastic happened
	$diff = `diff -e bin/$bin_files[$x] build/$bin_files[$x] | wc -l`;
	if ($diff >= 10 || $diff <= 2) {
		print "diff:$diff\n";
		print "Warning! Build file does not appear to have been constructed proporly. Please rerun this installer. Exiting...\n";
		exit 0;
	}
};




#######
#Installation Script
#
# Copies the scripts to their designated locations

print "Configuration Set. Running Install Scripts...\n";
for ($x=0; $x <= $#bin_files; $x++) {
	print `cp -f build/$bin_files[$x] $root/$bin/ 2>&1`;
	print `chmod 755 $root$bin/$bin_files[$x] 2>&1`;
	print `chown root:root $root$bin/$bin_files[$x] 2>&1`;
	print `pod2man build/$bin_files[$x] $root$man/man1/$bin_files[$x].1`;
}
print `mkdir -p $root/$docs/iptablesbuild/sample/etc/iptablesbuild/Templates 2>&1`;
print `cp -f docs/sample/Templates/* $root/$docs/iptablesbuild/sample/etc/iptablesbuild/Templates/ 2>&1`;
print `cp -f docs/sample/iptablesbuild.conf $root/$docs/iptablesbuild/sample/etc/iptablesbuild/ 2>&1`;
print `chown -R root:root $root/$docs/iptablesbuild/sample/etc/iptablesbuild 2>&1`;



print `pod2man docs/iptablesbuild.conf.pod $root$man/man1/iptablesbuild.conf.1`;


########
# Post Installation
#
# Runs some basic checks to ensure that the packages are in fact Installed Porporly.

print "Running Post Install Checks...\n";

for ($x=0; $x <= $#bin_files; $x++) {
	chop($old_md5= `md5sum build/$bin_files[$x] | awk '{print \$1}'`);
	chop($new_md5 = `md5sum $root$bin/$bin_files[$x] | awk '{print \$1}'`);
	if ($old_md5 != $new_md5 || !(-e "$root$bin/$bin_files[$x]")) {
		`rm $root$bin/$bin_files[$x]`;
		die "Error iptablesbuild does not appear to have installed proporly. Removing $root$bin/$bin_files[$x].\n";
	}
}

if (!(-e "$root$docs/iptablesbuild/sample/etc/iptablesbuild/iptablesbuild.conf")) {
	die "Error iptablesbuild does not appear to have installed proporly. $root/$docs/iptablesbuild/sample/etc/iptablesbuild/Templates does not exist\n";
}
if (!(-e "$root$docs/iptablesbuild/sample/etc/iptablesbuild/Templates")) {
	die "Error iptablesbuild does not appear to have installed proporly. $root/$docs/iptablesbuild/sample/iptablesbuild/Templates does not exist\n";
}

print "Installation Completed Successfully!\n";
exit 0;

