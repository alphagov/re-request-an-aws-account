FROM ghcr.io/alphagov/govuk-ruby-builder:3.2 AS builder


# Default directory
ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

# Install rails

#RUN chown -R user:user /opt/app
WORKDIR /opt/app

COPY . .

RUN bundle install



# Run a shell
CMD ["/bin/bash"]
