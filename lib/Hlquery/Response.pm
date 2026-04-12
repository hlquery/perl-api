package Hlquery::Response;

use strict;
use warnings;

BEGIN {
    package Hlquery::response;
    our @ISA = ('Hlquery::Response');
    $INC{'Hlquery/response.pm'} = __FILE__;
}

package Hlquery::Response;

sub new
{
    my ($class, %args) = @_;

    my $self = {
        status_code => $args{status_code} // 0,
        body        => $args{body},
        raw_body    => defined $args{raw_body} ? $args{raw_body} : '',
        headers     => $args{headers} || {},
        error       => $args{error},
    };

    return bless $self, $class;
}

sub GetStatusCode { return $_[0]->{status_code}; }
sub GetBody       { return $_[0]->{body}; }
sub GetRawBody    { return $_[0]->{raw_body}; }
sub GetHeaders    { return $_[0]->{headers}; }
sub GetError      { return $_[0]->{error}; }

sub GetData
{
    my ($self) = @_;
    return unless ref($self->{body}) eq 'HASH';
    return $self->{body}->{data};
}

sub IsSuccess
{
    my ($self) = @_;
    return $self->{status_code} >= 200 && $self->{status_code} < 300;
}

sub IsError
{
    my ($self) = @_;
    return !$self->IsSuccess();
}

sub ToHash
{
    my ($self) = @_;
    return {
        status_code => $self->{status_code},
        body        => $self->{body},
        raw_body    => $self->{raw_body},
        headers     => $self->{headers},
        error       => $self->{error},
    };
}

1;
