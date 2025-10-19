#!/usr/bin/perl
#
##!/usr/bin/perl

#
#
# This software was developed and is maitained by :
#
#       J.P. Langan
#       13186 15th Street South
#       Afton, MN 55001
#
#       Support inquiries to softw-dev@dyn-eng.com
#
#
# please remit all bug reports to support email address
#
# Bugs will be fixed, enhancements considered
#



use strict;
use warnings;



	my @dStack;
#
# a few global variables 
#
	my $hFile	= 0;
	my $cFile	= 0;
	my $pFile	= 0;
	my $sStrng	= "";
	my $iCase	= "n";
	my $num_args	= @ARGV;
	my $idx;
	my $fileCnt = 0;
	my $stackSz = 0;	


sub getDirectory {

	my $dPath	= $_[0]; 
	my $str 	= $_[1];
	my $fSuffix	= $_[2];
	my $indx;	

	#print "Testing Directory... $dPath\n";	

# Open the directory
	opendir(my $dh, $dPath) or die "Cannot open directory '$dPath': $!";

# Read the contents of the directory
	my @files = readdir($dh);
	for($indx = 0; $indx < @files; $indx++) {
		$_ = $files[$indx];
		if(! (length($files[$indx]) <= 2 && (/\./ || /\.\./)) && ! -l $dPath.$files[$indx]) {
						
				if(-f $dPath.$files[$indx]){
					#print " ...common file\n";
					# test for content and file type print results if a match
					testFile($dPath . $files[$indx]);
					
				}
				if(-d $dPath.$files[$indx]) {
					$_ = $dPath . $files[$indx]. "/"; 
					push @dStack, $_; #print " ...directory\n";
				}
		}	
	}

# Close the directory handle
	closedir($dh);
}



#
# 
# 

sub testFile {

	my $fName	= $_[0];
#	my $sStrng	= [1];
	my $found	= 0;
	my $line;
	my $lineNo	= 0;
	my $suffix	= "";
	my $proc 	= 0;
	
	$fileCnt++;
#
#
# test out filename for the propertires before we attempt open, let's not waste computer processing
#
	$_ = $fName;
	
	if(m/^(.*)\.(.*)$/) {$suffix = $2;}; 
	
	if($hFile && $suffix eq "h" ) {$proc = 1;}
	if($cFile && ($suffix eq "c" || $suffix eq "cpp") || $suffix eq "cc") {$proc = 1;}
	if($cFile && ($suffix eq "p" || $suffix eq "pl") || $suffix eq "pm") {$proc = 1;}
	
	if(! $proc) {return;}		# skip this file no match	

	open(my $fh, '<', $fName) or die "Cannot open file '$fName': $!";

	while (my $line = <$fh>) {
		$lineNo++;
    		if ($line =~ /\Q$sStrng\E/) { # \Q and \E quote the string for literal matching
        		if(! $found) {print "\r                                                                                \nMatch found! \n";}
			if(! $found) {print "     $fName\n";}
			print "        $lineNo... ";
			$line  =~ s/\n//; print " $line\n";
        		$found = 1;        		
        		
        		#last; # Exit loop once found
    		}
	}

	close($fh);
}

#
# searchFiles - search files and scan tranverse directories for files containing and input string
#
# 2025-10-16 - jpl Original Version
#
#		Only known deficiency is this version won't traverse logical links
#
#		Inputs	-d "directory name" base directory for beginning of search
#			-s "search string"  string to search in suspect files
#			-c search ".c" and ".cpp" files 
#			-h search ".h" include type files
#			-p search ".pl" and ".pm" files for perl support
#			-i ignore case
#			
#
# 2025-10-17 - jpl Added code to close the input directory with a "/" automatically
##
# 2025-10-17 - jpl Rearranged code to eliminate the possiblility of cyclic tranversing of symbolic links
#			Program now works on all directories. Was crashing... 
#
#	
#
# Parse out the input selections and parameters from the user
#
	my $fNameTest	= "";
	my $stackNo	= 0;
	my $rDir	= "";

	print "Number of input arguments $num_args\n\n";
	for($idx = 0; $idx < $num_args; $idx++) {
	
		$_ = lc($ARGV[$idx]);
		print "Argv : $_\n";
		if(/-h/) {$hFile = 1;}
		if(/-c/ || /-cpp/) {$cFile = 1;}
		if(/-p/) {$pFile = 1;}
		if(/^-s(.*)/) {$sStrng = $1;}
		if(/-i/) {$iCase = "y";}
		if(/-d(.*)/) {$rDir = $ARGV[$idx]; $rDir =~ s/^-d//;}
	
	}
	
	print "Search String :|$sStrng|\n";
	$_ = $rDir;
	if(! /\/$/) {$rDir .= "/";}
	
	push @dStack, $rDir;	
	
	while(1) {
		$fNameTest = pop @dStack; 
		getDirectory($fNameTest);			# pack the stack with first directory names
		$stackNo = @dStack;
		if($stackNo == 0) {print "\n\nProcessing complete!    number of files evaluated $fileCnt \n\n\n"; exit 0;}
	}
	
	print "\n\nProcessing complete!\n\n\n";
	
exit 0;
