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

sub ClearAuth
{
    my ($self) = @_;
    $self->{token} = undef;
    return $self;
}

sub Collections { return bless { client => $_[0] }, 'Hlquery::Client::Collections'; }
sub Documents   { return bless { client => $_[0] }, 'Hlquery::Client::Documents'; }
sub SearchAPI   { return bless { client => $_[0] }, 'Hlquery::Client::SearchAPI'; }
sub SQL         { return bless { client => $_[0] }, 'Hlquery::Client::SQL'; }
sub Keys        { return bless { client => $_[0] }, 'Hlquery::Client::Keys'; }
sub Synonyms    { return bless { client => $_[0] }, 'Hlquery::Client::Synonyms'; }
sub Stopwords   { return bless { client => $_[0] }, 'Hlquery::Client::Stopwords'; }
sub Overrides   { return bless { client => $_[0] }, 'Hlquery::Client::Overrides'; }
sub Aliases     { return bless { client => $_[0] }, 'Hlquery::Client::Aliases'; }
sub Users       { return bless { client => $_[0] }, 'Hlquery::Client::Users'; }
sub Links       { return bless { client => $_[0] }, 'Hlquery::Client::Links'; }
sub Modules     { return bless { client => $_[0] }, 'Hlquery::Client::Modules'; }
sub Analytics   { return bless { client => $_[0] }, 'Hlquery::Client::Analytics'; }
sub Presets     { return bless { client => $_[0] }, 'Hlquery::Client::Presets'; }

sub collections { return $_[0]->Collections(); }
sub documents   { return $_[0]->Documents(); }
sub search_api  { return $_[0]->SearchAPI(); }
sub sql         { return $_[0]->SQL(); }
sub sql_api     { return $_[0]->SQL(); }
sub keys        { return $_[0]->Keys(); }
sub synonyms    { return $_[0]->Synonyms(); }
sub stopwords   { return $_[0]->Stopwords(); }
sub overrides   { return $_[0]->Overrides(); }
sub aliases     { return $_[0]->Aliases(); }
sub users       { return $_[0]->Users(); }
sub links       { return $_[0]->Links(); }
sub modules     { return $_[0]->Modules(); }
sub analytics   { return $_[0]->Analytics(); }
sub presets     { return $_[0]->Presets(); }

sub Info   { return $_[0]->ExecuteRequest('GET', '/'); }
sub Health { return $_[0]->ExecuteRequest('GET', '/health'); }
sub Stats  { return $_[0]->ExecuteRequest('GET', '/stats'); }
sub Flush  { return $_[0]->ExecuteRequest('POST', '/flush'); }
sub Status { return $_[0]->ExecuteRequest('GET', '/status'); }
sub Query  { return $_[0]->ExecuteRequest('GET', '/query'); }
sub Ready  { return $_[0]->ExecuteRequest('GET', '/ready'); }
sub Ping   { return $_[0]->ExecuteRequest('GET', '/ping'); }
sub Metrics { return $_[0]->ExecuteRequest('GET', '/metrics'); }
sub MetricsJson { return $_[0]->ExecuteRequest('GET', '/metrics.json'); }
sub MetricsHistory { return $_[0]->ExecuteRequest('GET', '/metrics/history'); }
sub Cache { return $_[0]->ExecuteRequest('GET', '/cache'); }
sub Connections { return $_[0]->ExecuteRequest('GET', '/connections'); }
sub RocksDB { return $_[0]->ExecuteRequest('GET', '/rocksdb'); }
sub RocksDBInternal { return $_[0]->ExecuteRequest('GET', '/_rocksdb'); }
sub DocTotal { return $_[0]->ExecuteRequest('GET', '/doctotal'); }
sub SearchConfig { return $_[0]->ExecuteRequest('GET', '/search-config'); }
sub ConfigFiles { return $_[0]->ExecuteRequest('GET', '/config-files'); }
sub Startup { return $_[0]->ExecuteRequest('GET', '/startup'); }
sub BootStatus { return $_[0]->ExecuteRequest('GET', '/boot-status'); }
sub Integrity { return $_[0]->ExecuteRequest('GET', '/integrity'); }
sub Consistency { return $_[0]->ExecuteRequest('GET', '/consistency'); }
sub SelfCheck { return $_[0]->ExecuteRequest('GET', '/self-check'); }
sub StorageStatus { return $_[0]->ExecuteRequest('GET', '/admin/storage_status'); }
sub Etc { return $_[0]->ExecuteRequest('GET', '/etc'); }

