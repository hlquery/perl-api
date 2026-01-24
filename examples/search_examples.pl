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

# /* Get a real collection name first. */

my $collections = $client->ListCollections(0, 1);
my $collection_name = undef;

if ($collections->IsSuccess()) 
{
    my $body = $collections->GetBody();
    
    if (ref($body->{collections}) eq 'ARRAY' && @{$body->{collections}} > 0) 
    {
        my $first = $body->{collections}->[0];
        $collection_name = ref($first) eq 'HASH' && exists $first->{name} ? $first->{name} : $first;
        print "Using collection: $collection_name\n\n";
    }
}

unless ($collection_name) 
{
    print "No collections found. Run collections_examples.pl first.\n";
    exit 0;
}

my $json = JSON->new->utf8->pretty;

# /* Simple search. */

my $results = $client->Search($collection_name, {
    q => 'test',
    query_by => 'title,content',
    limit => 10
});

print "Search results: " . $json->encode($results->GetBody()) . "\n";

# /* Search with filters and sorting. */

$results = $client->Search($collection_name, {
    q => 'test',
    query_by => 'title',
    sort_by => 'title',
    limit => 5
});

print "Filtered search: " . $json->encode($results->GetBody()) . "\n";

# /* Vector search. */

my $vector_query = [0.1, 0.2, 0.3, 0.4, 0.5];

$results = $client->VectorSearch($collection_name, {
    vector_query => $vector_query,
    limit => 5,
    threshold => 0.0
});

print "Vector search: " . $json->encode($results->GetBody()) . "\n";

# /* Multi-search. */

my $searches = [
    { collection => $collection_name, q => 'test', query_by => 'title' },
    { collection => $collection_name, q => 'test', query_by => 'content' }
];

$results = $client->SearchAPI()->MultiSearch($searches);

print "Multi-search: " . $json->encode($results->GetBody()) . "\n";

# /* Advanced query types. */

# /* Field-specific search. */

$results = $client->Search($collection_name, {
    q => 'title:laptop',
    query_by => 'title,content',
    limit => 10
});

print "Field search: " . $json->encode($results->GetBody()) . "\n";

# /* Range query. */

$results = $client->Search($collection_name, {
    q => 'price:[100 TO 500]',
    query_by => 'title,content',
    limit => 10
});

print "Range search: " . $json->encode($results->GetBody()) . "\n";

# /* Fuzzy search. */

$results = $client->Search($collection_name, {
    q => 'laptop~2',
    query_by => 'title,content',
    limit => 10
});

print "Fuzzy search: " . $json->encode($results->GetBody()) . "\n";

# /* Wildcard search. */

$results = $client->Search($collection_name, {
    q => 'laptop*',
    query_by => 'title,content',
    limit => 10
});

print "Wildcard search: " . $json->encode($results->GetBody()) . "\n";

# /* Boost query. */

$results = $client->Search($collection_name, {
    q => 'laptop^2.0 computer',
    query_by => 'title,content',
    limit => 10
});

print "Boost search: " . $json->encode($results->GetBody()) . "\n";

# /* NOT query. */

$results = $client->Search($collection_name, {
    q => '!apple',
    query_by => 'title,content',
    limit => 10
});

print "NOT search: " . $json->encode($results->GetBody()) . "\n";

# /* Combined query. */

$results = $client->Search($collection_name, {
    q => 'title:laptop AND price:[100 TO 500]',
    query_by => 'title,content',
    limit => 10
});

print "Combined search: " . $json->encode($results->GetBody()) . "\n";

# /* Search with highlighting. */

$results = $client->Search($collection_name, {
    q => 'test',
    query_by => 'title,content',
    highlight => 1,
    highlight_fields => ['title', 'content'],
    limit => 10
});

print "Search with highlighting: " . $json->encode($results->GetBody()) . "\n";
