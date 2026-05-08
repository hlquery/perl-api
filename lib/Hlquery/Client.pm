package Hlquery::Client;

use strict;
use warnings;

use JSON qw(encode_json decode_json);
use LWP::UserAgent;
use HTTP::Request;
use URI;
use URI::Escape qw(uri_escape);

use Hlquery::Response;

sub new
{
    my ($class, $base_url, $options) = @_;

    $base_url ||= 'http://localhost:9200';
    $options ||= {};

    $base_url =~ s{/+$}{};

    my $self = bless {
        base_url    => $base_url,
        token       => $options->{token},
        auth_method => $options->{auth_method} || 'bearer',
        user_agent  => LWP::UserAgent->new(
            agent   => 'hlquery-perl/0.1.0',
            timeout => $options->{timeout} || 30,
        ),
    }, $class;

    return $self;
}

sub SetAuthToken
{
    my ($self, $token, $auth_method) = @_;
    $self->{token} = $token;
    $self->{auth_method} = $auth_method || 'bearer';
    return $self;
}

sub Collections { return bless { client => $_[0] }, 'Hlquery::Client::Collections'; }
sub Documents   { return bless { client => $_[0] }, 'Hlquery::Client::Documents'; }
sub SearchAPI   { return bless { client => $_[0] }, 'Hlquery::Client::SearchAPI'; }

sub Info   { return $_[0]->ExecuteRequest('GET', '/'); }
sub Health { return $_[0]->ExecuteRequest('GET', '/health'); }
sub Stats  { return $_[0]->ExecuteRequest('GET', '/stats'); }
sub Flush  { return $_[0]->ExecuteRequest('POST', '/flush'); }

sub ListCollections
{
    my ($self, $offset, $limit) = @_;
    return $self->ExecuteRequest('GET', '/collections', undef, {
        offset => defined $offset ? $offset : 0,
        limit  => defined $limit ? $limit : 20,
    });
}

sub GetCollection
{
    my ($self, $name) = @_;
    return $self->ExecuteRequest('GET', '/collections/' . _url_encode($name));
}

sub GetCollectionFields
{
    my ($self, $name) = @_;
    return $self->ExecuteRequest('GET', '/collections/' . _url_encode($name) . '/fields');
}

sub UpdateCollection
{
    my ($self, $name, $schema) = @_;
    return $self->ExecuteRequest('POST', '/collections/' . _url_encode($name) . '/update', $schema);
}

sub ListDocuments
{
    my ($self, $collection_name, $params) = @_;
    $params ||= {};

    return $self->ExecuteRequest(
        'GET',
        '/collections/' . _url_encode($collection_name) . '/documents',
        undef,
        $params,
    );
}

sub GetDocument
{
    my ($self, $collection_name, $document_id) = @_;
    return $self->ExecuteRequest(
        'GET',
        '/collections/' . _url_encode($collection_name) . '/documents/' . _url_encode($document_id),
    );
}

sub Search
{
    my ($self, $collection_name, $params) = @_;
    $params ||= {};

    my %normalized = %{$params};
    if (ref($normalized{highlight_fields}) eq 'ARRAY')
    {
        $normalized{highlight_fields} = join(',', @{$normalized{highlight_fields}});
    }

    return $self->ExecuteRequest(
        'GET',
        '/collections/' . _url_encode($collection_name) . '/documents/search',
        undef,
        \%normalized,
    );
}

sub ExecuteRequest
{
    my ($self, $method, $path, $body, $query) = @_;

    $method ||= 'GET';
    $path ||= '/';
    $query ||= {};

    my $uri = URI->new($self->{base_url} . $path);
    my %query_form;

    for my $key (keys %{$query})
    {
        next if !defined $query->{$key};

        my $value = $query->{$key};
        if (ref($value) eq 'ARRAY')
        {
            $query_form{$key} = join(',', @{$value});
        }
        elsif (!ref($value))
        {
            $query_form{$key} = $value;
        }
    }

    $uri->query_form(%query_form) if %query_form;

    my $request = HTTP::Request->new($method => $uri);
    $request->header('Accept' => 'application/json');

    if (defined $self->{token} && length $self->{token})
    {
        my $auth_method = lc($self->{auth_method} || 'bearer');
        if ($auth_method eq 'api-key' || $auth_method eq 'apikey')
        {
            $request->header('X-API-Key' => $self->{token});
        }
        else
        {
            $request->header('Authorization' => 'Bearer ' . $self->{token});
        }
    }

    if (defined $body)
    {
        if (ref($body))
        {
            $request->header('Content-Type' => 'application/json');
            $request->content(encode_json($body));
        }
        else
        {
            $request->content($body);
        }
    }

    my $http_response = eval { $self->{user_agent}->request($request) };
    if (!$http_response)
    {
        return Hlquery::Response->new(
            status_code => 0,
            error       => $@ || 'Request failed',
            raw_body    => '',
        );
    }

    my $raw_body = $http_response->decoded_content;
    my $decoded_body = _decode_body($raw_body);
    my $error = $http_response->is_success ? undef : _extract_error($decoded_body, $raw_body);

    return Hlquery::Response->new(
        status_code => $http_response->code,
        body        => $decoded_body,
        raw_body    => $raw_body,
        headers     => {$http_response->headers->flatten},
        error       => $error,
    );
}

sub _decode_body
{
    my ($raw_body) = @_;
    return undef if !defined $raw_body || $raw_body eq '';

    my $decoded = eval { decode_json($raw_body) };
    return $@ ? $raw_body : $decoded;
}

sub _extract_error
{
    my ($decoded_body, $raw_body) = @_;

    if (ref($decoded_body) eq 'HASH')
    {
        return $decoded_body->{message} if defined $decoded_body->{message};
        return $decoded_body->{error} if defined $decoded_body->{error};
    }

    return $raw_body;
}

sub _url_encode
{
    my ($value) = @_;
    $value = '' if !defined $value;
    return uri_escape($value);
}

package Hlquery::Client::Collections;

use strict;
use warnings;

sub Create
{
    my ($self, $name, $schema) = @_;
    my %body = ref($schema) eq 'HASH' ? %{$schema} : ();
    $body{name} = $name;
    return $self->{client}->ExecuteRequest('POST', '/collections', \%body);
}

sub Delete
{
    my ($self, $name) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/collections/' . Hlquery::Client::_url_encode($name));
}

package Hlquery::Client::Documents;

use strict;
use warnings;

sub Add
{
    my ($self, $collection_name, $document) = @_;
    return $self->{client}->ExecuteRequest(
        'POST',
        '/collections/' . Hlquery::Client::_url_encode($collection_name) . '/documents',
        $document,
    );
}

sub Update
{
    my ($self, $collection_name, $document_id, $document) = @_;
    return $self->{client}->ExecuteRequest(
        'PUT',
        '/collections/' . Hlquery::Client::_url_encode($collection_name) . '/documents/' . Hlquery::Client::_url_encode($document_id),
        $document,
    );
}

sub Delete
{
    my ($self, $collection_name, $document_id) = @_;
    return $self->{client}->ExecuteRequest(
        'DELETE',
        '/collections/' . Hlquery::Client::_url_encode($collection_name) . '/documents/' . Hlquery::Client::_url_encode($document_id),
    );
}

package Hlquery::Client::SearchAPI;

use strict;
use warnings;

sub MultiSearch
{
    my ($self, $searches) = @_;
    return $self->{client}->ExecuteRequest('POST', '/multi_search', {
        searches => $searches || [],
    });
}

1;