sub Repair
{
    my ($self, $payload, $params) = @_;
    return $self->ExecuteRequest(defined $payload ? 'POST' : 'GET', '/repair', $payload, $params || {});
}

sub UpdateCounters
{
    my ($self, $payload, $params) = @_;
    return $self->ExecuteRequest(defined $payload ? 'POST' : 'GET', '/update-counters', $payload, $params || {});
}

sub DebugCounters { return $_[0]->ExecuteRequest('GET', '/debug/counters'); }

sub set_auth_token { return shift->SetAuthToken(@_); }
sub clear_auth     { return shift->ClearAuth(@_); }

sub info               { return $_[0]->Info(); }
sub health             { return $_[0]->Health(); }
sub stats              { return $_[0]->Stats(); }
sub flush              { return $_[0]->Flush(); }
sub status             { return $_[0]->Status(); }
sub query              { return $_[0]->Query(); }
sub ready              { return $_[0]->Ready(); }
sub ping               { return $_[0]->Ping(); }
sub metrics            { return $_[0]->Metrics(); }
sub metrics_json       { return $_[0]->MetricsJson(); }
sub metrics_history    { return $_[0]->MetricsHistory(); }
sub cache              { return $_[0]->Cache(); }
sub connections        { return $_[0]->Connections(); }
sub rocksdb            { return $_[0]->RocksDB(); }
sub rocksdb_internal   { return $_[0]->RocksDBInternal(); }
sub doc_total          { return $_[0]->DocTotal(); }
sub search_config      { return $_[0]->SearchConfig(); }
sub config_files       { return $_[0]->ConfigFiles(); }
sub startup            { return $_[0]->Startup(); }
sub boot_status        { return $_[0]->BootStatus(); }
sub integrity          { return $_[0]->Integrity(); }
sub consistency        { return $_[0]->Consistency(); }
sub self_check         { return $_[0]->SelfCheck(); }
sub storage_status     { return $_[0]->StorageStatus(); }
sub etc                { return $_[0]->Etc(); }
sub repair             { return shift->Repair(@_); }
sub update_counters    { return shift->UpdateCounters(@_); }
sub debug_counters     { return $_[0]->DebugCounters(); }
sub list_collections   { return shift->ListCollections(@_); }
sub get_collection     { return shift->GetCollection(@_); }
sub get_collection_fields { return shift->GetCollectionFields(@_); }
sub update_collection  { return shift->UpdateCollection(@_); }
sub list_documents     { return shift->ListDocuments(@_); }
sub get_document_context { return shift->GetDocumentContext(@_); }
sub get_document       { return shift->GetDocument(@_); }
sub search             { return shift->Search(@_); }
sub sql_query          { return shift->Sql(@_); }
sub global_search      { return shift->GlobalSearch(@_); }
sub search_all         { return shift->GlobalSearch(@_); }
sub exec_sql           { return shift->ExecSql(@_); }
sub execute_request    { return shift->ExecuteRequest(@_); }

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
    return $self->GetCollection($name);
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

