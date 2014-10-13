Ruby Web Service Template
=========================

A template for building web services with Ruby and Sinatra.

Setup
-----

    # clone the repo
    git clone git@github.com:CXInc/ruby-web-service-template.git

    # remove .git directory so it's just the files and not the git repo
    rm -rf ruby-web-service-template/.git

    # rename
    mv ruby-web-service-template <your-service-name>

    # start a new git repo
    cd <your-service-name>
    git init

At this point it should be ready to start building your service.

Running
-------

    rackup

Testing
-------

    rake
