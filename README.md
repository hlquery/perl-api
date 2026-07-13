<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>

<div align="center">

**Perl client library for hlquery.**

[![Follow hlquery](https://img.shields.io/badge/Follow-%40hlquery-blue?logo=x&logoColor=white&labelColor=000000)](https://x.com/hlquery)
[![Perl build](https://img.shields.io/badge/Perl%20build-passing-brightgreen?logo=perl&logoColor=white&labelColor=000000)](https://github.com/hlquery/perl-api/actions/workflows/perl-api.yml)
[![GitHub](https://img.shields.io/badge/GitHub-perl--api-purple?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/perl-api/)
[![hlquery](https://img.shields.io/badge/GitHub-hlquery-blue?logo=github&logoColor=white&labelColor=000000)](https://github.com/hlquery/hlquery/)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-a35a0f?logo=open-source-initiative&logoColor=white&labelColor=000000)](https://opensource.org/licenses/BSD-3-Clause)

</div>

## Overview

The hlquery Perl client wraps the HTTP API with service objects for collections, documents, search, SQL, and administration. It handles JSON, query parameters, auth headers, and response parsing so application code does not need to build raw `LWP::UserAgent` requests.

Preferred style:

```perl
$client->collections->get('products');
$client->documents->add('products', \%document);
```

Legacy calls such as `$client->Collections()->Get(...)` still work.

## Installation

```bash
cpanm --installdeps .
```

For local checkout use:

```perl
use lib '/path/to/hlquery/etc/api/perl/lib';
use Hlquery::Client;
```

## Quick Start

```perl
use strict;
use warnings;
use Hlquery::Client;

my $client = Hlquery::Client->new($ENV{HLQUERY_BASE_URL} || 'http://localhost:9200');

my $health = $client->health;
die "hlquery is not healthy\n" unless $health->is_success;

my $collections = $client->collections->list(0, 10);
print "collections status code: " . $collections->get_status_code . "\n";
```

Authentication:

```perl
my $client = Hlquery::Client->new('http://localhost:9200', {
    token       => 'your_token_here',
    auth_method => 'bearer',
});

$client->set_auth_token('your_api_key_here', 'api-key');
```

## Common Operations

Create and inspect a collection:

```perl
my $schema = {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'price', type => 'float' },
    ],
};

my $create = $client->collections->create('products', $schema);
die $create->get_error unless $create->is_success;

my $metadata = $client->collections->get('products');
my $language = $client->collections->language('products');
```

Add, update, list, and delete documents:

```perl
$client->documents->add('products', {
    id    => 'prod_1',
    title => 'Mechanical Keyboard',
    price => 129.99,
});

my $doc = $client->documents->get('products', 'prod_1');
my $docs = $client->documents->list('products', { offset => 0, limit => 20 });

$client->documents->update('products', 'prod_1', {
    title => 'Mechanical Keyboard Pro',
    price => 149.99,
});

$client->documents->delete('products', 'prod_1');
```

Search and SQL:

```perl
my $results = $client->documents->search('products', {
    q        => 'keyboard',
    query_by => 'title,description',
    limit    => 10,
});

my $rows = $client->sql->query('SHOW COLLECTIONS;');
my $top = $client->sql->search(
    'products',
    'SELECT id, title FROM products ORDER BY price DESC LIMIT 5;'
);
```

Bulk import documents and use advanced document routes:

```perl
$client->documents->import('products', [
    { id => 'prod_2', title => 'Mouse', price => 49.99 },
    { id => 'prod_3', title => 'Monitor', price => 299.00 },
]);

$client->documents->facets('products', { facet_by => 'brand' });
$client->documents->export('products', { filter_by => 'active:true' });
$client->search_api->multi_search([
    { collection => 'products', q => 'keyboard', query_by => 'title' },
]);
```

Call custom module routes directly:

```perl
my $response = $client->execute_request('GET', '/modules/<name>/<route>', undef, {
    q => 'example query',
});
```

## Checks

```bash
perl -Ilib -c lib/Hlquery/Client.pm
perl -Ilib -c lib/Hlquery/Response.pm
```

### License

The hlquery Perl API is licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause).