sub GetDocumentContext
{
    my ($self, $collection_name, $document_id, $params) = @_;
    return $self->ExecuteRequest(
        'GET',
        '/collections/' . _url_encode($collection_name) . '/documents/' . _url_encode($document_id) . '/context',
        undef,
        $params || {},
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

sub SqlSearch
{
    my ($self, $collection_name, $sql, $params) = @_;
    $params ||= {};
    $sql ||= '';

    my %normalized = %{$params};
    $normalized{sql} = $sql;

    return $self->ExecuteRequest(
        'GET',
        '/collections/' . _url_encode($collection_name) . '/documents/search',
        undef,
        \%normalized,
    );
}

sub Sql
{
    my ($self, $sql, $params) = @_;
    $params ||= {};
    $sql ||= '';

    my %normalized = %{$params};
    $normalized{sql} = $sql;

    return $self->ExecuteRequest('GET', '/sql', undef, \%normalized);
}

sub GlobalSearch
{
    my ($self, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    return $method eq 'POST'
        ? $self->ExecuteRequest('POST', '/search', $params)
        : $self->ExecuteRequest('GET', '/search', undef, $params);
}

sub SearchAll { return shift->GlobalSearch(@_); }

sub ExecSql
{
    my ($self, $sql) = @_;
    $sql ||= '';
    return $self->ExecuteRequest('POST', '/sql', { exec => $sql });
}

sub ExecuteRequest
{
    my ($self, $method, $path, $body, $query) = @_;

    $method ||= 'GET';
    $path ||= '/';
    $query ||= {};

    my $uri = URI->new($self->{base_url} . $path);
    my %query_form;

    for my $key (CORE::keys %{$query})
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

sub _collection_path
{
    my ($collection_name, @segments) = @_;
    return join('', '/collections/', _url_encode($collection_name), map { '/' . _url_encode($_) } @segments);
}

sub _upsert_method
{
    my ($method) = @_;
    $method = uc($method || 'PUT');
    die "Upsert method must be POST or PUT\n" if $method ne 'POST' && $method ne 'PUT';
    return $method;
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

sub List
{
    my ($self, $offset, $limit) = @_;
    return $self->{client}->ListCollections($offset, $limit);
}

sub Get
{
    my ($self, $name) = @_;
    return $self->{client}->GetCollection($name);
}

sub GetFields
{
    my ($self, $name) = @_;
    return $self->{client}->GetCollectionFields($name);
}

sub Language
{
    my ($self, $name) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($name, 'lang'));
}

sub Distributed
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/collections/distributed', undef, $params || {});
}

sub Update
{
    my ($self, $name, $schema) = @_;
    return $self->{client}->UpdateCollection($name, $schema || {});
}

sub VectorSearch
{
    my ($self, $name, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    my $path = Hlquery::Client::_collection_path($name, 'vector_search');
    return $method eq 'POST'
        ? $self->{client}->ExecuteRequest('POST', $path, $params)
        : $self->{client}->ExecuteRequest('GET', $path, undef, $params);
}

sub SearchAlias
{
    my ($self, $name, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    my $path = Hlquery::Client::_collection_path($name, 'search');
    return $method eq 'POST'
        ? $self->{client}->ExecuteRequest('POST', $path, $params)
        : $self->{client}->ExecuteRequest('GET', $path, undef, $params);
}

sub create        { return shift->Create(@_); }
sub delete        { return shift->Delete(@_); }
sub list          { return shift->List(@_); }
sub get           { return shift->Get(@_); }
sub get_fields    { return shift->GetFields(@_); }
sub language      { return shift->Language(@_); }
sub distributed   { return shift->Distributed(@_); }
sub update        { return shift->Update(@_); }
sub vector_search { return shift->VectorSearch(@_); }
sub search_alias  { return shift->SearchAlias(@_); }

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

sub List
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ListDocuments($collection_name, $params || {});
}

sub Get
{
    my ($self, $collection_name, $document_id) = @_;
    return $self->{client}->GetDocument($collection_name, $document_id);
}

sub Import
{
    my ($self, $collection_name, $documents, $params) = @_;
    return $self->{client}->ExecuteRequest(
        'POST',
        Hlquery::Client::_collection_path($collection_name, 'documents', 'import'),
        { documents => $documents || [] },
        $params || {},
    );
}

sub DeleteByFilter
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ExecuteRequest(
        'DELETE',
        Hlquery::Client::_collection_path($collection_name, 'documents'),
        undef,
        $params || {},
    );
}

sub Search
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->Search($collection_name, $params || {});
}

sub SearchPost
{
    my ($self, $collection_name, $payload) = @_;
    return $self->{client}->ExecuteRequest(
        'POST',
        Hlquery::Client::_collection_path($collection_name, 'documents', 'search'),
        $payload || {},
    );
}

sub Context
{
    my ($self, $collection_name, $document_id, $params) = @_;
    return $self->{client}->GetDocumentContext($collection_name, $document_id, $params || {});
}

sub UpdateByQuery
{
    my ($self, $collection_name, $payload) = @_;
    return $self->{client}->ExecuteRequest(
        'POST',
        Hlquery::Client::_collection_path($collection_name, 'documents', '_update_by_query'),
        $payload || {},
    );
}

sub DeleteByQuery
{
    my ($self, $collection_name, $payload) = @_;
    return $self->{client}->ExecuteRequest(
        'POST',
        Hlquery::Client::_collection_path($collection_name, 'documents', '_delete_by_query'),
        $payload || {},
    );
}

sub Facets
{
    my ($self, $collection_name, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    my $path = Hlquery::Client::_collection_path($collection_name, 'documents', 'facet_counts');
    return $method eq 'POST'
        ? $self->{client}->ExecuteRequest('POST', $path, $params)
        : $self->{client}->ExecuteRequest('GET', $path, undef, $params);
}

sub Export
{
    my ($self, $collection_name, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    my $path = Hlquery::Client::_collection_path($collection_name, 'documents', 'export');
    return $method eq 'POST'
        ? $self->{client}->ExecuteRequest('POST', $path, $params)
        : $self->{client}->ExecuteRequest('GET', $path, undef, $params);
}

sub Maybe
{
    my ($self, $collection_name, $params, $method) = @_;
    $params ||= {};
    $method = uc($method || 'GET');
    my $path = Hlquery::Client::_collection_path($collection_name, 'documents', 'maybe');
    return $method eq 'POST'
        ? $self->{client}->ExecuteRequest('POST', $path, $params)
        : $self->{client}->ExecuteRequest('GET', $path, undef, $params);
}

sub Recent
{
    my ($self, $collection_name, $limit, $offset) = @_;
    $limit = 20 if !defined $limit;
    $offset = 0 if !defined $offset;
    my $sql = 'select * from ' . $collection_name . ' order by timestamp desc limit ' . int($limit) . ' offset ' . int($offset);
    return $self->{client}->SqlSearch($collection_name, $sql);
}

sub Copy
{
    my ($self, $collection_name, $source_id, $target_id) = @_;
    my $source_response = $self->Get($collection_name, $source_id);
    return $source_response if !$source_response->IsSuccess();

    my $doc = $source_response->GetBody();
    return $source_response if ref($doc) ne 'HASH';

    delete $doc->{collection_id};
    delete $doc->{score};
    $doc->{id} = $target_id;

    return $self->Import($collection_name, [$doc]);
}

sub add              { return shift->Add(@_); }
sub update           { return shift->Update(@_); }
sub delete           { return shift->Delete(@_); }
sub list             { return shift->List(@_); }
sub get              { return shift->Get(@_); }
sub import           { return shift->Import(@_); }
sub delete_by_filter { return shift->DeleteByFilter(@_); }
sub search           { return shift->Search(@_); }
sub search_post      { return shift->SearchPost(@_); }
sub context          { return shift->Context(@_); }
sub update_by_query  { return shift->UpdateByQuery(@_); }
sub delete_by_query  { return shift->DeleteByQuery(@_); }
sub facets           { return shift->Facets(@_); }
sub export           { return shift->Export(@_); }
sub maybe            { return shift->Maybe(@_); }
sub recent           { return shift->Recent(@_); }
sub copy             { return shift->Copy(@_); }

package Hlquery::Client::SearchAPI;

use strict;
use warnings;

sub MultiSearch
{
    my ($self, $searches, $method) = @_;
    $method = uc($method || 'POST');
    die "Multi-search method must be GET or POST\n" if $method ne 'GET' && $method ne 'POST';
    return $self->{client}->ExecuteRequest($method, '/multi_search', {
        searches => $searches || [],
    });
}

sub GlobalSearch
{
    my ($self, $params, $method) = @_;
    return $self->{client}->GlobalSearch($params || {}, $method || 'GET');
}

sub SearchAll { return shift->GlobalSearch(@_); }

sub VectorSearch
{
    my ($self, $collection_name, $params, $method) = @_;
    return $self->{client}->collections->vector_search($collection_name, $params || {}, $method || 'GET');
}

sub multi_search  { return shift->MultiSearch(@_); }
sub global_search { return shift->GlobalSearch(@_); }
sub search_all    { return shift->GlobalSearch(@_); }
sub vector_search { return shift->VectorSearch(@_); }

package Hlquery::Client::SQL;

use strict;
use warnings;

sub Query
{
    my ($self, $sql, $params) = @_;
    return $self->{client}->Sql($sql, $params);
}

sub Exec
{
    my ($self, $sql) = @_;
    return $self->{client}->ExecSql($sql);
}

sub Search
{
    my ($self, $collection_name, $sql, $params) = @_;
    return $self->{client}->SqlSearch($collection_name, $sql, $params);
}

sub query  { return shift->Query(@_); }
sub exec   { return shift->Exec(@_); }
sub search { return shift->Search(@_); }

package Hlquery::Client::Keys;

use strict;
use warnings;

sub List
{
    my ($self, $offset, $limit) = @_;
    return $self->{client}->ExecuteRequest('GET', '/keys', undef, {
        offset => defined $offset ? $offset : 0,
        limit  => defined $limit ? $limit : 100,
    });
}

sub Create
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/keys', $payload || {});
}

sub Get
{
    my ($self, $key_id) = @_;
    return $self->{client}->ExecuteRequest('GET', '/keys/' . Hlquery::Client::_url_encode($key_id));
}

sub Update
{
    my ($self, $key_id, $payload) = @_;
    return $self->{client}->ExecuteRequest('PUT', '/keys/' . Hlquery::Client::_url_encode($key_id), $payload || {});
}

sub Delete
{
    my ($self, $key_id) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/keys/' . Hlquery::Client::_url_encode($key_id));
}

sub list   { return shift->List(@_); }
sub create { return shift->Create(@_); }
sub get    { return shift->Get(@_); }
sub update { return shift->Update(@_); }
sub delete { return shift->Delete(@_); }

package Hlquery::Client::Synonyms;

use strict;
use warnings;

sub ListAll
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/synonyms', undef, $params || {});
}

sub List
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'synonyms'), undef, $params || {});
}

