#!/usr/bin/perl

require 5.000;

# This script has split some functions off into a util
# script so they can be re-used by other scripts.
require "build-seamonkey-util.pl";

use Sys::Hostname;
use POSIX "sys_wait_h";
use Cwd;

$Version = '$Revision: 1.42 $ ';


sub PrintUsage {
  die <<END_USAGE
usage: $0 [options]
Options:
  --depend               Build depend (must have this option or clobber).
  --clobber              Build clobber.
  --once                 Do not loop.
  --compress             Use '-z3' for cvs.
  --example-config       Print an example 'tinderconfig.pl'.
  --noreport             Do not report status to tinderbox server.
  --nofinalreport        Do not report final status, only start status.
  --notest               Do not run smoke tests.
  --timestamp            Pull by date.
   -tag TREETAG          Pull by tag (-r TREETAG).
   -t TREENAME           The name of the tree
  --mozconfig FILENAME   Provide a mozconfig file for client.mk to use.
  --version              Print the version number (same as cvs revision).
  --testonly             Only run the smoke tests (do not pull or build).
  --help
More details:
  To get started, run '$0 --example-config'.
END_USAGE
}

&InitVars;
&ParseArgs;
&ConditionalArgs;
&GetSystemInfo;
&LoadConfig;
&SetupEnv;
&SetupPath;
&BuildIt;

1;

# End of main
# ------------------------------------------------------

sub ParseArgs {
  
  &PrintUsage if $#ARGV == -1;

  while ($arg = shift @ARGV) {
    $BuildDepend = 0   , next if $arg eq '--clobber';
    $BuildDepend = 1   , next if $arg eq '--depend';
    $CVS = 'cvs -q -z3', next if $arg eq '--compress';
    &PrintExampleConfig, exit if $arg eq '--example-config';
    &PrintUsage        , exit if $arg eq '--help' or $arg eq '-h';
    $ReportStatus = 0  , next if $arg eq '--noreport';
    $ReportFinalStatus = 0  , next if $arg eq '--nofinalreport';
    $RunTest = 0       , next if $arg eq '--notest';
    $BuildOnce = 1     , next if $arg eq '--once';
    $UseTimeStamp = 1  , next if $arg eq '--timestamp';
    $TestOnly = 1      , next if $arg eq '--testonly';

    if ($arg eq '-tag') {
      $BuildTag = shift @ARGV;
      &PrintUsage if $BuildTag eq '' or $BuildTag eq '-t';
    }
    elsif ($arg eq '-t') {
      $BuildTree = shift @ARGV;
      &PrintUsage if $BuildTree eq '';
    }
    elsif ($arg eq '--mozconfig' or $arg eq '--configfile') {
	  # File generated by the build configurator,
      #   http://cvs-mirror.mozilla.org/webtools/build/config.cgi
      $MozConfigFileName = shift @ARGV;
      &PrintUsage if $MozConfigFileName eq '';
    }
    elsif ($arg eq '--version' or $arg eq '-v') {
      die "$0: version" . substr($Version,9,6) . "\n";
    } else {
      &PrintUsage;
    }
  }
  &PrintUsage if $BuildTree =~ /^\s+$/i;
}

sub PrintExampleConfig {
  print "#- tinder-config.pl - Tinderbox configuration file.\n";
  print "#-    Uncomment the variables you need to set.\n";
  print "#-    The default values are the same as the commented variables\n\n";
  
  while (<DATA>) {
    s/^\$/\#\$/;
    print;
  }
}

sub ConditionalArgs {
  my $cvsuser = $ENV{USER};

  $fe          = 'mozilla-bin';
  $RelBinaryName  = "dist/bin/$fe";
  #$FullBinaryName  = "$BaseDir/$DirName/$TopLevel/$Topsrcdir/$RelBinaryName";
  $ENV{CVSROOT} = ":pserver:$cvsuser\@cvs.mozilla.org:/cvsroot";
  print "build-seamonkey.pl: CVSROOT = $ENV{CVSROOT}\n";
  $CVSCO      .= " -r $BuildTag" unless $BuildTag eq '';
}


