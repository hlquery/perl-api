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

package Hlquery::Search
{
     use strict;
     use warnings;
     use URI::Escape;
     use JSON;
     use Hlquery::Utils::Validator;

     # /*
     #  * Hlquery::Search - Search API for hlquery.
     #  *
     #  * This class provides methods for performing full-text, faceted, and vector searches.
     #  */

     # /* Constructor for the Search handler. */

     sub new
     {
          my ($class, $request, $collections) = @_;

          my $self = bless 
          {
               request     => $request,
               collections => $collections,
               json        => JSON->new->utf8->allow_nonref
          }, $class;

          return $self;
     }

     # /* Performs a search operation in a collection. */

     sub Search
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          Hlquery::Utils::Validator::ValidateSearchParams($params);
          
          my %query_params = ();
          
          if (ref($params) eq 'HASH' && exists $params->{query} && ref($params->{query}) eq 'HASH') 
          {
               if (exists $params->{query}->{q}) 
               {
                    $query_params{q} = $params->{query}->{q};
               }
               
               if (exists $params->{query}->{query_by}) 
               {
                    my $query_by = $params->{query}->{query_by};
                    
                    $query_params{query_by} = (ref($query_by) eq 'ARRAY') ? join(',', @$query_by) : $query_by;
               }
          }
          
          if (exists $params->{q}) 
          {
               $query_params{q} = $params->{q};
          }
          
          if (exists $params->{query_by}) 
          {
               my $query_by = $params->{query_by};
               
               $query_params{query_by} = (ref($query_by) eq 'ARRAY') ? join(',', @$query_by) : $query_by;
          } 
          elsif (exists $params->{q} && $params->{q} ne '') 
          {
               my $collection = $self->{collections}->Get($collection_name);
               
               if (ref($collection) eq 'Hlquery::Response' && $collection->GetStatusCode() == 200) 
               {
                    my $body = $collection->GetBody();
                    
                    if (ref($body) eq 'HASH' && exists $body->{searchable_fields} && ref($body->{searchable_fields}) eq 'ARRAY' && @{$body->{searchable_fields}} > 0) 
                    {
                         $query_params{query_by} = join(',', @{$body->{searchable_fields}});
                    }
               }
          }
          
          if (exists $params->{from}) 
          {
               $query_params{offset} = $params->{from};
          } 
          elsif (exists $params->{offset}) 
          {
               $query_params{offset} = $params->{offset};
          }
          
          if (exists $params->{size}) 
          {
               $query_params{limit} = $params->{size};
          } 
          elsif (exists $params->{limit}) 
          {
               $query_params{limit} = $params->{limit};
          }
          
          if (exists $params->{page}) 
          {
               $query_params{page} = $params->{page};
          }
          
          if (exists $params->{per_page}) 
          {
               $query_params{per_page} = $params->{per_page};
          }
          
          if (exists $params->{filter_by}) 
          {
               $query_params{filter_by} = $params->{filter_by};
          } 
          elsif (exists $params->{filter}) 
          {
               my $filter = $params->{filter};
               
               $query_params{filter_by} = (ref($filter) eq 'HASH' || ref($filter) eq 'ARRAY') ? $self->{json}->encode($filter) : $filter;
          }
          
          if (exists $params->{sort}) 
          {
               my $sort = $params->{sort};
               
               if (ref($sort) eq 'ARRAY') 
               {
                    my @sort_fields = ();
                    
                    foreach my $sort_item (@$sort) 
                    {
                         if (ref($sort_item) eq 'HASH') 
                         {
                              foreach my $field (keys %$sort_item) 
                              {
                                   push @sort_fields, ($sort_item->{$field} eq 'desc') ? "-$field" : $field;
                              }
                         } 
                         else 
                         {
                              push @sort_fields, $sort_item;
                         }
                    }
                    
                    $query_params{sort_by} = join(',', @sort_fields);
               } 
               else 
               {
                    $query_params{sort_by} = $sort;
               }
          } 
          elsif (exists $params->{sort_by}) 
          {
               my $sort_by = $params->{sort_by};
               
               $query_params{sort_by} = (ref($sort_by) eq 'ARRAY') ? join(',', @$sort_by) : $sort_by;
          }
          
          if (exists $params->{facet_by}) 
          {
               my $facet_by = $params->{facet_by};
               
               $query_params{facet_by} = (ref($facet_by) eq 'ARRAY') ? join(',', @$facet_by) : $facet_by;
          } 
          elsif (exists $params->{facets}) 
          {
               my $facets = $params->{facets};
               
               $query_params{facet_by} = (ref($facets) eq 'ARRAY') ? join(',', @$facets) : $facets;
          }
          
          if (exists $params->{typo_tolerance}) 
          {
               $query_params{typo_tolerance} = $params->{typo_tolerance};
          }
          
          if (exists $params->{num_typos}) 
          {
               $query_params{num_typos} = $params->{num_typos};
          }
          
          if (exists $params->{highlight}) 
          {
               my $highlight = $params->{highlight};
               
               $query_params{highlight} = ($highlight eq 'true' || $highlight eq 'True' || $highlight == 1 || $highlight) ? 'true' : 'false';
          }
          
          if (exists $params->{highlight_fields}) 
          {
               my $highlight_fields = $params->{highlight_fields};
               
               $query_params{highlight_fields} = (ref($highlight_fields) eq 'ARRAY') ? join(',', @$highlight_fields) : $highlight_fields;
          }
          
          if (exists $params->{highlight_full_fields}) 
          {
               my $highlight = $params->{highlight_full_fields};
               
               $query_params{highlight_full_fields} = (ref($highlight) eq 'ARRAY') ? join(',', @$highlight) : $highlight;
          }
          
          my $method = (exists $params->{body}) ? 'POST' : 'GET';
          
          my $body = exists $params->{body} ? $params->{body} : undef;
          
          return $self->{request}->Execute($method, '/collections/' . uri_escape($collection_name) . '/documents/search', $body, \%query_params);
     }

     # /* Performs multiple search operations in a single request. */

     sub MultiSearch
     {
          my ($self, $searches) = @_;
          
          return $self->{request}->Execute('POST', '/multi_search', { searches => $searches });
     }

     # /* Performs a vector-based search operation. */

     sub VectorSearch
     {
          my ($self, $collection_name, $params) = @_;
          
          $params = {} unless $params;
          
          Hlquery::Utils::Validator::ValidateCollectionName($collection_name);
          
          my %query_params = ();
          
          if (exists $params->{vector_query}) 
          {
               my $vector_query = $params->{vector_query};
               
               $query_params{vector_query} = (ref($vector_query) eq 'ARRAY') ? $self->{json}->encode($vector_query) : $vector_query;
          } 
          elsif (exists $params->{embedding}) 
          {
               my $embedding = $params->{embedding};
               
               $query_params{vector_query} = (ref($embedding) eq 'ARRAY') ? $self->{json}->encode($embedding) : $embedding;
          }
          
          if (exists $params->{field_name}) 
          {
               $query_params{field_name} = $params->{field_name};
          }
          
          if (exists $params->{limit}) 
          {
               $query_params{limit} = $params->{limit};
          }
          
          if (exists $params->{threshold}) 
          {
               $query_params{threshold} = $params->{threshold};
          }
          
          if (exists $params->{normalize}) 
          {
               $query_params{normalize} = $params->{normalize} ? 'true' : 'false';
          }
          
          my $path = '/collections/' . uri_escape($collection_name) . '/vector_search';
          
          my $method = (exists $params->{body}) ? 'POST' : 'GET';
          
          my $body = exists $params->{body} ? $params->{body} : undef;
          
          return $self->{request}->Execute($method, $path, $body, \%query_params);
     }

     1;
}

__END__

=head1 NAME

Hlquery::Search - Search API for hlquery

=head1 DESCRIPTION

This module provides methods for performing various search operations in hlquery.
It is accessed via the C<SearchAPI()> method of an L<Hlquery::Client> object.

=head1 METHODS

=head2 Search($collection_name, $params)

Performs a full-text search in the specified collection. C<$params> is a hash reference
that can contain many options like C<q>, C<query_by>, C<filter_by>, C<sort_by>, etc.

=head2 MultiSearch($searches)

Performs multiple search operations in a single request. C<$searches> should be
an array reference of search parameters.

=head2 VectorSearch($collection_name, $params)

Performs a vector similarity search. C<$params> should contain C<vector_query> (or C<embedding>)
and C<field_name>.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
