vcl 4.0;

# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.

import var;

include "/vcl/backends.vcl";

sub vcl_init {
  call init_backends;
}

sub vcl_recv {
  # We want to route our URLs, ignoring query string values. We use var.get("url") for comparison, rather than req.url.
  var.set("url", regsub(req.url, "\?.*", ""));

  if(var.get("url") == "/" || var.get("url") == "/robots.txt" || var.get("url") ~ "^/resource" || var.get("url") ~ "^/mps" || var.get("url") ~ "^/meta" || var.get("url") ~ "^/search" || var.get("url") ~ "^/postcodes" || var.get("url") ~ "^/cookie_policy" || var.get("url") ~ "^/find-your-constituency" || var.get("url") ~ "^/who-should-i-contact-with-my-issue" || var.get("url") ~ "^/statutory-instruments") {
    set req.backend_hint = utilities.backend();
  } else if(var.get("url") ~ "(people|constituencies|parties|parliaments|media|houses|contact-points|media|articles|groups|concepts|collections|questions|procedures|work-packages)/\w{8}(\..*)?$") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "^/petition-a-hybrid-bill") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "^/(people|constituencies|parties|parliaments|media|houses|contact-points|media|articles|groups)/lookup") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "^/constituencies/postcode_lookup" || var.get("url") ~ "^/people/postcode_lookup") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "(parliaments)/\w{8}/(previous|next)(\..*)?$" || var.get("url") ~ "(parliaments/(current|next|previous)(\..*)?)$") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "(constituencies/map)(\..*)?$" || var.get("url") ~ "(constituencies)/\w{8}/(map)(\..*)?$" || var.get("url") ~ "constituencies/current/map(\..*)?$"){
    set req.backend_hint = things.backend();
  } else if(var.get("url") ~ "(.ico|.jpeg|.gif|.svg|.jpg|.png|.css|.js)$") {
    set req.backend_hint = utilities.backend();
  } else if(var.get("url") ~ "/places$" || var.get("url") ~ "^/places/regions" || var.get("url") ~ "places/\w+/constituencies$") {
    set req.backend_hint = lists.backend();
  } else if(var.get("url") ~ "/places/(E|S|W)\w{8}$") {
    set req.backend_hint = things.backend();
  } else if(var.get("url") == "/health-check") {
    return(synth(853, "OK"));
  } else {
    set req.backend_hint = lists.backend();
  }

  return (pass);
}

sub vcl_synth {
  if (resp.status == 853) {
    set resp.status = 200;
    set resp.http.Content-Type = "text/plain";
    synthetic("OK");
    return(deliver);
  }
}
