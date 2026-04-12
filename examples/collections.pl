#!/usr/bin/env perl
# /*
#  * hlquery - Search beyond keywords.
#  * https://www.hlquery.com
#  *
#  * Copyright (C) 2021-2026, Carlos F. Ferry <carlos.ferry@gmail.com>
#  *
#  * This file is part of hlquery, released under the BSD License version 3.
#  * You are free to redistribute and/or modify this software
#  * under the terms of the BSD License.
#  * For more details, please visit: https://docs.hlquery.com
#  */

# /*
#  * Collections Examples - Demonstrates collection management operations.
#  */

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;
use JSON;

my $client = Hlquery::Client->new('http://localhost:9200');
my $collection_name = 'perl_collections_demo_' . time();
my $json = JSON->new->utf8->pretty;

print "Collections example using '$collection_name'.\n";

# /* List collections. */

my $collections = $client->ListCollections(0, 10);
print "Collections: " . $json->encode($collections->GetBody()) . "\n";

# /* Create a collection. */

my $create = $client->Collections()->Create($collection_name, {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'price', type => 'float' },
    ],
});

print "Create result: " . $create->GetStatusCode() . ".\n";

# /* Get collection details. */

my $collection = $client->GetCollection($collection_name);
print "Collection details: " . $json->encode($collection->GetBody()) . "\n";

# /* Get formatted fields. */

my $fields = $client->GetCollectionFields($collection_name);
print "Collection fields: " . $json->encode($fields->GetBody()) . "\n";

# /* Update collection. */

my $update = $client->UpdateCollection($collection_name, {
    fields => [
        { name => 'description', type => 'string' },
    ],
});

print "Update result: " . $update->GetStatusCode() . ".\n";

# /* Delete collection. */

my $delete = $client->Collections()->Delete($collection_name);
print "Delete result: " . $delete->GetStatusCode() . ".\n";
