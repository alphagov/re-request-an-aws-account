FROM ruby:3.1-slim
RUN apt-get update && apt-get install -y nodejs npm 

 
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



