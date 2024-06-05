ARG RUBY_VERSION=3.2.4

FROM docker.io/library/ruby:$RUBY_VERSION

RUN apt-get update -qq && apt-get install -y build-essential libvips gnupg2 curl git libssl-dev vim libsasl2-dev

ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_DEPLOYMENT="1"

# Ensure node.js 20 is available for apt-get
ARG NODE_MAJOR=20
RUN apt-get update && \
    mkdir -p /etc/apt/keyrings && \
    curl --fail --silent --show-error --location https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Install node and yarn
RUN apt-get update -qq && apt-get install -y nodejs && npm install -g yarn

# Mount $PWD to this workdir
WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v '~> 2.5'
RUN gem update --system

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY package.json yarn.lock ./
RUN yarn install

COPY . .

# Ensure binding is always 0.0.0.0, even in development, to access server from outside container
ENV BINDING="0.0.0.0"
EXPOSE 3000

# Overwrite ruby image's entrypoint to provide open cli
ENTRYPOINT [""]