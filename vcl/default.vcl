vcl 4.0;

# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.

include "/vcl/backends.vcl";

sub vcl_init {
  call init_backends;
}

sub vcl_recv {
  if(req.url == "/" || req.url == "/robots.txt" || req.url ~ "^/resource" || req.url ~ "^/mps" || req.url ~ "^/meta" || req.url ~ "^/search" || req.url ~ "^/postcodes" || req.url ~ "^/cookie_policy" || req.url ~ "^/find-your-constituency" || req.url ~ "^/who-should-i-contact-with-my-issue") {
    set req.backend_hint = utilities.backend();
  } else if(req.url ~ "(people|constituencies|parties|parliaments|media|houses|contact-points|media|articles|groups|concepts|collections)/\w{8}(\..*)?$") {
    set req.backend_hint = things.backend();
  } else if(req.url ~ "^/petition-a-hybrid-bill") {
    set req.backend_hint = things.backend();
  } else if(req.url ~ "^/(people|constituencies|parties|parliaments|media|houses|contact-points|media|articles|groups)/lookup") {
    set req.backend_hint = things.backend();
  } else if(req.url ~ "^/constituencies/postcode_lookup" || req.url ~ "^/people/postcode_lookup") {
    set req.backend_hint = things.backend();
  } else if(req.url ~ "(parliaments)/\w{8}/(previous|next)(\..*)?$" || req.url ~ "(parliaments/(current|next|previous)(\..*)?)$") {
    set req.backend_hint = things.backend();
  } else if(req.url ~ "(constituencies/map)(\..*)?$" || req.url ~ "(constituencies)/\w{8}/(map)(\..*)?$" || req.url ~ "constituencies/current/map(\..*)?$"){
    set req.backend_hint = things.backend();
  } else if(req.url ~ "(.ico|.jpeg|.gif|.svg|.jpg|.png|.css|.js)$") {
    set req.backend_hint = utilities.backend();
  } else if(req.url ~ "/places$" || req.url ~ "^/places/regions" || req.url ~ "places/\w+/constituencies$") {
    set req.backend_hint = lists.backend();
  } else if(req.url ~ "/places/(E|S|W)\w{8}$") {
    set req.backend_hint = things.backend();
  } else {
    set req.backend_hint = lists.backend();
  }

  return (pass);
}
