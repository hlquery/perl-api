package Hlquery::Collections;

use strict;
use warnings;

use URI::Escape qw(uri_escape_utf8);
use Hlquery::Response;

sub new
{
    my ($class, $request) = @_;
    return bless { request => $request }, $class;
}

sub List
{
    my ($self, $offset, $limit) = @_;
    return $self->{request}->Execute('GET', '/collections', undef, {
        offset => defined $offset ? $offset : 0,
        limit  => defined $limit ? $limit : 10,
    });
}

sub Get
{
    my ($self, $name) = @_;
    return $self->{request}->Execute('GET', '/collections/' . uri_escape_utf8($name));
}

sub GetFields
{
    my ($self, $name) = @_;
    my $response = $self->Get($name);
    return $response unless $response->IsSuccess();

    my $body = $response->GetBody();
    return $response unless ref($body) eq 'HASH';

    my %field_types;
    my @ordered_fields;

    _collect_fields($body, 'searchable_fields', 'searchable', \%field_types, \@ordered_fields);
    _collect_fields($body, 'filterable_fields', 'filterable', \%field_types, \@ordered_fields);
    _collect_fields($body, 'sortable_fields',   'sortable',   \%field_types, \@ordered_fields);

    my @fields = map {
        {
            name => $_,
            type => join(', ', @{ $field_types{$_} || [] }),
        }
    } @ordered_fields;

    my $result = {
        collection        => $name,
        field_count       => scalar(@fields),
        fields            => \@fields,
        searchable_fields => $body->{searchable_fields} || [],
        filterable_fields => $body->{filterable_fields} || [],
        sortable_fields   => $body->{sortable_fields} || [],
    };

    return Hlquery::Response->new(
        status_code => 200,
        body        => $result,
        raw_body    => '',
        headers     => $response->GetHeaders(),
        error       => undef,
    );
}

sub Create
{
    my ($self, $name, $schema) = @_;
    $schema ||= {};
    my %payload = %{ $schema };
    $payload{name} = $name;
    return $self->{request}->Execute('POST', '/collections', \%payload);
}

sub Delete
{
    my ($self, $name) = @_;
    return $self->{request}->Execute('DELETE', '/collections/' . uri_escape_utf8($name));
}

sub Update
{
    my ($self, $name, $schema) = @_;
    $schema ||= {};
    return $self->{request}->Execute('POST', '/collections/' . uri_escape_utf8($name) . '/update', $schema);
}

sub _collect_fields
{
    my ($body, $key, $field_type, $field_types, $ordered_fields) = @_;
    return unless ref($body->{$key}) eq 'ARRAY';

    for my $field (@{ $body->{$key} })
    {
        next unless defined $field && !ref($field);

        if (!exists $field_types->{$field})
        {
            $field_types->{$field} = [];
            push @{$ordered_fields}, $field;
        }

        push @{$field_types->{$field}}, $field_type;
    }
}

1;
