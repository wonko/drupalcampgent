/* 	Openminds default varnish config from CHEF
	Leave this marker in, or it will get overwritten on the next run 
	45de855637935beabc1e5f4b89ef8ff4 
*/

include "/etc/varnish/extras.vcl";

backend default {
    .host = "127.0.0.1";
    .port = "8000";
}

sub vcl_recv {
	if (req.restarts == 0) {
       if (req.http.x-forwarded-for) {
           set req.http.X-Forwarded-For =
               req.http.X-Forwarded-For ", " client.ip;
       } else {
           set req.http.X-Forwarded-For = client.ip;
       }
     }

	/* server status should not be cached! */
	if(req.url ~ "^\/server-status") {
		return (pass);
	}

	/* NEVER cache certain urls */
	/* 
    if (req.url ~ "\/(manage|beheer|gestion|admin)" ) {
            return(pass);
    }
	*/

	/* exclude virtual hosts from caching */
	/* 
	if (req.http.Host ~ "^some.virtualhost.tld") {
		return (pipe);
	}
	*/

	/* don't use deflate on already compressed items */
	if (req.http.Accept-Encoding) {
		if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
			remove req.http.Accept-Encoding;
		} elsif (req.http.Accept-Encoding ~ "gzip") {
			set req.http.Accept-Encoding = "gzip";
		} elsif (req.http.Accept-Encoding ~ "deflate") {
			set req.http.Accept-Encoding = "deflate";
		} else {
			remove req.http.Accept-Encoding;
		}
	}

	/* never use cookies on images */
	if (req.url ~ "\.(css|ico|pdf|jpg|png|js|ttf)(\?[0-9]+)?$") {
		unset req.http.cookie;
		return (lookup);
	}

	/* clean up cookies */
	/*
	// Remove has_js and Google Analytics __* cookies.
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js)=[^;]*", "");
    // Remove a ";" prefix, if present.
    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");

    // remove a specific cookie
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)cookiename=[^;]*", "");

    // Remove empty cookies.
    if (req.http.Cookie ~ "^\s*$") {
            unset req.http.Cookie;
    }
    */

	/* rework the virtual host to strip the port and the possible www prefix */
	set req.http.Host = regsub(req.http.Host, ":[0-9]*$", "");
	set req.http.Host = regsub(req.http.Host, "^www\.", "");

	/* example to hard cache everything on staticX.domain.tld (and strip the cookies) */
    /*
	if (req.http.Host ~ "^static[0-9]") {
		unset req.http.cookie;
		return (lookup);
	}
	*/
	
} /* vcl_recv end */

sub vcl_fetch {
	if (beresp.status == 404 || beresp.status == 503 || beresp.status == 500) {
		set beresp.http.X-Cacheable = "NO: beresp.status";
		set beresp.http.X-Cacheable-status = beresp.status;
		return (pass);
	}

	/* */
    if (req.url ~ "\/(manage|beheer|gestion|admin)" ) {
            set beresp.http.X-Cacheable = "NO: admin";
            set beresp.http.X-Cacheable-sc = beresp.http.set-cookie;
            return(pass);
    }

	/* by default, if we have content, and the backend is dead, hold on to the content for 10 minutes */
	set beresp.grace = 600s;

	/* standaard cache regels, 60 minuten voor gewone content, en de browser mag het ook 60 minuten bijhouden */
	set beresp.ttl = 60m;
	set beresp.http.cache-control = "max-age = 3600";

	/* maar images, css, js... mogen wat langer */
	if (req.url ~ "\.(css|ico|pdf|jpg|png|js|ttf)(\?[0-9]+)?$") {
		unset beresp.http.set-cookie;
		set beresp.ttl = 6h;
		set beresp.http.cache-control = "max-age = 21600";
	}

	/* static example (see above) */
    /*
    if (req.http.Host ~ "^static[0-9]") {
		unset beresp.http.set-cookie;
 		set beresp.ttl = 5d;
		set beresp.http.cache-control = "max-age = 432000";
	}
	*/

	/* example for a virtual host, and a specific folder at once... */
	/*
	if (req.http.Host ~ "somedomain\.tld") {
		if(req.url ~ "^\/cachemehard\/") {
			unset beresp.http.set-cookie;
			set beresp.ttl = 30d;
			set beresp.http.cache-control = "max-age = 2592000";
		}
	}
	*/

	if (beresp.cacheable) {
		/* Remove Expires from backend, it's not long enough */
		unset beresp.http.expires;
		unset beresp.http.vary;

		/* marker for vcl_deliver to reset Age: */
		set beresp.http.magicmarker = "1";
	}

} /* vcl_fetch end */

