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
#  * Flush Example - Demonstrates the flush operation:
#  * 1. Create a fake collection
#  * 2. Create a fake document
#  * 3. Check collection count
#  * 4. Flush all data
#  * 5. Re-check collection count (should be 0)
#  */

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;
use JSON;

my $client = Hlquery::Client->new('http://localhost:9200');
my $json = JSON->new->utf8->pretty;

print "=" x 70 . "\n";
print "FLUSH EXAMPLE\n";
print "=" x 70 . "\n\n";

# /* Step 1: Create a fake collection. */

print "Step 1: Creating a fake collection...\n";
my $collection_name = 'flush_test_collection_' . time();

my $schema = {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'content', type => 'string' },
        { name => 'value', type => 'int' }
    ]
};

my $create_result = $client->Collections()->Create($collection_name, $schema);

if ($create_result->IsSuccess()) 
{
    print "  ✓ Collection '$collection_name' created successfully\n";
} 
else 
{
    print "  ✗ Failed to create collection: " . $create_result->GetStatusCode() . "\n";
    my $error_body = $create_result->GetBody();
    
    if ($error_body) 
    {
        print "  Error: " . $json->encode($error_body) . "\n";
    }
    exit(1);
}

print "\n";

# /* Step 2: Create a fake document. */

print "Step 2: Creating a fake document...\n";
my $doc = {
    id => 'flush_test_doc_' . time(),
    title => 'Flush Test Document',
    content => 'This is a test document for flush example',
    value => 42
};

my $add_result = $client->Documents()->Add($collection_name, $doc);

if ($add_result->IsSuccess()) 
{
    print "  ✓ Document '$doc->{id}' added successfully\n";
} 
else 
{
    print "  ✗ Failed to add document: " . $add_result->GetStatusCode() . "\n";
    my $error_body = $add_result->GetBody();
    
    if ($error_body) 
    {
        print "  Error: " . $json->encode($error_body) . "\n";
    }
}

print "\n";

# /* Step 3: Check collection count before flush. */

print "Step 3: Checking collection count before flush...\n";
my $collections_before = $client->ListCollections(0, 1000);
my $count_before = 0;

if ($collections_before->IsSuccess()) 
{
    my $body = $collections_before->GetBody();
    my $collections_list = ref($body->{collections}) eq 'ARRAY' ? $body->{collections} : [];
    $count_before = scalar(@$collections_list);
    print "  Collections before flush: $count_before\n";
    
    if ($count_before == 0) 
    {
        print "  ⚠ Warning: No collections found before flush\n";
    }
} 
else 
{
    print "  ✗ Failed to list collections: " . $collections_before->GetStatusCode() . "\n";
}

print "\n";

# /* Step 4: Flush all data. */

print "Step 4: Flushing all data...\n";
my $flush_result = $client->Flush();

if ($flush_result->IsSuccess()) 
{
    my $body = $flush_result->GetBody();
    my $collections_deleted = $body->{collections_deleted} // 0;
    print "  ✓ Flush completed successfully\n";
    print "  Collections deleted: $collections_deleted\n";
    my $message = $body->{message} // 'N/A';
    print "  Message: $message\n";
} 
else 
{
    print "  ✗ Flush failed: " . $flush_result->GetStatusCode() . "\n";
    my $error_body = $flush_result->GetBody();
    
    if ($error_body) 
    {
        print "  Error: " . $json->encode($error_body) . "\n";
    }
    exit(1);
}

print "\n";

# /* Step 5: Re-check collection count after flush. */

print "Step 5: Checking collection count after flush...\n";
my $collections_after = $client->ListCollections(0, 1000);
my $count_after = -1;

if ($collections_after->IsSuccess()) 
{
    my $body = $collections_after->GetBody();
    my $collections_list = ref($body->{collections}) eq 'ARRAY' ? $body->{collections} : [];
    $count_after = scalar(@$collections_list);
    print "  Collections after flush: $count_after\n";
    
    if ($count_after == 0) 
    {
        print "  ✓ SUCCESS: All collections have been flushed\n";
    } 
    else 
    {
        print "  ⚠ Warning: Expected 0 collections, but found $count_after\n";
    }
} 
else 
{
    print "  ✗ Failed to list collections: " . $collections_after->GetStatusCode() . "\n";
}

print "\n";
print "=" x 70 . "\n";
print "FLUSH EXAMPLE COMPLETED\n";
print "=" x 70 . "\n";
print "Summary:\n";
print "  Collections before flush: $count_before\n";
print "  Collections after flush: $count_after\n";
print "\n";