sub Upsert
{
    my ($self, $collection_name, $term, $payload, $method) = @_;
    return $self->{client}->ExecuteRequest(Hlquery::Client::_upsert_method($method), Hlquery::Client::_collection_path($collection_name, 'synonyms', $term), $payload || {});
}

sub Create { return shift->Upsert(@_); }
sub Update { return shift->Upsert(@_); }

sub Get
{
    my ($self, $collection_name, $term) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'synonyms', $term));
}

sub Delete
{
    my ($self, $collection_name, $term) = @_;
    return $self->{client}->ExecuteRequest('DELETE', Hlquery::Client::_collection_path($collection_name, 'synonyms', $term));
}

sub ListGlobal
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/synonyms/global', undef, $params || {});
}

sub UpsertGlobal
{
    my ($self, $term, $payload, $method) = @_;
    return $self->{client}->ExecuteRequest(Hlquery::Client::_upsert_method($method), '/synonyms/global/' . Hlquery::Client::_url_encode($term), $payload || {});
}

sub CreateGlobal { return shift->UpsertGlobal(@_); }
sub UpdateGlobal { return shift->UpsertGlobal(@_); }

sub GetGlobal
{
    my ($self, $term) = @_;
    return $self->{client}->ExecuteRequest('GET', '/synonyms/global/' . Hlquery::Client::_url_encode($term));
}

