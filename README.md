# Dancer2_AD-LDAP_Auth
How to use Active Directory authentication for Dancer2 apps.

## Purpose
To provide a simple, easy to copy (via `git clone`) template for integrating Active 
Directory authentication into Dancer 2 applications.  This example uses 
[https://metacpan.org/pod/Dancer2::Plugin::Auth::Extensible::Provider::LDAP](`Dancer2::Plugin::Auth::Extensible::Provider::LDAP`) 
rather than `Dancer2::Plugin::Auth::Extensible::Provider::ActiveDirectory`, because 
I found the LDAP module to be a bit more flexible with regards to ldap**s** (at 
least in the documentation), as well as allowing which field to use as the name 
attribute (allows the ability to require @domain.com in the login).

## Description
This example has the following pages:
1. The root page (`/`). This is visible to all users.
1. The`/protected` page, which is only accessible to authenticated AD users.
1. The `admins` page, which is only accessible to members of the Domain Admins group.

There are also pages for login, logout, permission required, etc.  These are all provided 
by the [https://metacpan.org/pod/Dancer2::Plugin::Auth::Extensible](`Dancer2::Plugin::Auth::Extensible`)
(aka D2AE) module.

There are also a few niceties that have been added by manipulating the templates so that 
the root page says if you are logged in, the right hand menu has the appropriate "Login" 
or "Logout" button on all pages, etc.

## Configuration
The LDAP configuration is stored in the `/config_local.yml` file. Because this file contains 
user credentials, there is no copy of it here.  There is, however a `config_local.yml.example` 
file, so to start, `cd` to the repository and:
```cp config_local.yml.example config_local.yml```

Breaking this down line by line:
```
plugins:
    Auth::Extensible:
        realms:
```
The first three lines are the information about the plugin configuration.  These can be left as-is.
```
            ldap:
```
This line is the name of the realm to be used.  The value of `ldap:` here is entirely arbitrary,
and it could just as easily have ben `ad:` or `domain.com:` or `foo:`.  A noteable featue of D2AE is 
that it can support multiple realms.  Have some users in Active Directory, and some users in a SQL 
database?  D2AE can handle that.  Each location where users could be found is a separate 'realm', and 
each realm needs a name by which it can be referenced.  Here, that name is `ldap`.
```
                provider: LDAP
```
This is what instructs Dancer2 to use 
[https://metacpan.org/pod/Dancer2::Plugin::Auth::Extensible::Provider::LDAP](`Dancer2::Plugin::Auth::Extensible::Provider::LDAP`)
```
                host: ldaps://domain-controller.domain.com
```
The hostname (or IP address) of your domain controllers.  This is using secure LDAP (LDAPS).  If 
you weren't concerned about security, you could use `ldap://` or just the hostname alone.  Port 636 
is assumed if using LDAPS.
```
                basedn: "dc=domain,dc=com"
```
This is the location to *start* the Active Directory search.  If you have users spread amongst a 
number of OUs, you might want to keep this at the top level of your domain as shown here.  If you 
want to restrict the search to the 'Users" OU, then you might use "CN=Users,dc=domain,dc=com".  To 
find the specific value to use, right click on the OU in *Active Directory Users and Computers*, select 
*properties*, then find the *distinguishedName* field on the *Attribute Editor* tab.
```
                binddn: ldap-bind-user@domain.com
                bindpw: REDACTED
```
A user is required to make the connection to Active Directory. This user can be fairly low permissions, however 
it will need to be able to see the list of users within the OU selected as the `basedn`.
```
                username_attribute: userPrincipalName
```
If using `userPrincipalName` here, then users will need to log into the webapp with their fully 
qualified login name (example: *someone@domain.com*).  If you'd prefer to have users only need 
to use the username portion, then try using `sAMAccountName` instead. Note that if you are using 
multiple active directory realms, etc., it might be best to force the full name disambiguate 
the username portion appearing in multiple places.
```
                role_attribute: name
                role_filter: '(objectClass=group)'
```
The `role_attribute` and `role_filter` properties combine to allow Active Directory security groups 
to be mapped to Dancer2 user roles.  The values here state to use the name of the group as the 
role name.

## Usage
### The routes:
The logic for the app is stored in `lib/ldap.pm`, and provides the three simple routes.

The root route, has no call for authentication.
```perl
get '/' => sub {
```

The protected route simply requires that the user be logged in:
```
any ['get', 'post'] =>'protected' => require_login sub {
```

The admin route requires that the user be a member of the `Domain Admins` Active 
Directory group.
```perl
any ['get', 'post'] => '/admins' => require_role 'Domain Admins' => sub {
```

### The pages
Each route uses the `index.tt` template.  I've modified the default dancer index template 
only slightly:
1. I've moved the list of links in the "Join the Community" section from within `index.tt` to being
included from the file `linklist.tt`.  This will provide for easier editing of this small list 
if needed.
1. Each route sends a `tt_body` parameter to the `index.tt` template. If found, then the body will load 
from a file matching that name.  If the value is not set, then the default dancer index page text 
will b displayed.

### Dynamic values
The `session.logged_in_user` parameter can be used in the template to check if the user is logged in 
or not.  This allows the first value in the right hand list to display "Login" if the user is logged out, 
and "Logout" if the user is logged in.  The list (again, imported from `linklist.tt`) is simply:
```html
<li>
  <% IF session.logged_in_user %>
    <a href="logout">Logout</a></li>
  <% ELSE %>
    <a href="login">Login</a>
  <% END %>
</li>
<li><a href="http://perldancer.org/">PerlDancer</a></li>
<li><a href="http://twitter.com/PerlDancer/">Official Twitter</a></li>
<li><a href="https://github.com/PerlDancer/Dancer2/">GitHub Community</a></li>

```
