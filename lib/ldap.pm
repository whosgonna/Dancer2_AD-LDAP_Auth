package ldap;
use Dancer2;
use Dancer2::Session::Simple;
use lib '/usr/home/ben/Dancer2-Plugin-Auth-Extensible/lib/';
use Dancer2::Plugin::Auth::Extensible;
use Dancer2::Plugin::Auth::Extensible::Provider::LDAP;
use Data::Printer;

our $VERSION = '0.1';

get '/' => sub {
    my $header = "The Root Page!";
    template 'index' => { 'title' => 'ldap', tt_body => 'root.tt', header => $header};
};

any ['get', 'post'] =>'protected' => require_login sub {
    my $header = "This Page Is Protected";
    template 'index' => { 'title' => 'proteted', header => $header, tt_body => 'protected.tt' };

};

any ['get', 'post'] => '/admins' => require_role AltiGenAdministrators => sub {
    my $output = {
        title   => 'Admins Only',
        header  => 'This Page Is Only for Administrators',
        tt_body => 'admins.tt'
    };
    template 'index' => $output;
};



true;
