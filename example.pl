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
use lib "$FindBin::Bin/lib";
use Hlquery::Client;
use JSON;
use URI::Escape;

# /* Configuration variables. */

my $BASE_URL        = $ENV{HLQUERY_URL} // 'http://localhost:9200';
my $COMMAND         = $ARGV[0] // 'all';
my $TEST_TOKEN      = undef;
my $OFFSET          = 0;
my $LIMIT           = 1000;
my $COLLECTION_NAME = undef;

# /* Parse command-line arguments. */

if ($COMMAND eq 'all' || $COMMAND eq 'cols' || $COMMAND eq 'docs' || 
    $COMMAND eq 'open' || $COMMAND eq 'status' || $COMMAND eq 'help') 
{
     if ($COMMAND eq 'cols' && @ARGV >= 2 && $ARGV[1] =~ /^\d+$/) 
     {
          $OFFSET = int($ARGV[1]);
          $LIMIT = int($ARGV[2]) if @ARGV >= 3 && $ARGV[2] =~ /^\d+$/;
          $TEST_TOKEN = $ARGV[3] if @ARGV >= 4;
     } 
     elsif ($COMMAND eq 'docs' && @ARGV >= 2) 
     {
          $COLLECTION_NAME = $ARGV[1];
          $TEST_TOKEN = $ARGV[2] if @ARGV >= 3;
     } 
     else 
     {
          for my $i (1..$#ARGV) 
          {
               if ($ARGV[$i] !~ /^\d+$/) 
               {
                    $TEST_TOKEN = $ARGV[$i];
                    last;
               }
          }
     }
} 
else 
{
     $TEST_TOKEN = $ARGV[0];
     $COMMAND = 'all';
}

# /* Display help information. */

if ($COMMAND eq 'help') 
{
     print "=== hlquery Perl API Example ===\n\n";
     print "Usage: perl example.pl [command] [offset] [limit] [token]\n\n";
     print "Commands:\n";
     print "  cols   - Run collections API examples\n";
     print "  docs   - Run documents API examples\n";
     print "  open   - List and open collections (interactive)\n";
     print "  status - Show server health and status information\n";
     print "  help   - Show this help message\n";
     print "  all    - Run all examples (default)\n\n";
     exit 0;
}

print "=== hlquery Perl API Example ===\n";
print "Command: $COMMAND\n\n";

# /* Helper function to display test results. */

sub print_result 
{
     my ($title, $response, $print_body) = @_;
     $print_body = 1 unless defined $print_body;
     
     print "=" x 70 . "\n";
     print "TEST: $title\n";
     print "-" x 70 . "\n";
     
     if (ref($response) && $response->isa('Hlquery::Response')) 
     {
          my $status = $response->GetStatusCode();
          my $body = $response->GetBody();
          
          print "Status Code: $status\n";
          
          if ($print_body && $body) 
          {
               print "Response Body:\n";
               my $json = JSON->new->utf8->pretty;
               if (ref($body) eq 'HASH' || ref($body) eq 'ARRAY') 
               {
                    print $json->encode($body) . "\n";
               } 
               else 
               {
                    print "$body\n";
               }
          }
          
          if ($response->IsSuccess()) 
          {
               print "✓ SUCCESS\n";
          } 
          else 
          {
               print "✗ FAILED: " . ($response->GetError() // 'Unknown error') . "\n";
          }
     } 
     else 
     {
          print "Invalid response type.\n";
     }
     print "\n";
}

# /* Helper function to retrieve the first available collection. */

sub get_first_collection 
{
     my ($client) = @_;
     my $collections = $client->ListCollections(0, 1);
     
     if ($collections->IsSuccess()) 
     {
          my $body = $collections->GetBody();
          
          if (ref($body) eq 'HASH' && exists $body->{collections} && ref($body->{collections}) eq 'ARRAY' && @{$body->{collections}} > 0) 
          {
               my $first = $body->{collections}->[0];
               return ref($first) eq 'HASH' && exists $first->{name} ? $first->{name} : $first;
          }
     }
     return undef;
}

# /* Instantiate the hlquery client. */

my $client = Hlquery::Client->new($BASE_URL);

if ($TEST_TOKEN) 
{
     $client->SetAuthToken($TEST_TOKEN, 'bearer');
     print "Using authentication token: " . substr($TEST_TOKEN, 0, 8) . "...\n\n";
}

# /* Server status commands. */

if ($COMMAND eq 'status') 
{
     print "\n" . "#" x 70 . "\n";
     print "# SERVER STATUS\n";
     print "#" x 70 . "\n\n";
     
     eval 
     {
          print_result("GET /health", $client->Health());
          print_result("GET /stats", $client->Stats());
          print_result("GET /status", $client->ExecuteRequest('GET', '/status'));
          
          my $info = $client->Info();
          print "=" x 70 . "\n";
          print "TEST: GET / (Root Info)\n";
          print "-" x 70 . "\n";
          
          if (ref($info) && $info->isa('Hlquery::Response')) 
          {
               my $status_code = $info->GetStatusCode();
               my $body = $info->GetBody();
               print "Status Code: $status_code\n";
               
               if ($info->IsSuccess() && ref($body) eq 'HASH') 
               {
                    print "Name: " . ($body->{name} || 'N/A') . "\n";
                    print "Version: " . ($body->{version} || 'N/A') . "\n";
                    print "✓ SUCCESS\n";
               }
          }
     };
     if ($@) 
     {
          print "Error getting status: $@\n\n";
     }
     exit 0;
}

# /* Full API testing suite. */

if ($COMMAND eq 'all') 
{
     print "\n" . "#" x 70 . "\n";
     print "# System APIs\n";
     print "#" x 70 . "\n\n";

     eval 
     {
          print_result("GET /health", $client->Health());
          print_result("GET /stats", $client->Stats());
          print_result("GET /metrics", $client->ExecuteRequest('GET', '/metrics'));
          print_result("GET /status", $client->ExecuteRequest('GET', '/status'));
          print_result("GET / (Root)", $client->Info());
     };
}

# /* Collections API tests. */

if ($COMMAND eq 'all' || $COMMAND eq 'cols' || $COMMAND eq 'open') 
{
     print "\n" . "#" x 70 . "\n";
     print "# COLLECTIONS API\n";
     print "#" x 70 . "\n\n";

     eval 
     {
          my $collections = $client->ListCollections($OFFSET, $LIMIT);
          
          if ($COMMAND eq 'cols') 
          {
               if ($collections->IsSuccess()) 
               {
                    my $body = $collections->GetBody();
                    if (ref($body) eq 'HASH' && exists $body->{collections}) 
                    {
                         my @cols = @{$body->{collections}};
                         print "Collections:\n\n";
                         foreach my $col (@cols) 
                         {
                              my $name = ref($col) eq 'HASH' && exists $col->{name} ? $col->{name} : $col;
                              print "  $name\n";
                         }
                    }
               }
          } 
          else 
          {
               print_result("GET /collections (List)", $collections);
               
               my $first_collection = get_first_collection($client);
               
               if ($first_collection && $COMMAND eq 'all') 
               {
                    print_result("GET /collections/{name}", $client->GetCollection($first_collection));
                    print_result("GET /collections/{name}/fields", $client->GetCollectionFields($first_collection));
                    
                    my $test_col = 'test_col_' . time();
                    my $create_result = $client->Collections()->Create($test_col, { fields => [{ name => 'title', type => 'string' }] });
                    print_result("POST /collections (Create)", $create_result);
                    
                    if ($create_result->IsSuccess()) 
                    {
                         $client->Collections()->Delete($test_col);
                    }
               }
          }
     };
}

# /* Documents API tests. */

if ($COMMAND eq 'all' || $COMMAND eq 'docs' || $COMMAND eq 'open') 
{
     print "\n" . "#" x 70 . "\n";
     print "# DOCUMENTS API\n";
     print "#" x 70 . "\n\n";

     my $test_collection = $COLLECTION_NAME || get_first_collection($client);
     
     if ($test_collection) 
     {
          eval 
          {
               my $documents = $client->ListDocuments($test_collection, { limit => $LIMIT });
               
               if ($COMMAND eq 'docs') 
               {
                    if ($documents->IsSuccess()) 
                    {
                         my $body = $documents->GetBody();
                         if (ref($body) eq 'HASH' && exists $body->{documents}) 
                         {
                              foreach my $doc (@{$body->{documents}}) 
                              {
                                   my $doc_id = ref($doc) eq 'HASH' && exists $doc->{id} ? $doc->{id} : $doc;
                                   print "  $doc_id\n";
                              }
                         }
                    }
               } 
               else 
               {
                    print_result("GET /collections/{name}/documents", $documents);
                    
                    my $new_doc = { id => 'test_' . time(), title => 'Test' };
                    print_result("POST /documents (Add)", $client->Documents()->Add($test_collection, $new_doc));
                    $client->Documents()->Delete($test_collection, $new_doc->{id});
               }
          };
     }
}

# /* Search API tests. */

if ($COMMAND eq 'all') 
{
     print "\n" . "#" x 70 . "\n";
     print "# SEARCH API\n";
     print "#" x 70 . "\n\n";

     my $search_col = get_first_collection($client);
     if ($search_col) 
     {
          eval 
          {
               print_result("Search", $client->Search($search_col, { q => 'test', limit => 5 }));
          };
     }
}

print "\nTesting complete.\n";
