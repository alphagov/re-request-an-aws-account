FROM timbru31/ruby-node@sha256:4ffd5f07be681e35ebeec21f966de45adc3b7fcd10ba17a2600bfad4fdf9ebee
 
# Default directory
ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH

# Install rails

#RUN chown -R user:user /opt/app
WORKDIR /opt/app

COPY . .

RUN bundle install
RUN npm install

EXPOSE 3000

# Run a shell
#CMD ["bundle", "exec", "rails", "server"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]



