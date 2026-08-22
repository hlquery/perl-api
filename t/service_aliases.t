use strict;
use warnings;

use Test::More;
use lib 'lib';

use Hlquery::Client;

my %aliases = (
    'Hlquery::Client::Keys'      => [qw(list create get update delete)],
    'Hlquery::Client::Synonyms'  => [qw(list_all list upsert create update get delete list_global upsert_global create_global update_global get_global delete_global)],
    'Hlquery::Client::Stopwords' => [qw(list_all list_global create_global delete_global list create delete)],
    'Hlquery::Client::Overrides' => [qw(list upsert create update get delete)],
    'Hlquery::Client::Aliases'   => [qw(list list_for_collection upsert create update get delete)],
    'Hlquery::Client::Users'     => [qw(list create get update delete)],
    'Hlquery::Client::Links'     => [qw(list ping connect disconnect)],
    'Hlquery::Client::Modules'   => [qw(list load load_with_payload unload unload_with_payload syntax request)],
    'Hlquery::Client::Analytics' => [qw(click)],
    'Hlquery::Client::Presets'   => [qw(list get create update upsert delete)],
);

for my $package (sort keys %aliases)
{
    can_ok($package, @{$aliases{$package}});
}

{
    package Local::RecordingClient;

    sub new { return bless { calls => [] }, shift; }

    sub ExecuteRequest
    {
        my ($self, @args) = @_;
        push @{$self->{calls}}, \@args;
        return $self->{calls}->[-1];
    }
}

my $recorder = Local::RecordingClient->new;

my $keys = bless { client => $recorder }, 'Hlquery::Client::Keys';
is_deeply(
    $keys->get('key/1'),
    ['GET', '/keys/key%2F1'],
    'lowercase key alias forwards arguments and URL-encodes identifiers',
);

my $modules = bless { client => $recorder }, 'Hlquery::Client::Modules';
is_deeply(
    $modules->load_with_payload({ name => 'example' }),
    ['POST', '/loadmodule', { name => 'example' }],
    'multiword lowercase alias forwards payloads',
);

my $presets = bless { client => $recorder }, 'Hlquery::Client::Presets';
is_deeply(
    $presets->delete('daily report'),
    ['DELETE', '/presets/daily%20report'],
    'lowercase preset alias preserves validation and encoding',
);

done_testing;