sub BuildIt {
  my $EarlyExit, $LastTime, $SaveCVSCO, $comptmp;

  die "\$BuildName is the empty string ('')\n" if $BuildName eq '';

  $comptmp = '';
  $jflag   = '';
  
  mkdir $DirName, 0777;
  chdir $DirName or die "Couldn't enter $DirName";
  
  $StartDir  = getcwd();
  $LastTime  = 0;
  $EarlyExit = 0;
  $SaveCVSCO = $CVSCO;
  
  # Bypass profile at startup.
  $ENV{MOZ_BYPASS_PROFILE_AT_STARTUP} = "1";

  print "Starting dir is : $StartDir\n";
  
  while (not $EarlyExit) {
    chdir $StartDir;

    if (not $TestOnly and (time - $LastTime < (60 * $BuildSleep))) {
      $SleepTime = (60 * $BuildSleep) - (time - $LastTime);
      print "\n\nSleeping $SleepTime seconds ...\n";
      sleep $SleepTime;
    }
    $LastTime = time;
    
    if ($UseTimeStamp) {
      $CVSCO = $SaveCVSCO;
    } else {
      $CVSCO = $SaveCVSCO . ' -A';
    }
    $StartTime = time;
    
    if ($UseTimeStamp) {
      $BuildStart = `date '+%m/%d/%Y %H:%M'`;
      chomp($BuildStart);
      $CVSCO .= " -D '$BuildStart'";
    }

    &MailStartBuildMessage if $ReportStatus;

    $CurrentDir = getcwd();
    if ($CurrentDir ne $StartDir) {
      print "startdir: $StartDir, curdir $CurrentDir\n";
      die "curdir != startdir";
    }
    
    $BuildDir = $CurrentDir;
    
    unlink $logfile;
    
    print "Opening $logfile\n";

    open LOG, ">$logfile" or print "can't open $?\n";
    print LOG "current dir is -- " . $ENV{HOST} . ":$CurrentDir\n";
    print LOG "Build Administrator is $BuildAdministrator\n";
    &PrintEnv;
    if ($Compiler ne '') {
      print LOG "===============================\n";
      if ($Compiler eq 'gcc' or $Compiler eq 'egcc') {
        $comptmp = `$Compiler --version`;
        chomp($comptmp);
        print LOG "Compiler is -- $Compiler \($comptmp\)\n";
      } else {
        print LOG "Compiler is -- $Compiler\n";
      }
      print LOG "===============================\n";
    }
    
    $BuildStatus = 0;

    mkdir $TopLevel, 0777;
    chdir $TopLevel or die "chdir($TopLevel): $!\n";

    unless ($TestOnly) {
      print "$CVS $CVSCO mozilla/client.mk\n";
      print LOG "$CVS $CVSCO mozilla/client.mk\n";
      open PULL, "$CVS $CVSCO mozilla/client.mk 2>&1 |" or die "open: $!\n";
      while (<PULL>) {
        print $_;
        print LOG $_;
      }
      close PULL;
    }
    
    chdir $Topsrcdir or die "chdir $Topsrcdir: $!\n";
    
    #Delete the binaries before rebuilding
    unless ($TestOnly) {
      
	  # Only delete if it exists.
	  if (&BinaryExists($fe)) {
		print LOG "deleting existing binary: $fe\n";
		&DeleteBinary($fe);
	  } else {
		print LOG "no binary detected, can't delete.\n";
	  }

    }
    
    $ENV{MOZ_CO_DATE} = "$BuildStart" if $UseTimeStamp;
    
	# Don't build if testing smoke tests.
	unless ($TestOnly) {

	  # If we are building depend, don't clobber.
	  if ($BuildDepend) {
		print LOG "$Make -f client.mk\n";
		open MAKEDEPEND, "$Make -f client.mk 2>&1 |";
		while (<MAKEDEPEND>) {
		  print $_;
		  print LOG $_;
		}
		close MAKEDEPEND;
	  } else {
		# Building clobber
        print LOG "$Make -f client.mk checkout realclean build 2>&1 |\n";
        open MAKECLOBBER, "$Make -f client.mk checkout realclean build 2>&1 |";
        while (<MAKECLOBBER>) {
          print $_;
          print LOG $_;
        }
        close MAKECLOBBER;
      }

    } # unless ($TestOnly)
    
	if (&BinaryExists($fe)) {
	  if ($RunTest) {
		print LOG "export binary exists, build successful.\n";

        # Mozilla AliveTest.
		print LOG "Running AliveTest ...\n";
		print "Running AliveTest ...\n";
		$BuildStatus = &RunAliveTest($fe);

		# ViewerTest.
		if ($BuildStatus == 0 and $ViewerTest) {
		  print LOG "Running ViewerTest ...\n";
		  print "Running ViewerTest ...\n";
		  $BuildStatus = &RunAliveTest('viewer');
		}
		

        # BloatTest.
		if ($BuildStatus == 0 and $BloatStats) {
		  $BuildStatusStr = 'success';
		  print LOG "Running BloatTest ...\n";
		  print "Running BloatTest ...\n";
		  $BuildStatus = &RunBloatTest($fe);
		}

        # Run Editor test.
		if ($BuildStatus == 0 and $EditorTest) {
		  $BuildStatusStr = 'success';
		  print LOG "Running EditorTest ...\n";
          print "Running EditorTest ...\n";
		  $BuildStatus = &RunFileBasedTest("TestOutSinks", 15, "FAILED");
		}
        

	  } else {
		print LOG "export binary exists, build successful. Skipping test.\n";
		$BuildStatus = 0;
	  }
	} else {
	  print LOG "export binary missing, build FAILED\n";
	  $BuildStatus = 666;
	} # if (&BinaryExists($fe))


	if ($BuildStatus == 0) {
	  $BuildStatusStr = 'success';
	}
	elsif ($BuildStatus == 333) {
	  $BuildStatusStr = 'testfailed';
	} else {
	  $BuildStatusStr = 'busted';
	}
    
    close LOG;
    chdir $StartDir;
    
    # This fun line added on 2/5/98. do not remove. Translated to english,
    # that's "take any line longer than 1000 characters, and split it into less
    # than 1000 char lines.  If any of the resulting lines is
    # a dot on a line by itself, replace that with a blank line."  
    # This is to prevent cases where a <cr>.<cr> occurs in the log file. 
    # Sendmail interprets that as the end of the mail, and truncates the
    # log before it gets to Tinderbox.  (terry weismann, chris yeh)
    #
    # This was replaced by a perl 'port' of the above, writen by 
    # preed@netscape.com; good things: no need for system() call, and now it's
    # all in perl, so we don't have to do OS checking like before.
    #
	
	# Rewrite LOG to OUTLOG, shortening lines.
    open LOG, "$logfile" or die "Couldn't open logfile: $!\n";
    open OUTLOG, ">${logfile}.last" or die "Couldn't open logfile: $!\n";
    
	# Stuff the status at the top of the new file, so
	# we don't need to parse the whole file to get to the
	# status part on the server-side.
	print OUTLOG "tinderbox: tree: $BuildTree\n";
	print OUTLOG "tinderbox: builddate: $StartTime\n";
	print OUTLOG "tinderbox: status: $BuildStatusStr\n";
	print OUTLOG "tinderbox: build: $BuildName\n";
	print OUTLOG "tinderbox: errorparser: unix\n";
	print OUTLOG "tinderbox: buildfamily: unix\n";
	print OUTLOG "tinderbox: version: $Version\n";
	print OUTLOG "tinderbox: END\n";            

    while (<LOG>) {
      for ($q = 0; ; $q++) {
        $val = $q * 1000;
        $Output = substr $_, $val, 1000;
        
        last if $Output eq undef;
        
        $Output =~ s/^\.$//g;
        $Output =~ s/\n//g;
        print OUTLOG "$Output\n";
      }
    }
    
    close LOG;
    close OUTLOG;
    if ($ReportStatus and $ReportFinalStatus) {
	  system("$mail $Tinderbox_server < ${logfile}.last");
	} 

    unlink("$logfile");
    
    # If this is a test run, set early_exit to 0. 
    # This mean one loop of execution
    $EarlyExit++ if $BuildOnce;
  }
}

