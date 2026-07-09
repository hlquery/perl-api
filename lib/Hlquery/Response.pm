package Hlquery::Response;

use strict;
use warnings;

sub new
{
    my ($class, %args) = @_;
    return bless {
        status_code => $args{status_code} // 0,
        body        => $args{body},
        raw_body    => $args{raw_body},
        headers     => $args{headers} || {},
        error       => $args{error},
    }, $class;
}

sub GetStatusCode { return $_[0]->{status_code}; }
sub GetBody       { return $_[0]->{body}; }
sub GetRawBody    { return $_[0]->{raw_body}; }
sub GetHeaders    { return $_[0]->{headers}; }
sub GetError      { return $_[0]->{error}; }

sub get_status_code { return $_[0]->GetStatusCode(); }
sub get_body        { return $_[0]->GetBody(); }
sub get_raw_body    { return $_[0]->GetRawBody(); }
sub get_headers     { return $_[0]->GetHeaders(); }
sub get_error       { return $_[0]->GetError(); }

sub IsSuccess
{
    my ($self) = @_;
    return $self->{status_code} >= 200 && $self->{status_code} < 300;
}

sub is_success { return $_[0]->IsSuccess(); }

1;
