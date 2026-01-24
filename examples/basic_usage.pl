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

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;

# /* Initialize the hlquery client. */

my $client = Hlquery::Client->new('http://localhost:9200');

# /* Perform a health check. */

my $health = $client->Health();

print "Health Status Code: " . $health->GetStatusCode() . ".\n";

# /* List all collections with pagination. */

my $collections = $client->ListCollections(0, 10);

if ($collections->IsSuccess()) 
{
     my $body = $collections->GetBody();
     
     print "Found " . scalar(@{$body->{collections} || []}) . " collections.\n";
}
else 
{
     print "Failed to list collections: " . $collections->GetError() . ".\n";
}
