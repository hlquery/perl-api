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
#  * Collections Examples - Demonstrates collection management operations.
#  */

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;
use JSON;

my $client = Hlquery::Client->new('http://localhost:9200');

# /* List collections. */

my $collections = $client->ListCollections(0, 10);
my $json = JSON->new->utf8->pretty;

print "Collections: " . $json->encode($collections->GetBody()) . "\n";

# /* Get collection details. */

if ($collections->IsSuccess()) 
{
    my $body = $collections->GetBody();
    
    if (ref($body->{collections}) eq 'ARRAY' && @{$body->{collections}} > 0) 
    {
        my $first_collection = $body->{collections}->[0];
        my $collection_name = ref($first_collection) eq 'HASH' && exists $first_collection->{name} 
            ? $first_collection->{name} 
            : $first_collection;
        
        # /* Get collection. */
        
        my $collection = $client->GetCollection($collection_name);
        print "Collection details: " . $json->encode($collection->GetBody()) . "\n";
        
        # /* Get formatted fields. */
        
        my $fields = $client->GetCollectionFields($collection_name);
        print "Collection fields: " . $json->encode($fields->GetBody()) . "\n";
    }
}
