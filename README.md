<div align="center">
  <img src="https://docs.hlquery.com/img/hlquery/2.png" alt="hlquery logo" width="200">
</div>


# hlquery Perl API Client

A modular Perl client library for hlquery, designed with a familiar and intuitive API structure.

## Features

-  **Modular Architecture**: Clean separation of concerns with organized classes
-  **Intuitive API**: Familiar and easy-to-use structure
-  **Authentication Support**: Bearer token and X-API-Key authentication
-  **Flexible Parameters**: Support for multiple parameter formats
-  **Auto-detection**: Automatically detects searchable fields when not specified
-  **Type-safe Responses**: Response objects with helper methods
-  **Comprehensive Validation**: Input validation for all operations
-  **Minimal Dependencies**: Uses standard Perl modules (LWP, JSON, URI)


## Installation

### Prerequisites

Install required Perl modules:

```bash
cpanm LWP::UserAgent JSON URI URI::Escape Digest::MD5
```

Or using cpanfile:

```bash
cpanm --installdeps .
```

### Manual Installation

Add the lib directory to your Perl path:

```perl
use lib '/path/to/hlquery/etc/api/perl/lib';
use Hlquery::Client;
```

## Quick Start

### Basic Usage

```perl
use Hlquery::Client;

# Initialize client
my $client = Hlquery::Client->new('http://localhost:9200');

# Health check
my $health = $client->Health();
print "Status: " . $health->GetStatusCode() . "\n";

# List collections
my $collections = $client->ListCollections(0, 10);
if ($collections->IsSuccess()) {
    my $body = $collections->GetBody();
    print "Found " . scalar(@{$body->{collections}}) . " collections\n";
}
```

### With Authentication

```perl
# Method 1: Set token in constructor
my $client = Hlquery::Client->new('http://localhost:9200', {
    token => 'your_token_here',
    auth_method => 'bearer'  # or 'api-key'
});

# Method 2: Set token dynamically
my $client = Hlquery::Client->new('http://localhost:9200');
$client->SetAuthToken('your_token_here', 'bearer');

# Method 3: Use X-API-Key
$client->SetAuthToken('your_token_here', 'api-key');
```

## Architecture

### Core Classes

#### `Hlquery::Client`
Main client class that provides access to all API operations.

#### `Hlquery::Request`
Handles HTTP requests, authentication, and error handling using LWP::UserAgent.

#### `Hlquery::Response`
Response wrapper with helper methods:
- `GetStatusCode()` - Get HTTP status code
- `GetBody()` - Get response body
- `GetData()` - Get 'data' field from response body
- `IsSuccess()` - Check if request was successful
- `IsError()` - Check if request failed
- `GetError()` - Get error message
- `ToHash()` - Convert to hash format (for backward compatibility)

#### `Hlquery::Collections`
Collection management operations (List, Get, Create, Delete, Update).

#### `Hlquery::Documents`
Document CRUD operations (List, Get, Add, Update, Delete, ImportDocuments).

#### `Hlquery::Search`
Search operations with flexible parameter formats.

### Utility Classes

#### `Hlquery::Utils::Auth`
Authentication utilities (token generation, validation).

#### `Hlquery::Utils::Config`
Configuration management (defaults, URL validation).

#### `Hlquery::Utils::Validator`
Input validation for all operations.

### Exceptions

- `Hlquery::Exception` - Base exception
- `Hlquery::AuthenticationException` - Authentication errors
- `Hlquery::RequestException` - Request errors
- `Hlquery::ValidationException` - Validation errors
- `Hlquery::CollectionException` - Collection operation errors
- `Hlquery::DocumentException` - Document operation errors
- `Hlquery::SearchException` - Search operation errors

## API Methods

### System APIs

#### `Health()`
Check server health status.

```perl
my $health = $client->Health();
if ($health->IsSuccess()) {
    my $body = $health->GetBody();
    print "Status: " . $body->{status} . "\n";
}
```

#### `Stats()`
Get server statistics.

```perl
my $stats = $client->Stats();
```

#### `Info()`
Get server information.

