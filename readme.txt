Wtf?
----

Material used to present a DrupalCampGent - Performance for large and small sites.

Live demo with JMeter measurements, most of it fair.

Created by Bernard & Openminds Devops team - Twitter: @wonko_be & @openminds

Re-use granted, but include a source notice somewhere, and send me a message with a link/... if possible

Setup
-----

- Make sure your box has all the debs downloaded if you're presenting offline
- Host-only networking - fix your hosts files (both in the box, and on your machine)
- Drupal: download core, devel, boost and memcached modules
- Drupal setup: install, devel module enable, devel generate enable
- Generate content: 1000 terms, 5 vocs, 2000 users, 5000 nodes 

- Get the memcached settings from the drupal memcache module site.

Todo
----

- dotdebs gebruiken, met php-fpm

Preso Flow
----------

chef-solo -c solo.rb -j apache_basic.json

5 threads - basic apache2 - 4 per seconde
15 threads - basic apache2 - 51 per minuut - thrasing

chef-solo -c solo.rb -j mysql_tuned.json

5 threads - basic tuned mysql - 5 per seconde
15 threads - basic tuned mysql - 56 per minuut - thrashing


Opm: maakt niet veel uit, door lage scale, maar wel minder io

chef-solo -c solo.rb -j xcache.json

5 threads - xcache - 14 per seconde
15 threads - xcache - 13 per seconde - thrashing

Opm: verbruikt geheugen, goede php-management om geheugen niet per php-proces maar shares te maken

purge xcache

enable caching in drupal (config, performance, cache, twee vinkjes)

rand 100 - 5 clients - 100 loops - 5.2 per seconde

15 threads - drupal cache - 
- ongelooflijk veel trager -> cache hitrate is niet efficient!

Opm: hot vs cold cache

rand 100 - 5 clients - 100 loops - 20 per seconde

- 2de run met "hot cache" - 30 per seconde
- 15 clients - 30 per seconde, maar zonder trashing normaal

chef-solo -c solo.rb -j xcache.json

xcache erbij met een "hot cache"

- 15 clients - 100 per seconde, nog steeds geen trashing
- 25 clients - 100 per seconde, nog steeds geen trashing

Opm: maakt dus veel invloed, meer in percentage door het kortere stack-pad

xcache er terug af

Memcache installeren, inschakelen (module inschakelen, in config verzetten)

- 1e run verwijderen
- 2de run - 90 per seconde (15 threads, 100 loops)

xcache er terug bij

- 2de run - 100 per seconde... xcache doet er hier niet meer zoveel toe... ?

Memcache is wat "in limbo" - wordt maar interessant eens we naar grotere setups gaan, of als de database al genoeg te doen heeft... Duidelijk wel te zien op IO dat bij cold cache er quasi geen io is.

boost (inschakelen, .htaccess genereren, pasten - let op, eerst memcache uit, dan saven, dan boost aan, dan saven, dan cache purgen)

5 clients, 10 loops - 17 per seconde, en zwaardere IO
25 clients, 100 loops - 270 per seconde
35 clients, 100 loops - 430 per seconde

PHP is weg uit de oplossing, en php is gewoon traag

Varnish 
- 20 MB cache - 50 clients - 1400 per seconde - TURBO!!1!1

That's all folks!