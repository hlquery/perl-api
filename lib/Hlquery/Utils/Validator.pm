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

package Hlquery::Utils::Validator
{
     use strict;
     use warnings;
     use Hlquery::Exceptions;

     # /*
     #  * Hlquery::Utils::Validator - Internal validation utilities.
     #  */

     # /* Validates a collection name for URL safety and format. */

     sub ValidateCollectionName 
     {
          my ($name) = @_;
          
          unless (defined $name && length($name) > 0) 
          {
               die Hlquery::ValidationException->new("Collection name must be a non-empty string.");
          }
          
          if ($name =~ /[^a-zA-Z0-9_-]/) 
          {
               die Hlquery::ValidationException->new(
                    "Collection name contains invalid characters. " .
                    "Use only letters, numbers, underscores, and hyphens."
               );
          }
     }

     # /* Validates a document ID. */

     sub ValidateDocumentID 
     {
          my ($doc_id) = @_;
          
          unless (defined $doc_id && length($doc_id) > 0) 
          {
               die Hlquery::ValidationException->new("Document ID must be a non-empty string.");
          }
     }

     # /* Validates pagination parameters (offset and limit). */

     sub ValidatePagination 
     {
          my ($offset, $limit) = @_;
          
          unless (defined $offset && $offset =~ /^\d+$/ && $offset >= 0) 
          {
               die Hlquery::ValidationException->new("Offset must be a non-negative integer.");
          }
          
          unless (defined $limit && $limit =~ /^\d+$/ && $limit >= 1) 
          {
               die Hlquery::ValidationException->new("Limit must be a positive integer.");
          }
          
          if ($limit > 1000) 
          {
               die Hlquery::ValidationException->new("Limit cannot exceed 1000.");
          }
     }

     # /* Validates search parameters. */

     sub ValidateSearchParams 
     {
          my ($params) = @_;
          
          $params = {} unless $params;
          
          if (exists $params->{limit}) 
          {
               unless ($params->{limit} =~ /^\d+$/ && $params->{limit} >= 1) 
               {
                    die Hlquery::ValidationException->new("Limit must be a positive integer.");
               }
          }
          
          if (exists $params->{offset}) 
          {
               unless ($params->{offset} =~ /^\d+$/ && $params->{offset} >= 0) 
               {
                    die Hlquery::ValidationException->new("Offset must be a non-negative integer.");
               }
          }
          
          if (exists $params->{page}) 
          {
               unless ($params->{page} =~ /^\d+$/ && $params->{page} >= 1) 
               {
                    die Hlquery::ValidationException->new("Page must be a positive integer.");
               }
          }
     }

     # /* Validates document fields for restricted characters. */

     sub ValidateDocumentFields 
     {
          my ($document) = @_;
          
          return unless $document;
          
          return unless ref($document) eq 'HASH';
          
          while (my ($key, $value) = each %{$document}) 
          {
               next if $key eq 'id';
               
               if (defined $value && !ref($value) && $value =~ /,/) 
               {
                    die Hlquery::ValidationException->new(
                         "Field '$key' contains invalid character: comma (`,`). " .
                         "Commas are not allowed in field values. Use underscores (_) or spaces instead, or use arrays for multiple values."
                    );
               }
               
               if (ref($value) eq 'ARRAY') 
               {
                    foreach my $item (@{$value}) 
                    {
                         if (defined $item && !ref($item) && $item =~ /,/) 
                         {
                              die Hlquery::ValidationException->new(
                                   "Field '$key' contains invalid character: comma (`,`). " .
                                   "Array items cannot contain commas. Use underscores (_) or spaces instead."
                              );
                         }
                    }
               }
          }
     }

     1;
}

__END__

=head1 NAME

Hlquery::Utils::Validator - Internal validation utilities for hlquery

=head1 DESCRIPTION

This module provides internal validation functions for collection names,
document IDs, pagination parameters, and search parameters. It ensures
data integrity before making requests to the hlquery server.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
