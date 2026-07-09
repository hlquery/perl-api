use strict;
use warnings;

use lib 'lib';
use Hlquery::Client;

my $base_url = $ENV{HLQ_BASE_URL}
    // $ENV{HLQUERY_BASE_URL}
    // 'http://localhost:9200';

my $client = Hlquery::Client->new($base_url, {
    token => $ENV{HLQ_TOKEN} // $ENV{HLQUERY_TOKEN},
});

my $sql = $client->sql;

my $rows = $sql->query('SHOW COLLECTIONS;');
print "SHOW COLLECTIONS status: " . $rows->get_status_code . "\n";
print $rows->get_raw_body . "\n";