sub vcl_deliver {
	if (resp.http.magicmarker) {
		/* Remove the magic marker */

		unset resp.http.magicmarker;
		/* By definition we have a fresh object */
		set resp.http.age = "0";
	}

	if (obj.hits > 0) {
		set resp.http.X-Cache = "HIT";
		set resp.http.X-Cache-Hits = obj.hits;
	} else {
		set resp.http.X-Cache = "MISS";
	}
}

# 
# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
# 
# sub vcl_recv {
#     if (req.restarts == 0) {
#       if (req.http.x-forwarded-for) {
#           set req.http.X-Forwarded-For =
#               req.http.X-Forwarded-For ", " client.ip;
#       } else {
#           set req.http.X-Forwarded-For = client.ip;
#       }
#     }
#     if (req.request != "GET" &&
#       req.request != "HEAD" &&
#       req.request != "PUT" &&
#       req.request != "POST" &&
#       req.request != "TRACE" &&
#       req.request != "OPTIONS" &&
#       req.request != "DELETE") {
#         /* Non-RFC2616 or CONNECT which is weird. */
#         return (pipe);
#     }
#     if (req.request != "GET" && req.request != "HEAD") {
#         /* We only deal with GET and HEAD by default */
#         return (pass);
#     }
#     if (req.http.Authorization || req.http.Cookie) {
#         /* Not cacheable by default */
#         return (pass);
#     }
#     return (lookup);
# }
# 
# sub vcl_pipe {
#     # Note that only the first request to the backend will have
#     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#     # have it set for all requests, make sure to have:
#     # set bereq.http.connection = "close";
#     # here.  It is not set by default as it might break some broken web
#     # applications, like IIS with NTLM authentication.
#     return (pipe);
# }
# 
# sub vcl_pass {
#     return (pass);
# }
# 
# sub vcl_hash {
#     set req.hash += req.url;
#     if (req.http.host) {
#         set req.hash += req.http.host;
#     } else {
#         set req.hash += server.ip;
#     }
#     return (hash);
# }
# 
# sub vcl_hit {
#     if (!obj.cacheable) {
#         return (pass);
#     }
#     return (deliver);
# }
# 
# sub vcl_miss {
#     return (fetch);
# }
# 
# sub vcl_fetch {
#     if (!beresp.cacheable) {
#         return (pass);
#     }
#     if (beresp.http.Set-Cookie) {
#         return (pass);
#     }
#     return (deliver);
# }
# 
# sub vcl_deliver {
#     return (deliver);
# }
# 
# sub vcl_error {
#     set obj.http.Content-Type = "text/html; charset=utf-8";
#     synthetic {"
# <?xml version="1.0" encoding="utf-8"?>
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html>
#   <head>
#     <title>"} obj.status " " obj.response {"</title>
#   </head>
#   <body>
#     <h1>Error "} obj.status " " obj.response {"</h1>
#     <p>"} obj.response {"</p>
#     <h3>Guru Meditation:</h3>
#     <p>XID: "} req.xid {"</p>
#     <hr>
#     <p>Varnish cache server</p>
#   </body>
# </html>
# "};
#     return (deliver);
# }
