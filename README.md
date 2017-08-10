
# parliament.uk-routing
[Parliament.uk-routing][parliament.uk-routing] is a [Varnish][varnish] application designed to replicate the routing of the [Application Load Balancer][alb] in the development environment. It handles the routing between the three applications that make up the new [parliament.uk][parliament.uk] website made by the [Parliamentary Digital Service][parliamentary-digital-service].

The [parliament.uk-routing][parliament.uk-routing] application routes between the [Utilities][utilities], [Things][things] and [Lists][lists] applications based on the url route, following the rules of the [Varnish][varnish] regex in the `default.vcl` file.

### Contents
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Running the application](#running-the-application)
- [Running the tests](#running-the-tests)
- [Contributing](#contributing)
- [License](#license)

## Requirements
[Parliament.uk-routing][parliament.uk-routing] requires [Docker][docker].

You will also need to have cloned the [Utilities][utilities], [Things][things] and [Lists][lists] applications locally, within the same directory.


## Getting Started
In this application, [Docker][docker] is dependent on the three rails applications all sitting in the same folder as the [Parliament.uk-routing][parliament.uk-routing] application, so make sure to clone the repository in the same directory as [Utilities][utilities], [Things][things] and [Lists][lists]. Your folder structure should look like this:
```bash
/example_folder
    /parliament.uk-lists
    /parliament.uk-utilities
    /parliament.uk-things
    /parliament.uk-routing
```

You will need environment variables set up locally in order to run the application.

Clone the repository locally using:
```bash
git clone https://github.com/ukparliament/parliament.uk-routing.git
cd parliament.uk-routing
```

## Running the application
Running the application locally is done using docker-compose. In order to set up the application, you will need to run:
```bash
docker-compose up --build
```

This command will build the dependent images and databases including those for the three rails applications, [Utilities][utilities], [Things][things] and [Lists][lists].  

Once docker has stored these images and containers, you can restart the application by running:
```bash
docker-compose up
```

The application will then be available from http://localhost:80, and the [Parliament.uk-routing][parliament.uk-routing] will automatically route to the three rails applications at http://localhost:3000.

If changes are made to the Gemfile of the three rails applications or to the `default.vcl` file within the [Parliament.uk-routing][parliament.uk-routing], you may need to rebuild Docker's images. In order to do this you can remove containers:
```bash
docker rm name_of_container
```
and remove images:
```bash
docker rmi -f name_of_image
```
for those that will need to be rebuilt.

To rebuild them, you can either rebuild them individually, eg:
```bash
docker-compose build utilities.parliament.local
```
or rebuild the entire set of docker images and databases again, with
```bash
docker-compose up --build
```

## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License
[Parliament.uk-routing][parliament.uk-routing] is available as open source under the terms of the [Open Parliament Licence][info-license].

[parliament.uk-routing]: https://github.com/ukparliament/parliament.uk-routing
[parliamentary-digital-service]:   https://github.com/ukparliament
[parliament.uk]:                   http://www.parliament.uk/
[varnish]:                         http://www.varnish-cache.org/docs/2.1/index.html
[alb]:                             https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/
[docker]:                          https://www.docker.com/
[utilities]:                       https://github.com/ukparliament/parliament.uk-utilities
[things]:                          https://github.com/ukparliament/parliament.uk-things
[lists]:                           https://github.com/ukparliament/parliament.uk-lists

[info-license]:   http://www.parliament.uk/site-information/copyright/open-parliament-licence/
[shield-license]: https://img.shields.io/badge/license-Open%20Parliament%20Licence-blue.svg
