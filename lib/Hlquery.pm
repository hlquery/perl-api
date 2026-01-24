# /*
#  * hlquery - Search beyond keywords.
#  * http://www.hlquery.com
#  *
#  * Copyright (C) 2021-2026, Carlos F. Ferry <carlos.ferry@gmail.com>
#  *
#  * This file is part of hlquery, released under the BSD License version 3.
#  * You are free to redistribute and/or modify this software
#  * under the terms of the BSD License.
#  * For more details, please visit: https://docs.hlquery.com
#  */

package Hlquery
{
     use strict;
     use warnings;

     our $VERSION = '1.1.0';

     use Hlquery::Client;
     use Hlquery::Exceptions;

     # /*
     #  * Hlquery - Official Perl client for the hlquery search engine.
     #  * 
     #  * This module acts as a namespace and version holder for the hlquery
     #  * Perl library. The main entry point for users is Hlquery::Client.
     #  */

     1;
}

__END__

=head1 NAME

Hlquery - Official Perl client for the hlquery search engine

=head1 SYNOPSIS

    use Hlquery::Client;

    my $client = Hlquery::Client->new('http://localhost:9200');
    my $health = $client->Health();

=head1 DESCRIPTION

Hlquery is a high-performance Perl client for the hlquery search engine.
It provides a simple, object-oriented interface for managing collections,
indexing documents, and performing advanced searches.

=head1 SEE ALSO

L<Hlquery::Client>

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021-2026, Carlos F. Ferry.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