```perl
my $info = $client->Info();
```

### Collections API

#### Using the Collections API Object

```perl
my $collections = $client->Collections();

# List collections
my $result = $collections->List(0, 10);

# Get collection
$result = $collections->Get('my_collection');

# Create collection
$result = $collections->Create('new_collection', $schema);

# Delete collection
$result = $collections->Delete('collection_name');

# Get formatted fields
$result = $collections->GetFields('my_collection');
```

#### Convenience Methods

```perl
# List collections
my $collections = $client->ListCollections(0, 10);

# Get collection details
my $collection = $client->GetCollection('my_collection');

# Get collection fields (formatted)
my $fields = $client->GetCollectionFields('my_collection');
```

### Documents API

#### Using the Documents API Object

```perl
my $documents = $client->Documents();

# List documents
my $result = $documents->List('collection', { offset => 0, limit => 10 });

# Get document
$result = $documents->Get('collection', 'doc_id');

# Add document
$result = $documents->Add('collection', $document);

# Update document
$result = $documents->Update('collection', 'doc_id', $document);

# Delete document
$result = $documents->Delete('collection', 'doc_id');

# Bulk import
$result = $documents->ImportDocuments('collection', [$doc1, $doc2, $doc3]);
```

#### Field Value Character Restrictions

**Important**: String field values have character restrictions:

**❌ Invalid Characters** (not allowed):
- Commas (`,`) - Reserved for internal parsing

** Valid Characters** (allowed):
- Letters, numbers, underscores (`_`), hyphens (`-`), spaces, periods, and most punctuation (except commas)

**Examples:**

 **Valid:**
```perl
my $doc = {
    id => 'doc1',
    tags => 'tag1_tag2_tag3',        #  Use underscores
    cast => 'Actor1_Actor2',          #  Use underscores
    genre => 'Action_Drama'            #  Use underscores
};

# Or use arrays for multiple values:
my $doc2 = {
    id => 'doc2',
    tags => ['tag1', 'tag2', 'tag3']  #  Arrays are fine
};
```

❌ **Invalid:**
```perl
my $doc = {
    id => 'doc1',
    tags => 'tag1,tag2,tag3',         # ❌ Commas not allowed
    cast => 'Actor1, Actor2',         # ❌ Commas not allowed
    genre => 'Action,Drama'           # ❌ Commas not allowed
};
```

**Workarounds:**
- Use underscores (`_`) or spaces instead of commas
- Use arrays for multiple values: `tags => ['tag1', 'tag2', 'tag3']`
- Use separate fields if you need comma-separated data

#### Convenience Methods

```perl
# List documents
my $docs = $client->ListDocuments('collection', { offset => 0, limit => 10 });

# Get document
my $doc = $client->GetDocument('collection', 'doc_id');
```

### Search API

#### Using the Search API Object

```perl
my $search = $client->SearchAPI();

# Simple search
my $results = $search->Search('collection', {
    q => 'search query',
    query_by => 'title,content',
    limit => 10
});

# Multi-search
$results = $search->MultiSearch([
    { collection => 'col1', q => 'query1' },
    { collection => 'col2', q => 'query2' }
]);
```

#### Convenience Method

```perl
# Search documents
my $results = $client->Search('collection', {
    q => 'search query',
    query_by => 'title,content',
    limit => 10
});
```

### Search Parameters

The `Search()` method accepts flexible parameters:

#### Query String (`q`)
The `q` parameter supports advanced query syntax:
- **NOT**: `q => '!apple'` or `q => 'NOT apple'`
- **FIELD**: `q => 'title:laptop'` or `q => 'price:100'`
- **RANGE**: `q => 'price:[100 TO 500]'` or `q => 'price:{100 TO 500}'`
- **WILDCARD**: `q => 'laptop*'`, `q => '*laptop'`, `q => 'lap*top'`
- **REGEX**: `q => 'title:/pattern/'`
- **FUZZY**: `q => 'laptop~'` or `q => 'laptop~2'`
- **BOOST**: `q => 'laptop^2.0'` or `q => 'laptop^2'`
- **Boolean**: `q => 'laptop AND computer'`, `q => 'laptop OR notebook'`
- **Phrase**: `q => '"exact phrase"'`

