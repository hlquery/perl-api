use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Hlquery',
    VERSION_FROM        => 'lib/Hlquery.pm',
    AUTHOR              => 'Carlos F. Ferry <carlos.ferry@gmail.com>',
    ABSTRACT            => 'Perl client library for hlquery search engine',
    LICENSE             => 'bsd',
    PREREQ_PM => {
        'LWP::UserAgent' => 0,
        'JSON'           => 0,
        'JSON::MaybeXS'  => 0,
        'URI'            => 0,
        'URI::Escape'    => 0,
        'Digest::MD5'    => 0,
        'Mojolicious'    => 0,
        'Promises'       => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Hlquery-*' },
);
