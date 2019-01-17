use ElectricCommander;

push (@::gMatchers,
  {
        id =>          "testStarted",
        pattern =>     q{Starting the test @ (.+) \(},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Test started at: $1 ". "\n";
                                
                               setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "testCompleted",
        pattern =>     q{Tidying up ...    @ (.+) \(},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Test finished at : $1 ". "\n";
                                
                               setProperty("summary", $desc . "\n");
                              
                             },
  },
);