sub DeleteGlobal
{
    my ($self, $term) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/synonyms/global/' . Hlquery::Client::_url_encode($term));
}

sub list_all      { return shift->ListAll(@_); }
sub list          { return shift->List(@_); }
sub upsert        { return shift->Upsert(@_); }
sub create        { return shift->Create(@_); }
sub update        { return shift->Update(@_); }
sub get           { return shift->Get(@_); }
sub delete        { return shift->Delete(@_); }
sub list_global   { return shift->ListGlobal(@_); }
sub upsert_global { return shift->UpsertGlobal(@_); }
sub create_global { return shift->CreateGlobal(@_); }
sub update_global { return shift->UpdateGlobal(@_); }
sub get_global    { return shift->GetGlobal(@_); }
sub delete_global { return shift->DeleteGlobal(@_); }

package Hlquery::Client::Stopwords;

use strict;
use warnings;

sub ListAll
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/stopwords', undef, $params || {});
}

sub ListGlobal
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/stopwords/global', undef, $params || {});
}

sub CreateGlobal
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/stopwords/global', $payload || {});
}

sub DeleteGlobal
{
    my ($self, $term) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/stopwords/global/' . Hlquery::Client::_url_encode($term));
}

sub List
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'stopwords'), undef, $params || {});
}

sub Create
{
    my ($self, $collection_name, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', Hlquery::Client::_collection_path($collection_name, 'stopwords'), $payload || {});
}

sub Delete
{
    my ($self, $collection_name, $term) = @_;
    return $self->{client}->ExecuteRequest('DELETE', Hlquery::Client::_collection_path($collection_name, 'stopwords', $term));
}

sub list_all      { return shift->ListAll(@_); }
sub list_global   { return shift->ListGlobal(@_); }
sub create_global { return shift->CreateGlobal(@_); }
sub delete_global { return shift->DeleteGlobal(@_); }
sub list          { return shift->List(@_); }
sub create        { return shift->Create(@_); }
sub delete        { return shift->Delete(@_); }

package Hlquery::Client::Overrides;

use strict;
use warnings;

sub List
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'overrides'), undef, $params || {});
}

