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

package Hlquery::Exceptions
{
     use strict;
     use warnings;

     # /*
     #  * Hlquery::Exceptions - Exception classes for the hlquery Perl API.
     #  */

     # /* Base exception class for all library errors. */

     package Hlquery::Exception 
     {
          sub new 
          {
               my ($class, $message) = @_;
               
               my $self = bless 
               {
                    message => $message
               }, $class;
               
               return $self;
          }

          sub Message 
          {
               my $self = shift;
               
               return $self->{message};
          }

          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     # /* Exception thrown for authentication-related failures. */

     package Hlquery::AuthenticationException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     # /* Exception thrown for failed HTTP requests. */

     package Hlquery::RequestException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;

          sub new 
          {
               my ($class, $message, $status_code, $response_body) = @_;
               
               my $self = $class->SUPER::new($message);
               
               $self->{status_code}   = $status_code || 0;
               
               $self->{response_body} = $response_body;
               
               return $self;
          }

          sub StatusCode 
          {
               my $self = shift;
               
               return $self->{status_code};
          }

          sub ResponseBody 
          {
               my $self = shift;
               
               return $self->{response_body};
          }
     }

     # /* Exception thrown for invalid input parameters. */

     package Hlquery::ValidationException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     # /* Exception thrown for collection-specific operation errors. */

     package Hlquery::CollectionException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     # /* Exception thrown for document-specific operation errors. */

     package Hlquery::DocumentException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     # /* Exception thrown for search-specific operation errors. */

     package Hlquery::SearchException 
     {
          use base 'Hlquery::Exception';
          
          use overload '""' => sub { $_[0]->{message} }, fallback => 1;
     }

     1;
}

__END__

=head1 NAME

Hlquery::Exceptions - Exception classes for the hlquery Perl API

=head1 DESCRIPTION

This module defines various exception classes used throughout the hlquery
Perl library for error handling.

=head1 CLASSES

=head2 Hlquery::Exception

Base class for all library exceptions.

=head2 Hlquery::AuthenticationException

Thrown when authentication fails or is misconfigured.

=head2 Hlquery::RequestException

Thrown when an HTTP request to the server fails.

=head2 Hlquery::ValidationException

Thrown when input parameters fail validation.

=head2 Hlquery::CollectionException

Thrown for errors related to collection management.

=head2 Hlquery::DocumentException

Thrown for errors related to document operations.

=head2 Hlquery::SearchException

Thrown for errors related to search operations.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
