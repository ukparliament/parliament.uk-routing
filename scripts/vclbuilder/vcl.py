import os

backend_vcl = """
backend {0} {{
    .host = "{1}";
    .port = "{2}";
    .probe = {{
        .url = "{3}";
        .timeout = 1s;
        .interval = 30s;
        .window = 3;
        .threshold = 2;
    }}
}}
"""

probe_urls = {
    "lists": "/404.html",
    "things": "/404.html",
    "utilities": "/404.html",
    "bandiera": None
}


class Backend(object):

    def __init__(self, name, data, url):
        self.name = name
        self.ip = data['ip']
        self.ports = data['ports']
        self.url = url

    def get_vcl(self):
        vcl = ''
        for port in self.ports:
            vcl += backend_vcl.format(self.name, self.ip, port, self.url)
        return vcl


class Director(object):

    def __init__(self, name):
        self.name = name
        self.backends = []

    def add_backend(self, data):
        index = len(self.backends) + 1
        backend_name = self.name + '_' + str(index)
        url = probe_urls.get(self.name, '/')
        if url:
            backend = Backend(backend_name, data, url)
            self.backends.append(backend)

    def get_vcl(self):
        vcl = []
        vcl.append(
            '    new {0} = directors.round_robin();'.format(self.name)
        )
        for backend in self.backends:
            vcl.append('    {0}.add_backend({1});'.format(self.name, backend.name))
        return os.linesep.join(vcl)


class VclFile(object):

    def __init__(self):
        self.directors = {}

    def add_backend(self, data):
        name = data['service']
        director = self.directors.get(name)
        if not director:
            director = Director(name)
            self.directors[name] = director
        director.add_backend(data)

    def get_vcl(self):
        vcl = [
            'import directors;',
            '',
        ]

        for director in self.directors.values():
            for backend in director.backends:
                vcl.append(backend.get_vcl())

        vcl.append('')
        vcl.append('sub init_backends {')

        for director in self.directors.values():
            vcl.append(director.get_vcl())

        vcl.append('}')
        return os.linesep.join(vcl)
