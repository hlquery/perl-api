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

package Hlquery::AsyncClient
{
     use strict;
     use warnings;
     use Hlquery::AsyncRequest;
     use Hlquery::Collections;
     use Hlquery::Documents;
     use Hlquery::Search;
     use Hlquery::Utils::Config;

     # /*
     #  * Hlquery::AsyncClient - Non-blocking entry point for the hlquery Perl API.
     #  *
     #  * This class provides non-blocking methods for interacting with an hlquery server.
     #  * All methods return Promises.
     #  */

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

          my $request = Hlquery::AsyncRequest->new(
               $base_url,
               $options->{timeout},
               $options->{token},
               $options->{auth_method} || 'bearer',
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

     sub SetAuthToken 
     {
          my ($self, $token, $method) = @_;
          $self->{request}->SetAuthToken($token, $method || 'bearer');
          return $self;
     }

     sub Health 
     {
          my $self = shift;
          return $self->{request}->Execute('GET', '/health');
     }

     sub Stats 
     {
          my $self = shift;
          return $self->{request}->Execute('GET', '/stats');
     }

     sub Search 
     {
          my ($self, $collection_name, $params) = @_;
          return $self->{search}->Search($collection_name, $params);
     }

     sub Collections { shift->{collections} }
     sub Documents   { shift->{documents} }
     sub SearchAPI   { shift->{search} }

     1;
}

__END__

=head1 NAME

Hlquery::AsyncClient - Non-blocking Perl client for hlquery

=head1 SYNOPSIS

    use Hlquery::AsyncClient;
    use Mojo::IOLoop;

    my $client = Hlquery::AsyncClient->new('http://localhost:9200');
    
    $client->Search('products', { q => 'laptop' })->then(sub {
        my $res = shift;
        print "Found " . $res->GetBody()->{found} . " documents\n";
    })->catch(sub {
        warn "Search failed: @_";
    });

    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

=head1 DESCRIPTION

C<Hlquery::AsyncClient> provides a non-blocking interface for hlquery using C<Mojo::UserAgent> and C<Promises>.

=cut
