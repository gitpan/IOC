use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'IOC',
    VERSION_FROM => 'lib/IOC.pm', 
    PREREQ_PM    => {
        'Test::More'       => 0.47,
        'Test::Exception'  => 0.15,
        'Class::Throwable' => 0.04
    }
);
