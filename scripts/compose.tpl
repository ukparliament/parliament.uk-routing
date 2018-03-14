import directors;

backend lists_server {
    .host = "$LIST_BACKEND_IP";
    .port = "$LIST_BACKEND_PORT";
    .probe = {
        .url = "/";
        .timeout = 1s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
}

backend things_server {
    .host = "$THING_BACKEND_IP";
    .port = "$THING_BACKEND_PORT";
    .probe = {
        .url = "/";
        .timeout = 1s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
}

backend utilities_server {
    .host = "$UTILITIES_BACKEND_IP";
    .port = "$UTILITIES_BACKEND_PORT";
    .probe = {
        .url = "/";
        .timeout = 1s;
        .interval = 5s;
        .window = 5;
        .threshold = 3;
    }
}

sub init_backends {
    new lists = directors.round_robin();
    lists.add_backend(lists_server);
    new things = directors.round_robin();
    things.add_backend(things_server);
    new utilities = directors.round_robin();
    utilities.add_backend(utilities_server);
}