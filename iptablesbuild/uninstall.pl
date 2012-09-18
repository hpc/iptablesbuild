#!/usr/bin/perl
#############
# install.sh
# Installs iptablesbuild
# Created By Graham Van Heule (grahamvh@lanl.gov)

use Getopt::Long;

@bin_files = ("iptablesbuild", "iptablestest");


## Grabs the configure options
local $opt_help = undef;
local $opt_conf = undef;
local $opt_bin = undef;
local $opt_perl = undef;

GetOptions(
	'h|help'	=> \$opt_help,
	'conf=s'	=> \$opt_conf,
	'bin=s'		=> \$opt_bin,
	'root=s'	=> \$opt_root,
);


# Help
if (defined $opt_help) {
	print "install.sh - Installs iptablesbuild on the given system\n";
	print "Options:\n";
	print "--conf - Defines the Configuration directory (Default is /etc\n";
	print "--bin - Defines the place to put the Binaries (Default is /usr/sbin)\n";
	print "--root - Defines a chroot directory to install into (Default is /)\n";
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
if (defined $opt_root) {
	$root = $opt_root;
}
else {
	$root = "/";
}




#######
#Removal Script
#
# deletes the binaries


for ($x=0; $x <= $#bin_files; $x++) {
	print `rm $root/$bin/$bin_files[$x] 2>&1`;
}

########
# Post Installation
#
# Runs some basic checks to ensure that the packages are in fact Installed Porporly.

print "Running Post Removal Checks...\n";


for ($x=0; $x <= $#bin_files; $x++) {
	if (-e "$root$bin/$bin_files[$x]") {
		die "Error $root$bin/$bin_files[$x]` could not be removed..\n";
	}
}

print "Removal Completed Successfully! Configuation files have been left in place.\n";
exit 0;

