#!/usr/bin/perl
use strict;
use warnings;

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

my @bin_files = ("iptablesbuild", "iptablestest");


## Grabs the configure options
my $opt_help = undef;
my $opt_conf = undef;
my $opt_bin = undef;
my $opt_perl = undef;
my $opt_root = undef;
my $opt_docs = undef;
my $opt_man = undef;
my $opt_force = undef;

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
my $version = "2.3.0";
my $conf = "/etc";
my $bin = "/usr/sbin";
my $perl = "/usr/bin/perl";
my $root = "/";
my $docs = "/usr/share/doc";
my $man = "/usr/share/man";
if (defined $opt_conf) {
	$conf = $opt_conf;
}

if (defined $opt_bin) {
	$bin = $opt_bin;
}
if (defined $opt_perl) {
	$perl = $opt_perl;
}
if (defined $opt_root) {
	$root = $opt_root;
}
if (defined $opt_docs) {
	$docs = $opt_docs;
}
if (defined $opt_man) {
	$man = $opt_man;
}

if (!(defined $opt_force)) {
	print "Perl is Sane? ";
	my $sanity = `$perl -v`;
	my $cont;
	while (!( $sanity =~/This is perl,/i) && $cont ne "y") {
		print "$root/$perl does not appear to exist. Would you like to enter an alternate path? (y/n) [y] fancy!";
		chop(my $inp = <STDIN>);
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
# Package Configuration
#
# Sets the system specific variables in the script (ie conf file location)

print "Configuring Packages...\n";
`mkdir build 2>&1`;
foreach my $bin_file (@bin_files) {
	my @file=undef;
	open(my $fileHandle, "bin/$bin_file") or die "Unable to open bin/$bin_file";
	@file = <$fileHandle>;
	close($fileHandle);

	foreach my $line (@file) {
		$line=~s/\%conf%/$conf/g;
		$line=~s/\%perl%/$perl/g;
		$line=~s/\%version%/$version/g;
	};
	open(my $build, "> build/$bin_file");
	print $build @file;
	close($build);
	
	# diff check to make sure nothing drastic happened
	my $diff = `diff -e bin/$bin_file build/$bin_file | wc -l`;
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
foreach my $bin_file (@bin_files) {
	print `cp -f build/$bin_file $root/$bin/ 2>&1`;
	print `chmod 755 $root$bin/$bin_file 2>&1`;
	print `chown root:root $root$bin/$bin_file 2>&1`;
	print `pod2man --section 8 build/$bin_file $root$man/man8/$bin_file.8`;
	print `gzip $root$man/man8/$bin_file.8`;
}
print `mkdir -p $root/$docs/iptablesbuild/sample/etc/iptablesbuild/Templates 2>&1`;
print `cp -f docs/sample/Templates/* $root/$docs/iptablesbuild/sample/etc/iptablesbuild/Templates/ 2>&1`;
print `cp -f docs/sample/iptablesbuild.conf $root/$docs/iptablesbuild/sample/etc/iptablesbuild/ 2>&1`;
print `chown -R root:root $root/$docs/iptablesbuild/sample/etc/iptablesbuild 2>&1`;



print `pod2man --section 5 docs/iptablesbuild.conf.pod $root$man/man5/iptablesbuild.conf.5`;
print `cd $root$bin; ln -s iptablesbuild iptbld`;


########
# Post Installation
#
# Runs some basic checks to ensure that the packages are in fact Installed Porporly.

print "Running Post Install Checks...\n";

foreach my $bin_file (@bin_files) {
	chop(my $old_md5= `md5sum build/$bin_file | awk '{print \$1}'`);
	chop(my $new_md5 = `md5sum $root$bin/$bin_file | awk '{print \$1}'`);
	if ($old_md5 ne $new_md5 || !(-e "$root$bin/$bin_file")) {
		`rm $root$bin/$bin_file`;
		die "Error iptablesbuild does not appear to have installed proporly. Removing $root$bin/$bin_file.\n";
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

