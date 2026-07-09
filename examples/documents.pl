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
#  * Documents Examples - Demonstrates document CRUD operations.
#  */

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Hlquery::Client;
use JSON;

my $client = Hlquery::Client->new('http://localhost:9200');
my $collection_name = 'perl_docs_demo_' . time();

my $json = JSON->new->utf8->pretty;

$client->collections->create($collection_name, {
    fields => [
        { name => 'title', type => 'string' },
        { name => 'content', type => 'string' },
    ],
});

print "Documents example using '$collection_name'.\n";

# /* List documents. */

my $documents = $client->documents->list($collection_name, { offset => 0, limit => 10 });

print "Documents: " . $json->encode($documents->get_body) . "\n";

# /* Get document. */

if ($documents->is_success) 
{
    my $body = $documents->get_body;
    
    if (ref($body->{documents}) eq 'ARRAY' && @{$body->{documents}} > 0) 
    {
        my $doc_id = $body->{documents}->[0]->{id};
        
        if ($doc_id) 
        {
            my $document = $client->documents->get($collection_name, $doc_id);
            print "Document: " . $json->encode($document->get_body) . "\n";
        }
    }
}

# /* Add document. */

my $new_doc = {
    id => 'doc_1',
    title => 'Test Document',
    content => 'This is a test document'
};

my $result = $client->documents->add($collection_name, $new_doc);
print "Add result: " . $result->get_status_code . ".\n";

# /* Update document. */

my $updated_doc = {
    title => 'Updated Document',
    content => 'Updated content'
};

$result = $client->documents->update($collection_name, 'doc_1', $updated_doc);
print "Update result: " . $result->get_status_code . ".\n";

# /* Delete document. */

$result = $client->documents->delete($collection_name, 'doc_1');
print "Delete result: " . $result->get_status_code . ".\n";

$client->collections->delete($collection_name);
