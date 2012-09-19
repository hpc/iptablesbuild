Copyright (c) 2011-2012 Los Alamos National Security, LLC. All rights reserved.

This program was prepared by Los Alamos National Security, LLC at Los Alamos 
National Laboratory (LANL) under contract No. DE-AC52-06NA25396 with the U.S. 
Department of Energy (DOE). All rights in the program are reserved by the DOE and 
Los Alamos National Security, LLC.  Permission is granted to the public to copy and
use this software without charge, provided that this Notice and any statement of 
authorship are reproduced on all copies.  Neither the U.S. Government nor LANS 
makes any warranty, express or implied, or assumes any liability or responsibility 
for the use of this software.

# iptablesbuild #

## About ##
iptablesbuild is a configuration management engine for iptables. The goal is to have one configuration file to manage an entire network of systems.

In large networks, individual host firewall configurations tend to share a large number of similarities with eachother. This can be access to email servers, file servers, etc. The general idea with iptablesbuild is to create a generic global configuration that all systems use, and have custom deviations for each individual configuration. This can turn a very complicted long configuration into a very simple one.

What does this accomplish?:
 1. Standardization for how the iptables configurations are organized and what rules are in place. This allows for better readability, and ensures that certain protections are always in place.
 2. Reduced duplication of unneeded rules. Often in large installations iptables configurations are copied from one system to annother without looking through to see what is needed and what isn't. iptablesbuild won't eliminate this, but it will reduce the amount of imformation a sysadmin needs to look through.
 3. Reduces user error. When the same base configuration is used on multiple systems with the same ordering scheme, it is less likely for a problem to occur where a rule in in the wrong place causing the rule to not have any effect or loss of access.

# Support #

LANL nor any of the supporters of this project assume any responsibility for any problems caused in relation to this tool. However, for any help please contact grahamvh@lanl.gov.

