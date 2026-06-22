use strict;
use warnings;
use Test::More;
use HTTP::Response;
use URI;
use lib 'lib';
use Hlquery::Client;

{
    package Local::RecordingUA;

    sub new
    {
        return bless { requests => [] }, shift;
    }

    sub request
    {
        my ($self, $request) = @_;
        push @{$self->{requests}}, $request;
        return HTTP::Response->new(200, 'OK', ['Content-Type' => 'application/json'], '{}');
    }

    sub last_request
    {
        return $_[0]->{requests}->[-1];
    }
}

my $client = Hlquery::Client->new('http://localhost:9200');
my $ua = Local::RecordingUA->new();
$client->{user_agent} = $ua;

sub assert_request
{
    my ($method, $path, $message) = @_;
    my $request = $ua->last_request();
    is($request->method(), $method, "$message method");
    is($request->uri()->path(), $path, "$message path");
}

$client->GetCollectionFields('books and notes');
assert_request('GET', '/collections/books%20and%20notes', 'collection fields use the core collection route');

$client->SearchAPI()->MultiSearch([], 'GET');
assert_request('GET', '/multi_search', 'multi-search GET variant');

$client->SearchAPI()->MultiSearch([], 'POST');
assert_request('POST', '/multi_search', 'multi-search POST variant');

$client->Synonyms()->Upsert('books', 'quick fox', {}, 'POST');
assert_request('POST', '/collections/books/synonyms/quick%20fox', 'collection synonym POST upsert');

$client->Synonyms()->UpsertGlobal('quick fox', {}, 'POST');
assert_request('POST', '/synonyms/global/quick%20fox', 'global synonym POST upsert');

$client->Overrides()->Upsert('books', 'featured', {}, 'POST');
assert_request('POST', '/collections/books/overrides/featured', 'override POST upsert');

$client->Aliases()->Upsert('current books', {}, 'POST');
assert_request('POST', '/aliases/current%20books', 'alias POST upsert');

done_testing();
