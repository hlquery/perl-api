package Hlquery::Request;

use strict;
use warnings;

use JSON qw(encode_json decode_json);
use LWP::UserAgent;
use HTTP::Request;
use URI::Escape qw(uri_escape_utf8);

use Hlquery::Response;

sub new
{
    my ($class, $base_url, $options) = @_;
    $options ||= {};

    my $ua = LWP::UserAgent->new(
        agent   => 'hlquery-perl/1.0.0',
        timeout => $options->{timeout} || 30,
    );
    $ua->env_proxy;

    my $self = {
        base_url    => _normalize_base_url($base_url),
        auth_token  => $options->{token},
        auth_method => $options->{auth_method} || 'bearer',
        user_agent  => $ua,
    };

    return bless $self, $class;
}

sub SetAuthToken
{
    my ($self, $token, $method) = @_;
    $self->{auth_token} = $token;
    $self->{auth_method} = $method || 'bearer';
    return $self;
}

sub Execute
{
    my ($self, $method, $path, $payload, $query_params, $headers) = @_;

    my $url = $self->{base_url} . $path;
    my $query = _build_query_string($query_params);
    $url .= "?$query" if length $query;

    my $request = HTTP::Request->new($method => $url);
    $request->header('Accept' => 'application/json');

    if ($headers && ref($headers) eq 'HASH')
    {
        for my $name (keys %{$headers})
        {
            next unless defined $headers->{$name};
            $request->header($name => $headers->{$name});
        }
    }

    if (defined $self->{auth_token} && length $self->{auth_token})
    {
        if (($self->{auth_method} || '') eq 'api-key')
        {
            $request->header('X-API-Key' => $self->{auth_token});
        }
        else
        {
            $request->header('Authorization' => 'Bearer ' . $self->{auth_token});
        }
    }

    if (defined $payload)
    {
        my $body = ref($payload) ? encode_json($payload) : $payload;
        $request->header('Content-Type' => 'application/json');
        $request->content($body);
    }

    my $http_response = $self->{user_agent}->request($request);
    my $raw_body = defined $http_response->decoded_content ? $http_response->decoded_content : '';
    my $decoded_body = _decode_body($raw_body, $http_response->header('Content-Type'));
    my $error = undef;

    if (!$http_response->is_success)
    {
        if (ref($decoded_body) eq 'HASH')
        {
            $error = $decoded_body->{message} || $decoded_body->{error} || $http_response->message;
        }
        else
        {
            $error = $http_response->message;
        }
    }

    return Hlquery::Response->new(
        status_code => $http_response->code + 0,
        body        => $decoded_body,
        raw_body    => $raw_body,
        headers     => { $http_response->headers->flatten },
        error       => $error,
    );
}

sub _normalize_base_url
{
    my ($base_url) = @_;
    $base_url ||= 'http://localhost:9200';
    $base_url =~ s{/\z}{};
    return $base_url;
}

sub _decode_body
{
    my ($raw_body, $content_type) = @_;
    return undef if !defined $raw_body || $raw_body eq '';

    if (defined $content_type && $content_type =~ m{application/json}i)
    {
        my $decoded = eval { decode_json($raw_body) };
        return $@ ? $raw_body : $decoded;
    }

    if ($raw_body =~ /^\s*[\{\[]/)
    {
        my $decoded = eval { decode_json($raw_body) };
        return $@ ? $raw_body : $decoded;
    }

    return $raw_body;
}

sub _build_query_string
{
    my ($query_params) = @_;
    return '' unless $query_params && ref($query_params) eq 'HASH';

    my @pairs;
    for my $key (sort keys %{$query_params})
    {
        my $value = $query_params->{$key};
        next unless defined $value;

        if (ref($value) eq 'ARRAY')
        {
            push @pairs, map { uri_escape_utf8($key) . '=' . uri_escape_utf8(defined($_) ? "$_" : '') } @{$value};
            next;
        }

        if (ref($value))
        {
            push @pairs, uri_escape_utf8($key) . '=' . uri_escape_utf8(encode_json($value));
            next;
        }

        push @pairs, uri_escape_utf8($key) . '=' . uri_escape_utf8("$value");
    }

    return join('&', @pairs);
}

1;
