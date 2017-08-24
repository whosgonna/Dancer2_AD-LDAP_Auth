#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use ldap;

ldap->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    ldap->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use ldap;
use Plack::Builder;

builder {
    enable 'Deflater';
    ldap->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use ldap;
use ldap_admin;

builder {
    mount '/'      => ldap->to_app;
    mount '/admin'      => ldap_admin->to_app;
}

=end comment

=cut

