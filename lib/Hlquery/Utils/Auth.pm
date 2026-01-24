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

package Hlquery::Utils::Auth
{
     use strict;
     use warnings;
     use Digest::MD5 qw(md5_hex);

     # /*
     #  * Hlquery::Utils::Auth - Internal authentication utilities.
     #  */

     # /* Generates an MD5-hashed token from a password. */

     sub GenerateToken 
     {
          my ($password) = @_;
          
          return md5_hex($password);
     }

     # /* Validates if a token is non-empty and defined. */

     sub IsValidToken 
     {
          my ($token) = @_;
          
          return defined $token && length($token) > 0;
     }

     # /* Returns the appropriate authentication header and value. */

     sub GetAuthHeader 
     {
          my ($token, $method) = @_;
          
          $method //= 'bearer';
          
          if ($method eq 'api-key') 
          {
               return { header => 'X-API-Key', value => $token };
          }
          
          return { header => 'Authorization', value => 'Bearer ' . $token };
     }

     1;
}

__END__

=head1 NAME

Hlquery::Utils::Auth - Internal authentication utilities for hlquery

=head1 DESCRIPTION

This module provides internal utility functions for authentication, including
token generation and header construction. It is not intended for direct use by users.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
