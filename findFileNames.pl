#!/usr/bin/perl
#
##!/usr/bin/perl
use strict;
use warnings;



	my @dStack;
#
# a few global variables 
#
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
		$fileCnt++;
		if(! (length($files[$indx]) <= 2 && (/\./ || /\.\./)) && ! -l $dPath.$files[$indx]) {
						
				if(-f $dPath.$files[$indx]){
					#print " ...common file\n";
					# test for content and file type print results if a match
					#testFile($dPath . $files[$indx]);
					$_ = $files[$indx]; 
					if(/$sStrng/i) {print "matched ...$dPath$files[$indx]\n\n";}
					
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
# searchFiles - search files and scan tranverse directories for files containing and input string
#
# 2025-10-19 - jpl Original Version
#
#		Only known deficiency is this version won't traverse logical links
#
#		Inputs	-d "directory name" base directory for beginning of search
#			-s "search string"  string to search in suspect file names
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
