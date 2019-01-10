# -------------------------------------------------------------------------
# Package
#    resultDriver.pl
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


# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use warnings;
use strict;
$|=1;

use ElectricCommander;

# use module
use XML::Simple;
use Data::Dumper;
use utf8;
use Encode;
use File::Copy;
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander;
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
	# create object
	my $xml = new XML::Simple;

	# read XML file
	my $resultXML = '.\Report\Results.xml';
	my $fullPath = $::gResultPath.'\Report\Results.xml';

    my $new_version;
    my ($testName, $status, $totalTests, $message);

    unless (-f $fullPath) {
        # New version
        my $htmlReport = $::gResultPath. '\Report\run_results.html';
        if (-f $htmlReport) {
            my $reportFilename = 'run_results.html';
            mkdir './artifacts' or die "Cannot create artifacts directory: $!";
            copy $htmlReport, "artifacts/$reportFilename" or die "Cannot copy report: $!";

            my $jobStepid = $ENV{COMMANDER_JOBSTEPID};
            my $link = "/commander/jobSteps/$jobStepid/$reportFilename";
            $ec->setProperty('/myJob/report-urls/Report', $link);
            print "Copied report into job workspace\n";
            exit 0;
        }

    }

    print "ResultXML: $fullPath\n";
    my $data = $xml->XMLin($fullPath);

    my $testPassed = $data->{Doc}->{Summary}->{passed};
    my $testFailed = $data->{Doc}->{Summary}->{failed};
    my $testWarnings = $data->{Doc}->{Summary}->{warnings};
    my $totalTests = $testPassed+$testFailed+$testWarnings;

    my $message = "Test Passed:$testPassed Failed:$testFailed Warnings:$testWarnings";

    if($testFailed > 0){
        print "IN Errors \n";
        errors($message);
    } elsif ($testWarnings > 0){
        print "IN Warnings \n";
        errors($message);
    } elsif ($testPassed >= 0){
        print "IN Success \n";
        success($message);
    }
    $testName = $data->{Doc}->{DName};
    $status = $data->{Doc}->{NodeArgs}->{status};

    # access XML data
    #print Dumper ($data);
    # print "Test Name:$data->{Doc}->{DName} \n";
    print "Test Name:$testName \n";
    # print "Status:$data->{Doc}->{NodeArgs}->{status} \n";
    print "Status:$status \n";
    print "Total Tests:$totalTests. $message\n";
}


#-------------------------------------------------------------------------
#  warnings
#
#   Print an error message
#
#   Parameters:
#       msgText     -   Optional warning text to display
#
#   Returns:
#       none
#
#-------------------------------------------------------------------------
sub warnings() {
    my ($message) = @_;

    my $ec = new ElectricCommander;

    $ec->setProperty("/myJobStep/outcome", 'warning');
    chomp($message);
    $message =~ s/\.$//;
    $message = "Warning: $message.\n";
	$ec->setProperty("summary", $message . "\n");

    print(STDERR $message);
}

#-------------------------------------------------------------------------
#  errors
#
#   Print an error message
#
#   Parameters:
#       msgText     -   Optional error text to display
#
#   Returns:
#       none
#
#-------------------------------------------------------------------------
sub errors() {
    my ($message) = @_;

    my $ec = new ElectricCommander;

    $ec->setProperty("/myJobStep/outcome", 'error');
    chomp($message);
    $message =~ s/\.$//;
    $message = "Error: $message.\n";
	$ec->setProperty("summary", $message . "\n");

    print(STDERR $message);

}

#-------------------------------------------------------------------------
#  success
#
#   Print an error message
#
#   Parameters:
#       msgText     -   Optional success text to display
#
#   Returns:
#       none
#
#-------------------------------------------------------------------------
sub success() {
    my ($message) = @_;

    my $ec = new ElectricCommander;

    $ec->setProperty("/myJobStep/outcome", 'success');
    chomp($message);
    $message =~ s/\.$//;
    $message = "Success: $message.\n";
	$ec->setProperty("summary", $message . "\n");

    print(STDERR $message);

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