sub MailStartBuildMessage {
  
  open LOG, "|$mail $Tinderbox_server";

  print LOG "\n";
  print LOG "tinderbox: tree: $BuildTree\n";
  print LOG "tinderbox: builddate: $StartTime\n";
  print LOG "tinderbox: status: building\n";
  print LOG "tinderbox: build: $BuildName\n";
  print LOG "tinderbox: errorparser: unix\n";
  print LOG "tinderbox: buildfamily: unix\n";
  print LOG "tinderbox: version: $Version\n";
  print LOG "tinderbox: END\n";
  print LOG "\n";

  close LOG;
}

# check for the existence of the binary
sub BinaryExists {
  my ($fe) = @_;
  my $BinName;
  
  $BinName = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  
  if (-e $BinName and -x _ and -s _) {
    print LOG "$BinName exists, is nonzero, and executable.\n";  
    1;
  }
  else {
    print LOG "$BinName doesn't exist, is zero-size, or not executable.\n";
    0;
  } 
}

sub DeleteBinary {
  my ($fe) = @_;
  my $BinName;

  print LOG "DeleteBinary: fe      = $fe\n";
  
  $BinName = "$BuildDir/$TopLevel/${Topsrcdir}/$RelBinaryName";

  print LOG "unlinking $BinName\n";
  unlink $BinName or print LOG "ERROR: Unlinking $BinName failed\n";
}

