package Hlquery::Documents;

use strict;
use warnings;

use URI::Escape qw(uri_escape_utf8);

BEGIN {
    package Hlquery::documents;
    our @ISA = ('Hlquery::Documents');
    $INC{'Hlquery/documents.pm'} = __FILE__;
}

package Hlquery::Documents;

sub new
{
    my ($class, $request) = @_;
    return bless { request => $request }, $class;
}

sub List
{
    my ($self, $collection, $params) = @_;
    $params ||= {};
    return $self->{request}->Execute('GET', '/collections/' . uri_escape_utf8($collection) . '/documents', undef, $params);
}

sub Get
{
    my ($self, $collection, $document_id) = @_;
    return $self->{request}->Execute('GET', '/collections/' . uri_escape_utf8($collection) . '/documents/' . uri_escape_utf8($document_id));
}

sub Add
{
    my ($self, $collection, $document) = @_;
    return $self->{request}->Execute('POST', '/collections/' . uri_escape_utf8($collection) . '/documents', $document);
}

sub Update
{
    my ($self, $collection, $document_id, $document) = @_;
    return $self->{request}->Execute('PUT', '/collections/' . uri_escape_utf8($collection) . '/documents/' . uri_escape_utf8($document_id), $document);
}

sub Delete
{
    my ($self, $collection, $document_id) = @_;
    return $self->{request}->Execute('DELETE', '/collections/' . uri_escape_utf8($collection) . '/documents/' . uri_escape_utf8($document_id));
}

sub ImportDocuments
{
    my ($self, $collection, $documents) = @_;
    return $self->{request}->Execute(
        'POST',
        '/collections/' . uri_escape_utf8($collection) . '/documents/import',
        { documents => $documents || [] }
    );
}

1;
