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

package Hlquery::AsyncRequest
{
     use strict;
     use warnings;
     use Mojo::UserAgent;
     use JSON::MaybeXS;
     use URI;
     use URI::Escape;
     use Promises qw(deferred);

     use Hlquery::Response;
     use Hlquery::Exceptions;

     # /*
     #  * Hlquery::AsyncRequest - Non-blocking HTTP request handler.
     #  *
     #  * Handles asynchronous communication with the hlquery server using Mojo::UserAgent.
     #  */

     sub new
     {
          my ($class, $base_url, $timeout, $auth_token, $auth_method, $lazy) = @_;

          $base_url =~ s/\/$//;
          
          $timeout //= 30;
          
          $auth_method //= 'bearer';

          my $ua = Mojo::UserAgent->new;
          
          $ua->request_timeout($timeout);
          
          my $self = bless 
          {
               base_url    => $base_url,
               timeout     => $timeout,
               auth_token  => $auth_token,
               auth_method => $auth_method,
               ua          => $ua,
               json        => JSON::MaybeXS->new->utf8->allow_nonref,
               lazy        => $lazy
          }, $class;

          return $self;
     }

     sub Execute
     {
          my ($self, $method, $path, $body, $query_params) = @_;

          my $deferred = deferred;
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

          my %headers = (
               'Content-Type' => 'application/json',
               'Accept'       => 'application/json',
          );

          if ($self->{auth_token}) 
          {
               if ($self->{auth_method} eq 'api-key') 
               {
                    $headers{'X-API-Key'} = $self->{auth_token};
               } 
               else 
               {
                    $headers{'Authorization'} = 'Bearer ' . $self->{auth_token};
               }
          }

          my $body_str;
          if (defined $body) 
          {
               if (ref($body) eq 'HASH' || ref($body) eq 'ARRAY') 
               {
                    $body_str = $self->{json}->encode($body);
               } 
               else 
               {
                    $body_str = $body;
               }
          }

          $self->{ua}->start($self->{ua}->build_tx($method => $url => \%headers => $body_str) => sub {
               my ($ua, $tx) = @_;
               
               my $res = $tx->result;
               my $status_code = $res->code;
               my $response_body = $res->body;
               
               my %response_headers;
               foreach my $name (@{$res->headers->names}) 
               {
                    $response_headers{lc($name)} = $res->headers->header($name);
               }

               my $decoded;
               my $decoder;
               
               if ($response_body) 
               {
                    $decoder = sub {
                         my $body = shift;
                         my $out;
                         eval { $out = $self->{json}->decode($body); };
                         return $@ ? $body : $out;
                    };

                    unless ($self->{lazy}) 
                    {
                         $decoded = $decoder->($response_body);
                         $decoder = undef;
                    } 
                    else 
                    {
                         $decoded = $response_body;
                    }
               }

               my $hl_res = Hlquery::Response->new($status_code, $decoded, \%response_headers, $decoder);
               $deferred->resolve($hl_res);
          });

          return $deferred->promise;
     }

     1;
}