sub PrintEnv {
  my($key);
  foreach $key (sort keys %ENV) {
    print LOG "$key=$ENV{$key}\n";
    print "$key=$ENV{$key}\n";
  }
  if (-e $ENV{MOZCONFIG}) {
    print LOG "-->mozconfig<----------------------------------------\n";
    print     "-->mozconfig<----------------------------------------\n";
    open CONFIG, "$ENV{MOZCONFIG}";
    while (<CONFIG>) {
      print LOG "$_";
      print     "$_";
    }
    close CONFIG;
    print LOG "-->end mozconfig<----------------------------------------\n";
    print     "-->end mozconfig<----------------------------------------\n";
  }
}

# Parse a file for $token, given a file handle.
# Return 1 if found, 0 otherwise.
sub parse_file_for_token {
  my ($filehandle, $token) = @_;
  my $foundStatus = 0;
  local $_;

  while (<$filehandle>) {
	chomp;
    if (/$token/) {
	  print "Found a \"$token\"!\n";
      $foundStatus = 1;
    }
  }

  return $foundStatus;
}



sub killer {
  &killproc($pid);
}

sub killproc {
  my ($local_pid) = @_;
  my $status;

  # try to kill 3 times, then try a kill -9
  for ($i=0; $i < 3; $i++) {
    kill('TERM',$local_pid);
    # give it 3 seconds to actually die
    sleep 3;
    $status = waitpid($local_pid, WNOHANG());
    last if $status != 0;
  }
  return $status;
}

