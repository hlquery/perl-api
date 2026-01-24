# hlquery Perl Client Dependencies

requires 'LWP::UserAgent', '0';
requires 'JSON', '0';
requires 'URI', '0';
requires 'URI::Escape', '0';
requires 'Digest::MD5', '0';

on 'test' => sub {
    requires 'Test::More', '0';
    requires 'Test::Exception', '0';
};
