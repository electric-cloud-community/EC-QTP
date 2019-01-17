# -------------------------------------------------------------------------
# Package
#    qtpDriver.pl
# Dependencies
#    None
#
# Purpose
#    Use QuickTest Pro tool features on Electric Commander
#
# Plugin Version
#    1.0.6
#
# Date
#    02/21/2011
#
# Engineer
#    Oscar Arrieta
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------
   
# Important note about I18n:
# If property or parameter might contain high Unicode get the value from the property via the EC API:
# my $foo = ($ec->getProperty( "foo" ))->findvalue("//value");
   
# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use warnings;
use strict; 
$|=1;

use ElectricCommander;

use Win32::OLE;
use Win32::OLE::Variant qw(:DEFAULT nothing);
# Use Unicode UTF-8 encoding inside Win32::OLE
Win32::OLE->Option( CP => Win32::OLE::CP_UTF8 );

# Set OLE warn level to "warn", not "fail" on minor errors
$Win32::OLE::Warn = 3;

use utf8;

# -------------------------------------------------------------------------
# Procedure Parameters
# -------------------------------------------------------------------------

my $ec = new ElectricCommander;
$::gTestPath = ($ec->getProperty( "testPath" ))->findvalue('//value')->string_value;
$::gResultPath = ($ec->getProperty( "resultPath" ))->findvalue('//value')->string_value;

#-------------------------------------------------------------------------
# main - 
#        
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
#-------------------------------------------------------------------------
sub main() {

	print "Test path $::gTestPath \n";
	print "Result path $::gResultPath\n";
	
	#TestPath and ResutPath have to be different
	if($::gTestPath eq $::gResultPath){
		print "ERROR: Specifying the same root for the test path and test result fields is a unsupported action from QTP. \n";
		exit 1;
	}

	my $qtpApp;
	
	eval{
	$qtpApp = Win32::OLE->new( 'Quicktest.Application', 'Quit') or die print "ERROR - Unable to create the QTP Object";
	};
	die $@ if ($@);

	$qtpApp->Open($::gTestPath,1,0); 
	$qtpApp->Launch;
	$qtpApp->{Visible} = 0;
	
	my $qtResultsOpt = Win32::OLE->new( 'QuickTest.RunResultsOptions', 'Quit' );
	$qtResultsOpt->{ResultsLocation} = $::gResultPath; 
	$qtpApp->Test->Run($qtResultsOpt);

	my $status = $qtpApp->Test->LastRunResults->{Status};	
	print $status;
	
	my $ec = new ElectricCommander;
	if ($status eq 'Failed'){
		$ec->setProperty("/myJobStep/outcome", 'error');
	}
	$ec->setProperty("summary", 'Status: ' . $status . "\n");	
}

#------------------------------------------------------------------------
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties 
#              to be written into the Electric Commander
#
# Returns:
#   -nothing
#
#-------------------------------------------------------------------------
sub setProperties($) {

    my ($propHash) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);
    
 
    foreach my $key (keys % $propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
    }
}

main();

