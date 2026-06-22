<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**Perl client resources for hlquery, designed with a familiar and intuitive API structure.**

[![Follow hlquery](https://img.shields.io/badge/Follow-%40hlquery-blue?logo=x&logoColor=white&labelColor=000000)](https://x.com/hlquery)
[![Perl build](https://img.shields.io/badge/Perl%20build-passing-brightgreen?logo=perl&logoColor=white&labelColor=000000)](https://github.com/hlquery/perl-api/actions/workflows/perl-api.yml)
[![GitHub](https://img.shields.io/badge/GitHub-perl--api-purple?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/perl-api/)
[![hlquery](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/hlquery/)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-a35a0f?logo=open-source-initiative&logoColor=white&labelColor=000000)](https://opensource.org/licenses/BSD-3-Clause)


</div>

### What is the hlquery Perl API?

The Perl API directory contains the [hlquery](https://github.com/hlquery/hlquery) Perl client resources, packaging metadata, runnable examples, and usage notes. It is the Perl entry point for talking to hlquery without building raw HTTP requests around `LWP::UserAgent` by hand.

### Why use it?

Use the Perl API when you want hlquery integration to feel like part of your application instead of a stack of hand-written `LWP::UserAgent` calls and JSON handling. It cuts down repetitive transport code, keeps authentication and request behavior consistent, and gives you a cleaner path into collections, documents, search, and admin operations from normal Perl code.

### Install

Install dependencies:

```bash
$ cpanm --installdeps .
```

Or install the runtime modules directly:

```bash
$ cpanm LWP::UserAgent JSON JSON::MaybeXS URI URI::Escape Digest::MD5 Mojolicious Promises
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

### SQL

```perl
my $sql = $client->SQL();

my $rows = $sql->Query('SHOW COLLECTIONS;');
my $exec = $sql->Exec("INSERT INTO logs_archive (id, title) VALUES ('row-1', 'warm cache');");

my $products = $sql->Search('products',
    'SELECT id, title FROM products ORDER BY id DESC LIMIT 3;',
    { highlight => 0 }
);
```

### Current resource API

The client exposes service objects using the method names shown below:

```perl
my $metadata = $client->Collections()->Get('products');
my $language = $client->Collections()->Language('products');

# GetFields is retained for compatibility and returns the collection metadata;
# the server has no /collections/{name}/fields route.
my $metadata_again = $client->Collections()->GetFields('products');

my $context = $client->Documents()->Context('products', 'prod_1', { window => 3 });
my $facets = $client->Documents()->Facets('products', { facet_by => 'brand' });
my $export = $client->Documents()->Export('products', { filter_by => 'active:true' });
my $maybe = $client->Documents()->Maybe('products', { q => 'keybaord' });

$client->Documents()->UpdateByQuery('products', {
    filter_by => 'active:false', set => { archived => 1 },
});
$client->Documents()->DeleteByQuery('products', { filter_by => 'expired:true' });

my $searches = [{ collection => 'products', q => 'keyboard', query_by => 'title' }];
$client->SearchAPI()->MultiSearch($searches);        # POST (default)
$client->SearchAPI()->MultiSearch($searches, 'GET');
```

`Synonyms()->Upsert`, `Overrides()->Upsert`, and `Aliases()->Upsert` default to `PUT` and accept `POST` or `PUT` as the final argument. The same applies to global synonym upserts. The client also provides `Stopwords`, `Users`, `Keys`, `Links`, `Modules`, and `Analytics` service objects, plus direct wrappers for readiness, metrics, storage, integrity, counters, and repair.

Run the offline route contract with:

```bash
prove -Ilib t/route_contract.t
```

### Reduce Text Example

Use the same raw request path for custom module routes:

```perl
my $module_response = $client->ExecuteRequest('GET', '/modules/<name>/<route>', undef, {
    q => 'example query',
});
```

### Contributing

We welcome contributions from the community! All contributions must be released under the BSD 3-Clause license.

### How to Contribute

- Check existing [issues](https://github.com/hlquery/hlquery/issues) or create new ones
- Contribute to client libraries (Node.js, Go, Java, Python, PHP, Ruby, Rust, Perl, C++)
- Test and report bugs
- Improve documentation

### Community

- 📖 [Documentation](https://docs.hlquery.com)
- 🐦 [X (Twitter)](https://x.com/hlquery)
- 📦 [GitHub](https://github.com/hlquery/hlquery)

### License

hlquery is licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause).