#
# Start up Mozilla, test passes if Mozilla is still alive
# after $waittime (seconds).
#
sub RunAliveTest {
  my ($fe) = @_;
  my $Binary;
  my $status = 0;
  my $waittime = 45;
  $fe = 'x' unless defined $fe;
  
  $ENV{LD_LIBRARY_PATH} = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $ENV{MOZILLA_FIVE_HOME} = $ENV{LD_LIBRARY_PATH};
  $Binary = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  
  print LOG "$Binary\n";
  $BinaryDir = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $Binary    = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin/$fe";
  $BinaryLog = $BuildDir . '/runlog';
  
  # Fork off a child process.
  $pid = fork;

  unless ($pid) { # child
    
    chdir $BinaryDir;
    unlink $BinaryLog;
    $SaveHome = $ENV{HOME};
    $ENV{HOME} = $BinaryDir;
    open STDOUT, ">$BinaryLog";
    select STDOUT; $| = 1; # make STDOUT unbuffered
    open STDERR,">&STDOUT";
    select STDERR; $| = 1; # make STDERR unbuffered
    exec $Binary;
    close STDOUT;
    close STDERR;
    $ENV{HOME} = $SaveHome;
    die "Couldn't exec()";
  }
  
  # parent - wait $waittime seconds then check on child
  sleep $waittime;
  $status = waitpid($pid, WNOHANG());

  print LOG "$fe quit AliveTest with status $status\n";
  if ($status != 0) {
    print LOG "$fe has crashed or quit on the AliveTest.  Turn the tree orange now.\n";
    print LOG "----------- failure output from $fe for alive test --------------- \n";
    open READRUNLOG, "$BinaryLog";
    while (<READRUNLOG>) {
      print $_;
      print LOG $_;
    }
    close READRUNLOG;
    print LOG "--------------- End of AliveTest($fe) Output -------------------- \n";
    return 333;
  }
  
  print LOG "Success! $fe is still running.\n";

  &killproc($pid);

  print LOG "----------- success output from $fe for alive test --------------- \n";
  open READRUNLOG, "$BinaryLog";
  while (<READRUNLOG>) {
    print $_;
    print LOG $_;
  }
  close READRUNLOG;
  print LOG "--------------- End of AliveTest ($fe) Output -------------------- \n";
  return 0;

} # RunAliveTest

