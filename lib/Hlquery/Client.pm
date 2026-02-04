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

package Hlquery::Client
{
     use strict;
     use warnings;
     use Hlquery::Request;
     use Hlquery::Collections;
     use Hlquery::Documents;
     use Hlquery::Search;
     use Hlquery::Utils::Config;

     # /*
     #  * Hlquery::Client - Main entry point for the hlquery Perl API.
     #  *
     #  * This class provides high-level methods for interacting with an hlquery server.
     #  */

     # /* Constructor for the main Client class. */

     sub new 
     {
          my ($class, $base_url, $options) = @_;
          
          $options = {} unless $options;

          $options = Hlquery::Utils::Config::merge_defaults($options);

          $base_url = $base_url || $options->{base_url} || 'http://localhost:9200';
          
          $base_url = Hlquery::Utils::Config::normalize_url($base_url);

          unless (Hlquery::Utils::Config::is_valid_url($base_url)) 
          {
               die "Invalid base URL: $base_url.";
          }

          my $request = Hlquery::Request->new(
               $base_url,
               $options->{timeout},
               $options->{token},
               $options->{auth_method} || 'bearer',
               $options->{pool},
               $options->{lazy}
          );

          my $collections = Hlquery::Collections->new($request);
          
          my $documents   = Hlquery::Documents->new($request);
          
          my $search      = Hlquery::Search->new($request, $collections);

          my $self = bless 
          {
               request     => $request,
               collections => $collections,
               documents   => $documents,
               search      => $search
          }, $class;

          return $self;
     }

     # /* Sets the authentication token dynamically. */

     sub SetAuthToken 
     {
          my ($self, $token, $method) = @_;
          
          $self->{request}->SetAuthToken($token, $method || 'bearer');
          
          return $self;
     }

     # /* Clears authentication information. */

     sub ClearAuth 
     {
          my $self = shift;
          
          $self->{request}->ClearAuth();
          
          return $self;
     }

     # /* Returns server health status. */

     sub Health 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/health');
     }

     # /* Returns server statistics. */

     sub Stats 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/stats');
     }

     # /* Returns server etc info. */

     sub Etc 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/etc');
     }

     # /* Returns server information. */

     sub Info 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/');
     }

     # /* Flushes all data to disk. */

     sub Flush 
     {
          my $self = shift;
          
          return $self->{request}->Execute('POST', '/flush');
     }

     # /* Returns cluster health status. */

     sub ClusterHealth 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/cluster/health');
     }

     # /* Returns cluster statistics. */

     sub ClusterStats 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/cluster/stats');
     }

     # /* Returns cluster nodes information. */

     sub ClusterNodes 
     {
          my $self = shift;
          
          return $self->{request}->Execute('GET', '/cluster/nodes');
     }

     # /* Returns the collections API object. */

     sub Collections 
     {
          my $self = shift;
          
          return $self->{collections};
     }

     # /* Lists all collections with pagination. */

     sub ListCollections 
     {
          my ($self, $offset, $limit) = @_;
          
          $offset //= 0;
          
          $limit //= 10;
          
          return $self->{collections}->List($offset, $limit);
     }

     # /* Returns details for a specific collection. */

     sub GetCollection 
     {
          my ($self, $name) = @_;
          
          return $self->{collections}->Get($name);
     }

     # /* Returns fields for a specific collection. */

     sub GetCollectionFields 
     {
          my ($self, $name) = @_;
          
          return $self->{collections}->GetFields($name);
     }

     # /* Returns the documents API object. */

     sub Documents 
     {
          my $self = shift;
          
          return $self->{documents};
     }

     # /* Lists documents in a collection. */

     sub ListDocuments 
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          return $self->{documents}->List($collection_name, $params);
     }

     # /* Returns a specific document. */

     sub GetDocument 
     {
          my ($self, $collection_name, $document_id) = @_;
          
          return $self->{documents}->Get($collection_name, $document_id);
     }

     # /* Returns the search API object. */

     sub SearchAPI 
     {
          my $self = shift;
          
          return $self->{search};
     }

     # /* Performs a search operation. */

     sub Search 
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          return $self->{search}->Search($collection_name, $params);
     }

     # /* Performs a vector search operation. */

     sub VectorSearch 
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          return $self->{search}->VectorSearch($collection_name, $params);
     }

     # /* Executes an arbitrary request. */

     sub ExecuteRequest 
     {
          my ($self, $method, $path, $body, $query_params) = @_;
          
          return $self->{request}->Execute($method, $path, $body, $query_params);
     }

     # /* Elasticsearch-compatible alias for listing collections. */

     sub Indices 
     {
          my ($self, $params) = @_;
          
          $params = {} unless $params;
          
          return $self->ListCollections(
               $params->{offset} || 0,
               $params->{limit} || 10
          );
     }

     # /* Elasticsearch-compatible alias for getting a collection or document. */

     sub Get 
     {
          my ($self, $params) = @_;
          
          if (exists $params->{index} && exists $params->{id}) 
          {
               return $self->GetDocument($params->{index}, $params->{id});
          } 
          elsif (exists $params->{index}) 
          {
               return $self->GetCollection($params->{index});
          }
          
          die "Invalid parameters for Get().";
     }

     # /* Elasticsearch-compatible Cat API alias. */

     sub Cat 
     {
          my ($self, $cat_type, $params) = @_;
          
          $cat_type = $cat_type || 'indices';
          
          $params = {} unless $params;
          
          if ($cat_type eq 'indices') 
          {
               return $self->Indices($params);
          }
          
          die "Unsupported cat type: $cat_type.";
     }

     1;
}

__END__

=head1 NAME

Hlquery::Client - Main entry point for the hlquery Perl API

=head1 SYNOPSIS

    use Hlquery::Client;

    my $client = Hlquery::Client->new('http://localhost:9200');
    
    # Check server health
    my $res = $client->Health();
    print "Server is healthy\n" if $res->IsSuccess();

    # Search documents
    my $search_res = $client->Search('products', { q => 'laptop' });
    print "Found " . $search_res->GetBody()->{found} . " documents\n";

=head1 DESCRIPTION

C<Hlquery::Client> provides a high-level interface for interacting with an hlquery search server.
It organizes functionality into sub-objects for collections, documents, and search operations.

=head1 METHODS

=head2 new($base_url, $options)

Creates a new hlquery client instance.

=head2 SetAuthToken($token, $method)

Sets the authentication token dynamically. C<$method> can be 'bearer' or 'api-key'.

=head2 Health()

Returns the server health status.

=head2 Stats()

Returns server statistics.

=head2 Search($collection, $params)

Performs a search operation in the specified collection.

=head2 Collections()

Returns the L<Hlquery::Collections> API object.

=head2 Documents()

Returns the L<Hlquery::Documents> API object.

=head2 SearchAPI()

Returns the L<Hlquery::Search> API object.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
