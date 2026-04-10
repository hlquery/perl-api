#!/usr/bin/env perl
# /*
#  * hlquery - Search beyond keywords.
#  * http://www.hlquery.com
#  *
#  * Copyright (C) 2021-2026, Carlos F. Ferry <carlos.ferry@gmail.com>
#  *
#  * This file is part of hlquery, released under the BSD License version 3.
#  * You are free to redistribute and/or modify this software
#  * under the terms of the BSD License.
#  * For more details, please visit: https://docs.hlquery.com
#  */

# /*
#  * Search Examples - Demonstrates search operations.
#  */

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;
use JSON;

my $client = Hlquery::Client->new('http://localhost:9200');
my $collection_name = 'perl_search_demo_' . time();

my $json = JSON->new->utf8->pretty;

$client->Collections()->Create($collection_name, {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'content', type => 'string' },
        { name => 'category', type => 'string' },
        { name => 'price', type => 'int32' },
    ],
});

$client->Documents()->Add($collection_name, {
    id => '1',
    title => 'Wireless Keyboard',
    content => 'Compact laptop accessory',
    category => 'electronics',
    price => 120,
});

$client->Documents()->Add($collection_name, {
    id => '2',
    title => 'Refurbished Laptop',
    content => 'Budget notebook option',
    category => 'electronics',
    price => 80,
});

print "Using collection: $collection_name\n\n";

# /* Simple search. */

my $results = $client->Search($collection_name, {
    q => 'keyboard',
    query_by => 'title,content',
    limit => 10
});

print "Search results: " . $json->encode($results->GetBody()) . "\n";

# /* Search with filters and sorting. */

$results = $client->Search($collection_name, {
    q => 'keyboard',
    query_by => 'title',
    sort_by => 'title',
    limit => 5
});

print "Filtered search: " . $json->encode($results->GetBody()) . "\n";

# /* Multi-search. */

my $searches = [
    { collection => $collection_name, q => 'keyboard', query_by => 'title' },
    { collection => $collection_name, q => 'notebook', query_by => 'content' }
];

$results = $client->SearchAPI()->MultiSearch($searches);

print "Multi-search: " . $json->encode($results->GetBody()) . "\n";

# /* Supported query semantics. */

# /* Field-specific search. */

$results = $client->Search($collection_name, {
    q => 'title:laptop',
    query_by => 'title,content',
    limit => 10
});

print "Field search: " . $json->encode($results->GetBody()) . "\n";

# /* Boolean OR query. */

$results = $client->Search($collection_name, {
    q => 'title:laptop OR title:notebook',
    query_by => 'title,content',
    limit => 10
});

print "Boolean OR search: " . $json->encode($results->GetBody()) . "\n";

# /* Boolean NOT query. */

$results = $client->Search($collection_name, {
    q => 'title:laptop NOT title:refurbished',
    query_by => 'title,content',
    limit => 10
});

print "Boolean NOT search: " . $json->encode($results->GetBody()) . "\n";

# /* Phrase search. */

$results = $client->Search($collection_name, {
    q => '"wireless keyboard"',
    query_by => 'title',
    limit => 10
});

print "Phrase search: " . $json->encode($results->GetBody()) . "\n";

# /* Wildcard search. */

$results = $client->Search($collection_name, {
    q => 'laptop*',
    query_by => 'title,content',
    limit => 10
});

print "Wildcard search: " . $json->encode($results->GetBody()) . "\n";

# /* query_by restriction. */

$results = $client->Search($collection_name, {
    q => 'laptop',
    query_by => 'title',
    limit => 10
});

print "query_by restricted search: " . $json->encode($results->GetBody()) . "\n";

# /* Filter operators belong in filter_by. */

$results = $client->Search($collection_name, {
    q => '*',
    query_by => 'title,content',
    filter_by => 'price:>100&&category:electronics',
    limit => 10
});

print "Filtered search: " . $json->encode($results->GetBody()) . "\n";

# /* Search with highlighting. */

$results = $client->Search($collection_name, {
    q => 'keyboard',
    query_by => 'title,content',
    highlight => 1,
    highlight_fields => ['title', 'content'],
    limit => 10
});

print "Search with highlighting: " . $json->encode($results->GetBody()) . "\n";

$client->Collections()->Delete($collection_name);
