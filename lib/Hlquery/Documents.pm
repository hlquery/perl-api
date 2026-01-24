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

package Hlquery::Documents
{
     use strict;
     use warnings;
     use URI::Escape;
     use Hlquery::Response;
     use Hlquery::Utils::Validator;

     # /*
     #  * Hlquery::Documents - Document management API.
     #  *
     #  * This class provides methods for adding, retrieving, updating, and deleting
     #  * documents within a collection.
     #  */

     # /* Constructor for the Documents handler. */

     sub new
     {
          my ($class, $request) = @_;

          my $self = bless 
          {
               request => $request
          }, $class;

          return $self;
     }

     # /* Lists documents in a collection. */

     sub List
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateSearchParams($params);
          
          my $offset = $params->{offset} || $params->{from} || 0;
          
          my $limit  = $params->{limit}  || $params->{size} || 10;
          
          return $self->{request}->Execute('GET', '/collections/' . uri_escape($collection_name) . '/documents', undef, 
          {
               offset => $offset,
               limit  => $limit
          });
     }

     # /* Returns a specific document. */

     sub Get
     {
          my ($self, $collection_name, $document_id) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateDocumentID($document_id);
          
          return $self->{request}->Execute('GET', '/collections/' . uri_escape($collection_name) . '/documents/' . uri_escape($document_id));
     }

     # /* Adds a new document to a collection. */

     sub Add
     {
          my ($self, $collection_name, $document) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateDocumentFields($document);
          
          return $self->{request}->Execute('POST', '/collections/' . uri_escape($collection_name) . '/documents', $document);
     }

     # /* Updates an existing document. */

     sub Update
     {
          my ($self, $collection_name, $document_id, $document) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateDocumentID($document_id);
          
          Hlquery::Utils::Validator::ValidateDocumentFields($document);
          
          return $self->{request}->Execute('PUT', '/collections/' . uri_escape($collection_name) . '/documents/' . uri_escape($document_id), $document);
     }

     # /* Deletes a document. */

     sub Delete
     {
          my ($self, $collection_name, $document_id) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateDocumentID($document_id);
          
          return $self->{request}->Execute('DELETE', '/collections/' . uri_escape($collection_name) . '/documents/' . uri_escape($document_id));
     }

     # /* Imports multiple documents in bulk. */

     sub ImportDocuments
     {
          my ($self, $collection_name, $documents) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          if (ref($documents) eq 'ARRAY') 
          {
               foreach my $doc (@{$documents}) 
               {
                    Hlquery::Utils::Validator::ValidateDocumentFields($doc);
               }
          }
          
          my $body = 
          {
               documents => $documents
          };
          
          return $self->{request}->Execute('POST', '/collections/' . uri_escape($collection_name) . '/documents/import', $body);
     }

     # /* Deletes documents matching a filter. */

     sub DeleteByFilter
     {
          my ($self, $collection_name, $filter) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          return $self->{request}->Execute('DELETE', '/collections/' . uri_escape($collection_name) . '/documents', undef, 
          {
               filter_by => $filter
          });
     }

     1;
}

__END__

=head1 NAME

Hlquery::Documents - Document management API for hlquery

=head1 DESCRIPTION

This module provides methods for managing documents within hlquery collections.
It is accessed via the C<Documents()> method of an L<Hlquery::Client> object.

=head1 METHODS

=head2 List($collection_name, $params)

Lists documents in a collection. C<$params> can include C<offset> and C<limit>.

=head2 Get($collection_name, $document_id)

Retrieves a specific document by its ID.

=head2 Add($collection_name, $document)

Adds a new document to the specified collection. C<$document> should be a hash reference.

=head2 Update($collection_name, $document_id, $document)

Updates an existing document.

=head2 Delete($collection_name, $document_id)

Deletes a document from the collection.

=head2 ImportDocuments($collection_name, $documents)

Imports an array reference of documents in bulk.

=head2 DeleteByFilter($collection_name, $filter)

Deletes documents that match the given filter string.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
