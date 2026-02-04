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

package Hlquery::Collections
{
     use strict;
     use warnings;
     use URI::Escape;
     use Hlquery::Response;
     use Hlquery::Utils::Validator;

     # /*
     #  * Hlquery::Collections - Collection management API.
     #  *
     #  * This class provides methods for creating, listing, and deleting collections.
     #  */

     # /* Constructor for the Collections handler. */

     sub new
     {
          my ($class, $request) = @_;

          my $self = bless 
          {
               request => $request
          }, $class;

          return $self;
     }

     # /* Lists all collections. */

     sub List
     {
          my ($self, $offset, $limit) = @_;

          $offset //= 0;
          
          $limit //= 10;
          
          Hlquery::Utils::Validator::ValidatePagination($offset, $limit);
          
          return $self->{request}->Execute('GET', '/collections', undef, 
          {
               offset => $offset,
               limit  => $limit
          });
     }

     # /* Returns details for a specific collection. */

     sub Get
     {
          my ($self, $name) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($name);
          
          return $self->{request}->Execute('GET', '/collections/' . uri_escape($name));
     }

     # /* Creates a new collection. */

     sub Create
     {
          my ($self, $name, $schema) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($name);
          
          my $body = 
          {
               name => $name
          };
          
          if ($schema && ref($schema) eq 'HASH') 
          {
               if (exists $schema->{fields} && ref($schema->{fields}) eq 'ARRAY') 
               {
                    $body->{fields} = $schema->{fields};
               } 
               elsif (exists $schema->{searchable_fields} && ref($schema->{searchable_fields}) eq 'ARRAY') 
               {
                    $body->{searchable_fields} = $schema->{searchable_fields};
               }
          } 
          elsif ($schema && ref($schema) eq 'ARRAY') 
          {
               $body->{fields} = $schema;
          }
          
          return $self->{request}->Execute('POST', '/collections', $body);
     }

     # /* Deletes a collection. */

     sub Delete
     {
          my ($self, $name) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($name);
          
          return $self->{request}->Execute('DELETE', '/collections/' . uri_escape($name));
     }

     # /* Updates an existing collection. */

     sub Update
     {
          my ($self, $name, $schema) = @_;
          
          Hlquery::Utils::Validator::ValidateCollectionName($name);
          
          return $self->{request}->Execute('POST', '/collections/' . uri_escape($name) . '/update', $schema);
     }

     # /* Returns formatted fields for a collection. */

     sub GetFields
     {
          my ($self, $name) = @_;
          
          my $response = $self->Get($name);
          
          if (ref($response) ne 'Hlquery::Response')
          {
               return $response; # Probably a promise
          }

          if ($response->GetStatusCode() != 200) 
          {
               return $response;
          }
          
          my $body = $response->GetBody();
          
          my @all_fields = ();
          
          my %field_types = ();
          
          if (ref($body) eq 'HASH' && exists $body->{searchable_fields} && ref($body->{searchable_fields}) eq 'ARRAY') 
          {
               foreach my $field (@{$body->{searchable_fields}}) 
               {
                    unless (grep { $_ eq $field } @all_fields) 
                    {
                         push @all_fields, $field;
                    }
                    
                    $field_types{$field} = [] unless exists $field_types{$field};
                    
                    push @{$field_types{$field}}, 'searchable';
               }
          }
          
          if (ref($body) eq 'HASH' && exists $body->{filterable_fields} && ref($body->{filterable_fields}) eq 'ARRAY') 
          {
               foreach my $field (@{$body->{filterable_fields}}) 
               {
                    unless (grep { $_ eq $field } @all_fields) 
                    {
                         push @all_fields, $field;
                    }
                    
                    $field_types{$field} = [] unless exists $field_types{$field};
                    
                    push @{$field_types{$field}}, 'filterable';
               }
          }
          
          if (ref($body) eq 'HASH' && exists $body->{sortable_fields} && ref($body->{sortable_fields}) eq 'ARRAY') 
          {
               foreach my $field (@{$body->{sortable_fields}}) 
               {
                    unless (grep { $_ eq $field } @all_fields) 
                    {
                         push @all_fields, $field;
                    }
                    
                    $field_types{$field} = [] unless exists $field_types{$field};
                    
                    push @{$field_types{$field}}, 'sortable';
               }
          }
          
          my @fields = ();
          
          foreach my $field (@all_fields) 
          {
               push @fields, 
               {
                    name => $field,
                    type => join(', ', @{$field_types{$field}})
               };
          }
          
          return Hlquery::Response->new(200, 
          {
               collection        => $name,
               fields            => \@fields,
               field_count       => scalar @fields,
               searchable_fields => (ref($body) eq 'HASH' && exists $body->{searchable_fields}) ? $body->{searchable_fields} : [],
               filterable_fields => (ref($body) eq 'HASH' && exists $body->{filterable_fields}) ? $body->{filterable_fields} : [],
               sortable_fields   => (ref($body) eq 'HASH' && exists $body->{sortable_fields})   ? $body->{sortable_fields}   : []
          });
     }

     1;
}

__END__

=head1 NAME

Hlquery::Collections - Collection management API for hlquery

=head1 DESCRIPTION

This module provides methods for managing collections in an hlquery server.
It is accessed via the C<Collections()> method of an L<Hlquery::Client> object.

=head1 METHODS

=head2 List($offset, $limit)

Lists all collections with pagination.

=head2 Get($name)

Returns details for a specific collection.

=head2 Create($name, $schema)

Creates a new collection with the given name and schema.

=head2 Delete($name)

Deletes the specified collection.

=head2 Update($name, $schema)

Updates the schema of an existing collection.

=head2 GetFields($name)

Returns a formatted list of all fields in a collection.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