# Run a generic test that writes output
# to stdout, save that output to a file,
# parse the file looking for failure token and
# report status based on that.  A hack, but should
# be useful for many tests.
#
#     testBinary = Test we're gonna run, in dist/bin.
# testTimeoutSec = Timeout for hung tests, minimum test time.
#   failureToken = What string to look for in test output to 
#                  determine failure.
#
# Note: I tried to merge this function with RunAliveTest(),
#       the process flow control got too confusing :(  -mcafee
#
sub RunFileBasedTest {
  my ($testBinary, $testTimeoutSec, $failureToken) = @_;
  my $Binary;

  print LOG "testBinary = ", $testBinary, "\n";

  $ENV{LD_LIBRARY_PATH} = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $ENV{MOZILLA_FIVE_HOME} = $ENV{LD_LIBRARY_PATH};

  $BinaryDir = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $Binary    = $BinaryDir . '/' . $testBinary;
  $BinaryLog = $BuildDir . '/' .$testBinary . '.log';

  # If we care about log files, clear the old log, if there is one.
  unlink($BinaryLog);

  print LOG "Binary = ", $Binary, "\n";
  print "Binary = ", $Binary, "\n";

  print LOG "BinaryLog = ", $BinaryLog, "\n";
  print "BinaryLog = ", $BinaryLog, "\n";

  # Fork off a child process.
  $pid = fork;

  unless ($pid) { # child
	print "child\n";
    print LOG "child\n";

    print LOG "2:Binary = ", $Binary, "\n";
    print "2:Binary = ", $Binary, "\n";


	# The following set of lines makes stdout/stderr show up
	# in the tinderbox logs.
    $SaveHome = $ENV{HOME};
    $ENV{HOME} = $BinaryDir;
    open STDOUT, ">$BinaryLog";
    select STDOUT; $| = 1; # make STDOUT unbuffered
    open STDERR,">&STDOUT";
    select STDERR; $| = 1; # make STDERR unbuffered
	

	# Timestamp when we're running the test.
    print LOG `date`, "\n";
    print `date`, "\n";

	if (-e $Binary) {
	  $cmd = "$testBinary";   
	  print LOG $cmd, "\n";
	  print $cmd, "\n";
	  print LOG $cmd;
	  chdir($BinaryDir);
	  exec ($cmd);
	} else {
	  print LOG "ERROR: cannot run ", $Binary, ".\n";
	  print "ERROR: cannot run ", $Binary, ".\n";
	}

    close STDOUT;
    close STDERR;
    $ENV{HOME} = $SaveHome;
    die "Couldn't exec()";	
  } else {
	print "parent\n";
    print LOG "parent\n";
  }

  # Set up a timer with a signal handler.
  $SIG{ALRM} = \&killer;

  # Wait $testTimeoutSec seconds, then kill the process if it's still alive.
  alarm $testTimeoutSec;

  $status = waitpid($pid, 0);

  # Back to parent.

  # Clear the alarm so we don't kill the next test!
  alarm 0;

  #
  # Determine proper status, look in log file for failure token.
  #

  open TESTLOG, "<$BinaryLog" or die "Can't open $!";
  $status = parse_file_for_token(*TESTLOG, $failureToken);
  close TESTLOG;

  print LOG "$testBinary exited with status $status\n";

  #
  # Write test output to log.
  #
  if ($status != 0) {
    print LOG "$testBinary has crashed or quit.  Turn the tree orange now.\n";
    print LOG "----------- failure output from ", $testBinary, " test --------------- \n";
  } else {
	print LOG "----------- success output from ", $testBinary, " test --------------- \n";
  }

  # Parse the test log, dumping lines into tinderbox log.
  open READRUNLOG, "$BinaryLog";
  while (<READRUNLOG>) {
	print $_;
	print LOG $_;
  }
  close READRUNLOG;
  print LOG "--------------- End of ", $testBinary, " Output -------------------- \n";

  # 0 = success, 333 = orange.
  if ($status != 0) {
    return 333;
  } else {
	return 0;
  }

} # RunFileBasedTest


sub RunBloatTest {
  my ($fe) = @_;
  my $Binary;
  my $status = 0;
  $fe = 'x' unless defined $fe;

  print LOG "in runBloatTest\n";

  $ENV{LD_LIBRARY_PATH} = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $ENV{MOZILLA_FIVE_HOME} = $ENV{LD_LIBRARY_PATH};

  # Turn on ref counting to track leaks (bloaty tool).
  $ENV{XPCOM_MEM_BLOAT_LOG} = "1";

  $Binary    = "$BuildDir/$TopLevel/$Topsrcdir/$RelBinaryName";
  $BinaryDir = "$BuildDir/$TopLevel/$Topsrcdir/dist/bin";
  $BinaryLog = $BuildDir . '/bloat-cur.log';
  
  rename ($BinaryLog, "$BuildDir/bloat-prev.log");
  
  # Fork off a child process.
  $pid = fork;

  unless ($pid) { # child
    chdir $BinaryDir;

    $SaveHome = $ENV{HOME};
    $ENV{HOME} = $BinaryDir;
    open STDOUT, ">$BinaryLog";
    select STDOUT; $| = 1; # make STDOUT unbuffered
    open STDERR,">&STDOUT";
    select STDERR; $| = 1; # make STDERR unbuffered

	if (-e "bloaturls.txt") {
	  $cmd = "$Binary -f bloaturls.txt";
	  print LOG $cmd;
	  exec ($cmd);
	} else {
	  print LOG "ERROR: bloaturls.txt does not exist.\n";
	}

    close STDOUT;
    close STDERR;
    $ENV{HOME} = $SaveHome;
    die "Couldn't exec()";
  }
  
  # Set up a timer with a signal handler.
  $SIG{ALRM} = \&killer;

  # Wait 120 seconds, then kill the process if it's still alive.
  alarm 120;

  $status = waitpid($pid, 0);

  # Clear the alarm so we don't kill the next test!
  alarm 0;

  print LOG "Client quit Bloat Test with status $status\n";
  if ($status <= 0) {
    print LOG "$Binary has crashed or quit on the BloatTest.  Turn the tree orange now.\n";
    print LOG "----------- failure Output from mozilla-bin for BloatTest --------------- \n";
    open READRUNLOG, "$BinaryLog";
    while (<READRUNLOG>) {
      print $_;
      print LOG $_;
    }
    close READRUNLOG;
    print LOG "--------------- End of BloatTest Output -------------------- \n";

	# HACK.  Clobber isn't reporting bloat status properly,
	# only turn tree orange for depend build.  This has
	# been filed as bug 22052.  -mcafee
	if ($BuildDepend == 1) {
	  return 333;
	} else {
	  return 0;
	}
  }

  print LOG "<a href=#bloat>\n######################## BLOAT STATISTICS\n";

  
  open DIFF, "$BuildDir/../bloatdiff.pl $BuildDir/bloat-prev.log $BinaryLog |" or 
	die "Unable to run bloatdiff.pl";

  while (my $line = <DIFF>) {
    print LOG $line;
  }
  close(DIFF);
  print LOG "######################## END BLOAT STATISTICS\n</a>\n";
  
  print LOG "----------- success output from mozilla-bin for BloatTest --------------- \n";
  open READRUNLOG, "$BinaryLog";
  while (<READRUNLOG>) {
    print $_;
    print LOG $_;
  }
  close READRUNLOG;
  print LOG "--------------- End of BloatTest Output -------------------- \n";
  return 0;
  
}




