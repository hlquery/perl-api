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

package Hlquery::Request
{
     use strict;
     use warnings;
     use LWP::UserAgent;
     use HTTP::Request;
     use JSON;
     use URI;
     use URI::Escape;

     use Hlquery::Response;
     use Hlquery::Exceptions;

     # /*
     #  * Hlquery::Request - Internal HTTP request handler.
     #  *
     #  * Handles the low-level communication with the hlquery server.
     #  */

     # /* Constructor for the Request handler. */

     sub new
     {
          my ($class, $base_url, $timeout, $auth_token, $auth_method) = @_;

          $base_url =~ s/\/$//;
          
          $timeout //= 30;
          
          $auth_method //= 'bearer';

          my $ua = LWP::UserAgent->new;
          
          $ua->timeout($timeout);
          
          $ua->agent("hlquery-perl-client/$Hlquery::VERSION");

          my $self = bless 
          {
               base_url    => $base_url,
               timeout     => $timeout,
               auth_token  => $auth_token,
               auth_method => $auth_method,
               ua          => $ua,
               json        => JSON->new->utf8->allow_nonref
          }, $class;

          return $self;
     }

     # /* Sets the authentication token. */

     sub SetAuthToken
     {
          my ($self, $token, $method) = @_;

          $self->{auth_token}  = $token;
          
          $self->{auth_method} = $method // 'bearer';
     }

     # /* Clears authentication information. */

     sub ClearAuth
     {
          my $self = shift;

          $self->{auth_token} = undef;
     }

     # /* Executes an HTTP request. */

     sub Execute
     {
          my ($self, $method, $path, $body, $query_params) = @_;

          my $url = $self->{base_url} . $path;

          if ($query_params && ref($query_params) eq 'HASH' && keys %$query_params) 
          {
               my $uri = URI->new($url);
               
               foreach my $key (sort keys %$query_params) 
               {
                    $uri->query_param($key => $query_params->{$key});
               }
               
               $url = $uri->as_string;
          }

          my $request = HTTP::Request->new($method => $url);
          
          $request->header('Content-Type' => 'application/json');
          
          $request->header('Accept'       => 'application/json');

          if ($self->{auth_token}) 
          {
               if ($self->{auth_method} eq 'api-key') 
               {
                    $request->header('X-API-Key' => $self->{auth_token});
               } 
               else 
               {
                    $request->header('Authorization' => 'Bearer ' . $self->{auth_token});
               }
          }

          if (defined $body) 
          {
               my $body_str;
               
               if (ref($body) eq 'HASH' || ref($body) eq 'ARRAY') 
               {
                    $body_str = $self->{json}->encode($body);
               } 
               else 
               {
                    $body_str = $body;
               }
               
               $request->content($body_str);
          }

          my $response = $self->{ua}->request($request);
          
          my $status_code = $response->code;
          
          my $response_body = $response->decoded_content // $response->content;

          my %response_headers;
          
          foreach my $header ($response->header_field_names) 
          {
               $response_headers{lc($header)} = $response->header($header);
          }

          my $decoded;
          
          if ($response_body) 
          {
               eval 
               {
                    $decoded = $self->{json}->decode($response_body);
               };
               
               if ($@) 
               {
                    $decoded = $response_body;
               }
          }

          # /* Handle specific error conditions. */

          if ($status_code == 403 && ref($decoded) eq 'HASH') 
          {
               my $error = $decoded->{error} // '';
               
               my $message = $decoded->{message} // '';

               if ($error =~ /Authentication is disabled/ || $message =~ /Tokens are not accepted when authentication is disabled/) 
               {
                    die Hlquery::AuthenticationException->new(
                        "Authentication is disabled on the server. Remove the token from your client configuration. " .
                        "Server message: " . ($message || $error) . "."
                    );
               }
          }

          return Hlquery::Response->new($status_code, $decoded, \%response_headers);
     }

     1;
}

__END__

=head1 NAME

Hlquery::Request - Internal HTTP request handler for the hlquery Perl API

=head1 DESCRIPTION

This module is used internally by C<Hlquery::Client> to perform HTTP requests
to the hlquery server. It handles URL construction, JSON encoding/decoding,
and authentication headers.

=head1 METHODS

=head2 new($base_url, $timeout, $auth_token, $auth_method)

Creates a new request handler instance.

=head2 SetAuthToken($token, $method)

Sets the authentication token and method.

=head2 Execute($method, $path, $body, $query_params)

Executes an HTTP request and returns an L<Hlquery::Response> object.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
