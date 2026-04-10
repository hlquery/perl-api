package Hlquery::Client;

use strict;
use warnings;

use Hlquery;
use Hlquery::Collections;
use Hlquery::Documents;
use Hlquery::Request;
use Hlquery::Search;

sub new
{
    my ($class, $base_url, $options) = @_;
    $options ||= {};

    my $request = Hlquery::Request->new($base_url, $options);
    my $self = {
        request     => $request,
        collections => Hlquery::Collections->new($request),
        documents   => Hlquery::Documents->new($request),
        search      => Hlquery::Search->new($request),
    };

    return bless $self, $class;
}

sub SetAuthToken
{
    my ($self, $token, $method) = @_;
    $self->{request}->SetAuthToken($token, $method);
    return $self;
}

sub ExecuteRequest
{
    my ($self, $method, $path, $payload, $query_params, $headers) = @_;
    return $self->{request}->Execute($method, $path, $payload, $query_params, $headers);
}

sub Health { return $_[0]->ExecuteRequest('GET', '/health'); }
sub Stats  { return $_[0]->ExecuteRequest('GET', '/stats'); }
sub Info   { return $_[0]->ExecuteRequest('GET', '/'); }
sub Flush  { return $_[0]->ExecuteRequest('POST', '/flush'); }
sub FlushAll { return $_[0]->Flush(); }

sub Collections { return $_[0]->{collections}; }
sub Documents   { return $_[0]->{documents}; }
sub SearchAPI   { return $_[0]->{search}; }

sub ListCollections   { return $_[0]->Collections()->List($_[1], $_[2]); }
sub GetCollection     { return $_[0]->Collections()->Get($_[1]); }
sub GetCollectionFields { return $_[0]->Collections()->GetFields($_[1]); }
sub UpdateCollection  { return $_[0]->Collections()->Update($_[1], $_[2]); }

sub ListDocuments { return $_[0]->Documents()->List($_[1], $_[2]); }
sub GetDocument   { return $_[0]->Documents()->Get($_[1], $_[2]); }

sub Search       { return $_[0]->SearchAPI()->Search($_[1], $_[2]); }
sub VectorSearch { return $_[0]->SearchAPI()->VectorSearch($_[1], $_[2]); }

1;