__END__
#- PLEASE FILL THIS IN WITH YOUR PROPER EMAIL ADDRESS
$BuildAdministrator = "$ENV{USER}\@$ENV{HOST}";

#- You'll need to change these to suit your machine's needs
$BaseDir       = '/builds/tinderbox/SeaMonkey';
$DisplayServer = ':0.0';

#- Default values of command-line opts
#-
$BuildDepend       = 1;  # Depend or Clobber
$ReportStatus      = 1;  # Send results to server, or not
$ReportFinalStatus = 1;  # Finer control over $ReportStatus.
$BuildOnce         = 0;  # Build once, don't send results to server
$RunTest           = 1;  # Run the smoke tests on successful build, or not
$UseTimeStamp      = 1;  # Use the CVS 'pull-by-timestamp' option, or not
$TestOnly          = 0;  # Only run tests, don't pull/build

#- Set these to what makes sense for your system
$Make          = 'gmake'; # Must be GNU make
$MakeOverrides = '';
$mail          = '/bin/mail';
$CVS           = 'cvs -q';
$CVSCO         = 'checkout -P';

#- Set these proper values for your tinderbox server
$Tinderbox_server = 'tinderbox-daemon@tinderbox.mozilla.org';

#-
#- The rest should not need to be changed
#-

#- Minimum wait period from start of build to start of next build in minutes.
$BuildSleep = 10;

#- Until you get the script working. When it works,
#- change to the tree you're actually building
$BuildTree  = 'MozillaTest'; 

$BuildName        = '';
$BuildTag         = '';
$BuildObjName     = '';
$BuildConfigDir   = 'mozilla/config';
$BuildStart       = '';
$TopLevel         = '.';
$Topsrcdir        = 'mozilla';
$ClobberStr       = 'realclean';
$ConfigureEnvArgs = '';
$ConfigureArgs    = ' --cache-file=/dev/null ';
$ConfigGuess      = './build/autoconf/config.guess';
$Logfile          = '${BuildDir}.log';
$Compiler         = 'gcc';
$ShellOverride    = ''; # Only used if the default shell is too stupid

# Need to end with a true value, (since we're using "require").
1;