sub Upsert
{
    my ($self, $collection_name, $override_id, $payload, $method) = @_;
    return $self->{client}->ExecuteRequest(Hlquery::Client::_upsert_method($method), Hlquery::Client::_collection_path($collection_name, 'overrides', $override_id), $payload || {});
}

sub Create { return shift->Upsert(@_); }
sub Update { return shift->Upsert(@_); }

sub Get
{
    my ($self, $collection_name, $override_id) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'overrides', $override_id));
}

sub Delete
{
    my ($self, $collection_name, $override_id) = @_;
    return $self->{client}->ExecuteRequest('DELETE', Hlquery::Client::_collection_path($collection_name, 'overrides', $override_id));
}

sub list   { return shift->List(@_); }
sub upsert { return shift->Upsert(@_); }
sub create { return shift->Create(@_); }
sub update { return shift->Update(@_); }
sub get    { return shift->Get(@_); }
sub delete { return shift->Delete(@_); }

package Hlquery::Client::Aliases;

use strict;
use warnings;

sub List
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/aliases', undef, $params || {});
}

sub ListForCollection
{
    my ($self, $collection_name, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', Hlquery::Client::_collection_path($collection_name, 'aliases'), undef, $params || {});
}

sub Upsert
{
    my ($self, $alias, $payload, $method) = @_;
    return $self->{client}->ExecuteRequest(Hlquery::Client::_upsert_method($method), '/aliases/' . Hlquery::Client::_url_encode($alias), $payload || {});
}

sub Create { return shift->Upsert(@_); }
sub Update { return shift->Upsert(@_); }

sub Get
{
    my ($self, $alias) = @_;
    return $self->{client}->ExecuteRequest('GET', '/aliases/' . Hlquery::Client::_url_encode($alias));
}

sub Delete
{
    my ($self, $alias) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/aliases/' . Hlquery::Client::_url_encode($alias));
}

sub list                { return shift->List(@_); }
sub list_for_collection { return shift->ListForCollection(@_); }
sub upsert              { return shift->Upsert(@_); }
sub create              { return shift->Create(@_); }
sub update              { return shift->Update(@_); }
sub get                 { return shift->Get(@_); }
sub delete              { return shift->Delete(@_); }

package Hlquery::Client::Users;

use strict;
use warnings;

sub List
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/users', undef, $params || {});
}

sub Create
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/users', $payload || {});
}

sub Get
{
    my ($self, $user_id) = @_;
    return $self->{client}->ExecuteRequest('GET', '/users/' . Hlquery::Client::_url_encode($user_id));
}

sub Update
{
    my ($self, $user_id, $payload) = @_;
    return $self->{client}->ExecuteRequest('PUT', '/users/' . Hlquery::Client::_url_encode($user_id), $payload || {});
}

