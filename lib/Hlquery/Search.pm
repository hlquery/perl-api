package Hlquery::Search;

use strict;
use warnings;

use URI::Escape qw(uri_escape_utf8);

sub new
{
    my ($class, $request) = @_;
    return bless { request => $request }, $class;
}

sub Search
{
    my ($self, $collection, $params) = @_;
    $params ||= {};
    return $self->{request}->Execute(
        'GET',
        '/collections/' . uri_escape_utf8($collection) . '/documents/search',
        undef,
        $params
    );
}

sub VectorSearch
{
    my ($self, $collection, $params) = @_;
    $params ||= {};
    my $body = ref($params->{body}) eq 'HASH' ? $params->{body} : $params;
    return $self->{request}->Execute(
        'POST',
        '/collections/' . uri_escape_utf8($collection) . '/search',
        $body
    );
}

sub MultiSearch
{
    my ($self, $searches) = @_;
    return $self->{request}->Execute('POST', '/multi_search', { searches => $searches || [] });
}

1;
