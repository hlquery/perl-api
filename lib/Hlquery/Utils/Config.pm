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

package Hlquery::Utils::Config
{
     use strict;
     use warnings;
     use URI;

     use constant DEFAULT_TIMEOUT     => 30;
     use constant DEFAULT_BASE_URL    => 'http://localhost:9200';
     use constant DEFAULT_AUTH_METHOD => 'bearer';
     use constant DEFAULT_POOL        => 1;
     use constant DEFAULT_LAZY        => 0;

     # /*
     #  * Hlquery::Utils::Config - Internal configuration utilities.
     #  */

     # /* Merges user-provided options with default configuration values. */

     sub merge_defaults 
     {
          my ($user_options) = @_;
          
          $user_options = {} unless $user_options;
          
          my $defaults = 
          {
               timeout     => DEFAULT_TIMEOUT,
               base_url    => DEFAULT_BASE_URL,
               auth_method => DEFAULT_AUTH_METHOD,
               token       => undef,
               pool        => DEFAULT_POOL,
               lazy        => DEFAULT_LAZY
          };
          
          foreach my $key (keys %$user_options) 
          {
               $defaults->{$key} = $user_options->{$key};
          }
          
          return $defaults;
     }

     # /* Checks if a given string is a valid URL. */

     sub is_valid_url 
     {
          my ($url) = @_;
          
          return 0 unless defined $url && length($url) > 0;
          
          eval 
          {
               my $uri = URI->new($url);
               
               return defined($uri->scheme) && defined($uri->host) && length($uri->scheme) > 0 && length($uri->host) > 0;
          };
          
          return 0 if $@;
          
          return 1;
     }

     # /* Normalizes a URL by removing trailing slashes. */

     sub normalize_url 
     {
          my ($url) = @_;
          
          $url =~ s/\/$//;
          
          return $url;
     }

     1;
}

__END__

=head1 NAME

Hlquery::Utils::Config - Internal configuration utilities for hlquery

=head1 DESCRIPTION

This module provides internal utility functions for handling configuration,
merging defaults, and validating URLs. It is not intended for direct use by users.

=head1 AUTHOR

Carlos F. Ferry <carlos.ferry@gmail.com>

=cut