sub Delete
{
    my ($self, $user_id) = @_;
    return $self->{client}->ExecuteRequest('DELETE', '/users/' . Hlquery::Client::_url_encode($user_id));
}

sub list   { return shift->List(@_); }
sub create { return shift->Create(@_); }
sub get    { return shift->Get(@_); }
sub update { return shift->Update(@_); }
sub delete { return shift->Delete(@_); }

package Hlquery::Client::Links;

use strict;
use warnings;

sub List
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/links', undef, $params || {});
}

sub Ping
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/links/ping', undef, $params || {});
}

sub Connect
{
    my ($self, $endpoint) = @_;
    return $self->{client}->ExecuteRequest('POST', '/links/connect', { endpoint => $endpoint });
}

sub Disconnect
{
    my ($self, $endpoint) = @_;
    return $self->{client}->ExecuteRequest('POST', '/links/disconnect', { endpoint => $endpoint });
}

sub list       { return shift->List(@_); }
sub ping       { return shift->Ping(@_); }
sub connect    { return shift->Connect(@_); }
sub disconnect { return shift->Disconnect(@_); }

package Hlquery::Client::Modules;

use strict;
use warnings;

sub List
{
    my ($self, $params) = @_;
    return $self->{client}->ExecuteRequest('GET', '/modules', undef, $params || {});
}

sub Load
{
    my ($self, $module) = @_;
    return $self->{client}->ExecuteRequest('POST', '/loadmodule/' . Hlquery::Client::_url_encode($module));
}

sub LoadWithPayload
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/loadmodule', $payload || {});
}

sub Unload
{
    my ($self, $module) = @_;
    return $self->{client}->ExecuteRequest('POST', '/unloadmodule/' . Hlquery::Client::_url_encode($module));
}

sub UnloadWithPayload
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/unloadmodule', $payload || {});
}

sub Syntax
{
    my ($self, $module) = @_;
    return $self->{client}->ExecuteRequest('GET', '/modules/' . Hlquery::Client::_url_encode($module) . '/syntax');
}

sub Request
{
    my ($self, $method, $path, $payload, $query) = @_;
    $path ||= '';
    $path = '/modules/' . $path if $path !~ m{^/modules/};
    return $self->{client}->ExecuteRequest($method || 'GET', $path, $payload, $query || {});
}

sub list                { return shift->List(@_); }
sub load                { return shift->Load(@_); }
sub load_with_payload   { return shift->LoadWithPayload(@_); }
sub unload              { return shift->Unload(@_); }
sub unload_with_payload { return shift->UnloadWithPayload(@_); }
sub syntax              { return shift->Syntax(@_); }
sub request             { return shift->Request(@_); }

package Hlquery::Client::Analytics;

use strict;
use warnings;

sub Click
{
    my ($self, $payload) = @_;
    return $self->{client}->ExecuteRequest('POST', '/analytics/click', $payload || {});
}

sub click { return shift->Click(@_); }

package Hlquery::Client::Presets;

use strict;
use warnings;

sub _name
{
    my ($name) = @_;
    die "Preset name must be a non-empty string\n" if !defined($name) || $name !~ /\S/;
    return Hlquery::Client::_url_encode($name);
}

sub List { return $_[0]->{client}->ExecuteRequest('GET', '/presets'); }
sub Get { return $_[0]->{client}->ExecuteRequest('GET', '/presets/' . _name($_[1])); }
sub Create { return $_[0]->{client}->ExecuteRequest('POST', '/presets/' . _name($_[1]), $_[2] || {}); }
sub Update { return $_[0]->{client}->ExecuteRequest('PUT', '/presets/' . _name($_[1]), $_[2] || {}); }
sub Upsert { my ($self, @args) = @_; return $self->Update(@args); }
sub Delete { return $_[0]->{client}->ExecuteRequest('DELETE', '/presets/' . _name($_[1])); }

sub list   { return shift->List(@_); }
sub get    { return shift->Get(@_); }
sub create { return shift->Create(@_); }
sub update { return shift->Update(@_); }
sub upsert { return shift->Upsert(@_); }
sub delete { return shift->Delete(@_); }

1;
