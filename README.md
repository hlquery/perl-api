<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**Perl client resources for hlquery, designed around the same practical API coverage as the other official clients.**

[![GitHub](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white)](https://github.com/hlquery/hlquery)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

</div>

### What is the hlquery Perl API?

The Perl API directory contains the hlquery Perl client resources, packaging metadata, runnable examples, and usage notes. It is the Perl entry point for talking to hlquery without building raw HTTP requests around `LWP::UserAgent` by hand.

### Why use it?

- Faster path to collections, documents, search, and admin endpoints.
- Shared auth and request behavior instead of repeating transport code.
- Direct access to examples and packaging files in one place.

### Why choose it over raw HTTP?

- Less repetitive request and JSON glue code.
- Cleaner client entry point for common tasks.
- Still flexible enough to hit raw SAM or module routes directly.

### Install

Install dependencies:

```bash
cpanm --installdeps .
```

Or install the runtime modules directly:

```bash
cpanm LWP::UserAgent JSON JSON::MaybeXS URI URI::Escape Digest::MD5 Mojolicious Promises
```

When loading from a local checkout:

```perl
use lib '/path/to/hlquery/etc/api/perl/lib';
use Hlquery::Client;
```

### Quick Start

```perl
use Hlquery::Client;

my $base_url = $ENV{HLQ_BASE_URL}
    // $ENV{HLQUERY_BASE_URL}
    // 'http://localhost:9200';

my $client = Hlquery::Client->new($base_url);

my $health = $client->Health();
print "Health status: " . $health->GetStatusCode() . "\n";

my $collections = $client->ListCollections(0, 10);
if ($collections->IsSuccess()) {
    my $body = $collections->GetBody();
    print "Collections: " . scalar(@{$body->{collections} || []}) . "\n";
}
```

### Auth

```perl
my $client = Hlquery::Client->new('http://localhost:9200', {
    token => 'your_token_here',
    auth_method => 'bearer',
});

$client->SetAuthToken('your_token_here', 'bearer');
$client->SetAuthToken('your_api_key_here', 'api-key');
```

### SAM

Call SAM endpoints through the raw request helper:

SAM is separate from vector search. It performs term and intent-style lookup, not vector similarity search.

```perl
my $status = $client->ExecuteRequest('GET', '/sam/status', undef, {
    collection => 'music',
});

my $history = $client->ExecuteRequest('GET', '/sam/history', undef, {
    collection => 'music',
    limit => 5,
});

my $results = $client->ExecuteRequest('GET', '/sam/search', undef, {
    collection => 'music',
    q => 'queen of pop',
    limit => 10,
});
```

### Reduce Text Example

Use the same raw request path for custom module routes:

```perl
my $module_response = $client->ExecuteRequest('GET', '/modules/<name>/<route>', undef, {
    q => 'example query',
});
```

### Examples

```bash
perl example.pl
perl examples/basic_usage.pl
perl examples/collections.pl
perl examples/documents.pl
perl examples/search.pl
perl examples/flush.pl
```

### Notes

- Base URL defaults to `http://localhost:9200`.
- Examples also check `HLQ_BASE_URL` and `HLQUERY_BASE_URL`.
- Use canonical module names such as `Hlquery::Client`.
