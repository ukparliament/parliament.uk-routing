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
    set req.backend_hint = utilities;
  } else if(req.url == "^/people/a-z") {
    set req.backend_hint = lists;
  } else if(req.url == "^/people/members") {
    set req.backend_hint = lists;
  } else if(req.url == "^/people/current") {
    set req.backend_hint = lists;
  } else if(req.url == "^/parties/a-z") {
    set req.backend_hint = lists;
  } else if(req.url == "^/constituencies/current/a-z/*") {
    set req.backend_hint = lists;
  } else if(req.url == "^/constituencies/a-z") {
    set req.backend_hint = lists;
  } else if(req.url == "^/constituencies/current") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/houses/*/members/current/a-z/*") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/houses/*/parties/current") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/houses/*/parties/*/*") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parties/*/*$") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parliaments/*/members") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parliaments/*/houses") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parliaments/*/houses/*/parties") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parliaments/*/parties") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/parliaments/*/constituencies") {
    set req.backend_hint = lists;
  } else if(req.url == "^/media") {
    set req.backend_hint = lists;
  } else if(req.url == "^/places") {
    set req.backend_hint = lists;
  } else if(req.url == "^/places/regions") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/places/*/constituencies") {
    set req.backend_hint = lists;
  } else if(req.url == "^/people/lookup") {
    set req.backend_hint = things;
  } else if(req.url == "^/people/postcode_lookup") {
    set req.backend_hint = things;
  } else if(req.url == "^/parties/lookup") {
    set req.backend_hint = things;
  } else if(req.url == "^/constituencies/lookup") {
    set req.backend_hint = things;
  } else if(req.url == "^/constituencies/postcode_lookup") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/constituencies/*/map") {
    set req.backend_hint = things;
  } else if(req.url == "^/houses/lookup") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/houses/*/parties/*") {
    set req.backend_hint = things;
  } else if(req.url == "^/parliaments/current") {
    set req.backend_hint = things;
  } else if(req.url == "^/parliaments/lookup") {
    set req.backend_hint = things;
  } else if(req.url == "^/parliaments/previous") {
    set req.backend_hint = things;
  } else if(req.url == "^/parliaments/next") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/next") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/previous") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/houses/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "/people/*/*$") {
    set req.backend_hint = lists;
  } else if(req.url ~ "/parties/*/*$") {
    set req.backend_hint = lists;
  } else if(req.url ~ "/constituencies/*/*$") {
    set req.backend_hint = lists;
  } else if(req.url ~ "^/houses/*/*") {
    set req.backend_hint = lists;
  } else if(req.url ~ "/parliaments/*/*$") {
    set req.backend_hint = lists;
  # Explicit use of 8 character wildcard for people, parties, constituenices and parliaments
  # differs from ALB rules, as Varnish regex execution differs from ALB
  } else if(req.url ~ "/people/\w{8}$") {
    set req.backend_hint = things;
  } else if(req.url ~ "/parties/\w{8}$") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/postcodes/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "/constituencies/\w{8}$") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/contact-points/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/houses/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/houses/*/parties/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/houses/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/parliaments/*/parties/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "/parliaments/\w{8}$") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/media/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/places/*") {
    set req.backend_hint = things;
  } else if(req.url ~ "^/petition-a-hybrid-bill") {
    set req.backend_hint = things;
  } else if(req.url ~ "/articles/\w{8}$") {
    set req.backend_hint = things;
  } else {
    set req.backend_hint = lists;
  }
}
