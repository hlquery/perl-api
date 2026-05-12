use strict;
use warnings;

use lib 'lib';
use Hlquery::Client;

my $base_url = $ENV{HLQ_BASE_URL}
    // $ENV{HLQUERY_BASE_URL}
    // 'http://localhost:9200';

my $collection = $ARGV[0] // 'music';
my $query = $ARGV[1] // 'queen of pop';

my $client = Hlquery::Client->new($base_url, {
    token => $ENV{HLQ_TOKEN} // $ENV{HLQUERY_TOKEN},
});

my $sam = $client->SAM();
my $res = $sam->Search($collection, $query, { limit => 10 });

print "Status: " . $res->GetStatusCode() . "\n";
print $res->GetRawBody() . "\n";

