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

my $sql = $client->SQL();

my $rows = $sql->Query('SHOW COLLECTIONS;');
print "SHOW COLLECTIONS status: " . $rows->GetStatusCode() . "\n";
print $rows->GetRawBody() . "\n";

