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

package Hlquery::Response 
{
     use strict;
     use warnings;

     # /*
     #  * Hlquery::Response - Encapsulates an hlquery server response.
     #  *
     #  * This class provides methods to access the status code, body, and headers
     #  * of a response from the hlquery server.
     #  */

     # /* Constructor for the Response object. */

     sub new 
     {
          my ($class, $status_code, $body, $headers) = @_;

          my $self = bless 
          {
               status_code => $status_code,
               body        => $body,
               headers     => $headers || {}
          }, $class;

          return $self;
     }

     # /* Returns the HTTP status code. */

     sub GetStatusCode 
     {
          my $self = shift;

          return $self->{status_code};
     }

     # /* Returns the response body. */

     sub GetBody 
     {
          my $self = shift;

          return $self->{body};
     }

     # /* Returns the 'data' field of the response body. */

     sub GetData
     {
          my $self = shift;
          
          if (ref($self->{body}) eq 'HASH')
          {
               return $self->{body}->{data};
          }
          
          return undef;
     }

     # /* Returns all response headers. */

     sub GetHeaders 
     {
          my $self = shift;

          return $self->{headers};
     }

     # /* Returns a specific response header. */

     sub GetHeader
     {
          my ($self, $name) = @_;
          
          return $self->{headers}->{lc($name)};
     }

     # /* Checks if the request was successful (2xx). */

     sub IsSuccess 
     {
          my $self = shift;

          my $status = $self->{status_code};

          return $status >= 200 && $status < 300;
     }

     # /* Checks if the request resulted in an error (4xx or 5xx). */

     sub IsError 
     {
          my $self = shift;

          return $self->{status_code} >= 400;
     }

     # /* Extracts and returns the error message if present. */

     sub GetError 
     {
          my $self = shift;

          if ($self->IsError() && ref($self->{body}) eq 'HASH') 
          {
               return $self->{body}->{error} || $self->{body}->{message} || 'Unknown error.';
          }

          return undef;
     }

     # /* Converts the response to a hash for compatibility. */

     sub ToHash 
     {
          my $self = shift;

          return 
          {
               status => $self->{status_code},
               body   => $self->{body}
          };
     }

     1;
}

__END__

=head1 NAME

Hlquery::Response - Encapsulates an hlquery server response

=head1 DESCRIPTION

This object is returned by all API calls in C<Hlquery::Client>. It provides
methods to inspect the result of the request.

=head1 METHODS

=head2 GetStatusCode()

Returns the HTTP status code (e.g., 200, 404, 500).

=head2 GetBody()

Returns the decoded JSON body of the response (usually a hash reference or array reference).

=head2 GetData()

Returns the C<data> field from the response body, if present.

=head2 GetHeaders()

Returns a hash reference containing all response headers (lowercase keys).

=head2 IsSuccess()

Returns true if the status code indicates success (2xx).

=head2 IsError()

Returns true if the status code indicates an error (4xx or 5xx).

=head2 GetError()

Returns the error message from the server if the request failed.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
