<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**Perl client resources for `hlquery`: packaging files, examples, and API usage notes.**

[![GitHub](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white)](https://github.com/hlquery/hlquery)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

</div>

# hlquery Perl API

This directory contains the Perl client packaging metadata, runnable examples,
and README documentation used by the `hlquery` Perl API.

## What Is Here

- `Makefile.PL` and `cpanfile` for dependency management and packaging
- `example.pl` for quick end-to-end API checks
- `examples/` for focused collection, document, search, and flush examples
- `LICENSE` for the BSD 3-Clause license

## Installation

Install the declared dependencies:

```bash
cpanm --installdeps .
```

Or install the core runtime modules directly:

```bash
cpanm LWP::UserAgent JSON JSON::MaybeXS URI URI::Escape Digest::MD5 Mojolicious Promises
```

If you are working from a Perl client checkout or release tarball that includes
the client modules under `lib/`, load the client like this:

```perl
use lib '/path/to/hlquery/etc/api/perl/lib';
use Hlquery::Client;
```

## Quick Start

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

## Authentication

```perl
my $client = Hlquery::Client->new('http://localhost:9200', {
    token => 'your_token_here',
    auth_method => 'bearer',
});

$client->SetAuthToken('your_token_here', 'bearer');
$client->SetAuthToken('your_api_key_here', 'api-key');
```

## Common APIs

Collections:

```perl
my $collections = $client->Collections();
my $list = $collections->List(0, 10);
my $get = $collections->Get('music');
my $create = $collections->Create('music', {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'artist', type => 'string' },
    ],
});
```

Documents:

```perl
my $documents = $client->Documents();

my $add = $documents->Add('music', {
    id => 'track_1',
    title => 'Like a Prayer',
    artist => 'Madonna',
});

my $list = $client->ListDocuments('music', { offset => 0, limit => 10 });
my $doc = $client->GetDocument('music', 'track_1');
```

Search:

```perl
my $results = $client->Search('music', {
    q => 'madonna',
    query_by => 'title,artist',
    limit => 10,
});
```

## SAM

`hlquery` also exposes the Secondary Assistant Manager (`SAM`) endpoints:

- `GET /sam/search`
- `GET /sam/status`
- `GET /sam/history`

If your Perl client build exposes a raw request helper such as
`ExecuteRequest`, you can call those routes directly:

```perl
my $sam = $client->ExecuteRequest('GET', '/sam/search', undef, {
    collection => 'music',
    q => 'queen of pop',
    limit => 10,
});

my $status = $client->ExecuteRequest('GET', '/sam/status', undef, {
    collection => 'music',
});

my $history = $client->ExecuteRequest('GET', '/sam/history', undef, {
    collection => 'music',
    limit => 5,
});
```

SAM search now accepts SQL-style wildcard intent in `q` as well:

- `%madonna%` for contains-style matching
- `madonna%` for prefix-style matching
- `%queen_` where `_` matches a single character

## Examples

Run the all-in-one example:

```bash
perl example.pl
perl example.pl status
perl example.pl cols 0 10
perl example.pl docs music
```

Run the focused examples:

```bash
perl examples/basic_usage.pl
perl examples/collections.pl
perl examples/documents.pl
perl examples/search.pl
perl examples/flush.pl
```

## Notes

- Base URL defaults to `http://localhost:9200`.
- Examples also check `HLQ_BASE_URL` and `HLQUERY_BASE_URL`.
- Use canonical module names such as `Hlquery::Client`.
- Lowercase file-based imports like `Hlquery::client` should not be used.

## License

BSD 3-Clause. See [LICENSE](./LICENSE).
