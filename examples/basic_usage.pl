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

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;

# /* Initialize the hlquery client. */

my $client = Hlquery::Client->new('http://localhost:9200');

# /* Perform a health check. */

my $health = $client->health;

print "Health Status Code: " . $health->get_status_code . ".\n";

# /* List all collections with pagination. */

my $collections = $client->collections->list(0, 10);

if ($collections->is_success) 
{
     my $body = $collections->get_body;
     
     print "Found " . scalar(@{$body->{collections} || []}) . " collections.\n";
}
else 
{
     print "Failed to list collections: " . $collections->get_error . ".\n";
}