#### Other Parameters
- `query_by` - Fields to search in (comma-separated string or array reference)
- `query` - Structured query object

#### Pagination
- `from` / `offset` - Starting offset
- `size` / `limit` - Number of results
- `page` - Page number (alternative to offset)
- `per_page` - Results per page

#### Filtering & Sorting
- `filter_by` - Filter conditions (string)
- `filter` - Filter object
- `sort_by` - Sort fields (string or array reference)
- `sort` - Sort specification

#### Faceting
- `facet_by` - Facet fields (string or array reference)
- `facets` - Facet specification

### API Aliases

#### `Indices($params)`
Alias for `ListCollections()`.

```perl
my $collections = $client->Indices({ offset => 0, limit => 10 });
```

#### `Get($params)`
Alias for `GetCollection()` or `GetDocument()`.

```perl
# Get document
my $doc = $client->Get({ index => 'collection', id => 'doc_id' });

# Get collection
my $collection = $client->Get({ index => 'collection' });
```

#### `Cat($type, $params)`
Cat API for listing collections and system information.

```perl
my $indices = $client->Cat('indices', { limit => 10 });
```

## Response Handling

All methods return a `Hlquery::Response` object:

```perl
my $response = $client->Health();

# Check status
if ($response->IsSuccess()) {
    # Handle success
    my $body = $response->GetBody();
}

# Or check status code
if ($response->GetStatusCode() == 200) {
    # Handle success
}

# Get error
if ($response->IsError()) {
    my $error = $response->GetError();
    print "Error: $error\n";
}

# Convert to hash (for backward compatibility)
my $hash = $response->ToHash();
# Returns: { status => 200, body => {...} }
```

## Error Handling

The client throws exceptions for errors:

```perl
use Hlquery::Client;
use Hlquery::Exceptions;

eval {
    my $result = $client->Search('collection', { q => 'test' });
    
    if ($result->IsError()) {
        # Handle HTTP error
        print "Error: " . $result->GetError() . "\n";
    }
};
if ($@) {
    if (ref($@) && $@->isa('Hlquery::RequestException')) {
        # Handle request errors
        print "Request failed: " . $@->Message() . "\n";
        print "Status: " . $@->StatusCode() . "\n";
    } elsif (ref($@) && $@->isa('Hlquery::AuthenticationException')) {
        # Handle authentication errors
        print "Auth failed: " . $@->Message() . "\n";
    } elsif (ref($@) && $@->isa('Hlquery::ValidationException')) {
        # Handle validation errors
        print "Validation failed: " . $@->Message() . "\n";
    } else {
        # Handle other errors
        print "Error: $@\n";
    }
}
```

## Examples

### Complete Example

See `example.pl` for a complete example demonstrating:
- Health checks
- Authentication (with and without token)
- Listing collections
- Getting collection fields
- Listing documents with pagination
- Multiple search methods
- Dynamic authentication

Run the example:

```bash
# Without authentication
perl example.pl

# With authentication
perl example.pl your_token_here
```

### Organized Examples

Check the `examples/` directory for organized examples:
- `basic_usage.pl` - Basic operations
- `search.pl` - Search patterns
- `collections.pl` - Collection management
- `documents.pl` - Document CRUD


## Requirements

- Perl >= 5.10
- LWP::UserAgent - For HTTP requests
- JSON - For JSON encoding/decoding
- URI - For URL handling
- URI::Escape - For URL encoding
- Digest::MD5 - For token generation

## Installation

This package can be installed via CPAN (when available) or manually:

```bash
# Install dependencies
cpanm LWP::UserAgent JSON URI URI::Escape Digest::MD5

# Use the library
perl -Ilib -MHlquery::Client -e '...'
```

## Architecture

The hlquery Perl client follows a modular design, separating the core client from specific API implementations for collections, documents, and search. This makes the library easy to maintain and extend.
