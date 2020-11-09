ARG BASE_IMAGE=rocker/geospatial:latest

# Install fonts, Chromium and graphics utils
RUN apt-get update \
    && apt-get -qq install gnupg \
    && sh -c 'echo "deb http://http.us.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC \
    && apt-get update \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get -qq install --no-install-recommends \
       ttf-mscorefonts-installer \
       fonts-liberation \
       fonts-freefont-ttf \
       libssl-dev \
       chromium \
       imagemagick \
       libmagick++-dev \
       ghostscript \
       libgs-dev \
       librsvg2-dev \
       libwebp-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb

COPY . /var/local/R/devpkg

COPY docker/check.r docker/coverage.r /usr/local/bin/
RUN chmod +x /usr/local/bin/check.r \
    && chmod +x /usr/local/bin/coverage.r

RUN Rscript -e "remotes::install_deps('/var/local/R/devpkg', dependencies = TRUE)"

FROM build-env AS production-env

RUN Rscript -e "devtools::install('/var/local/R/devpkg')" \
    && rm -rf /var/local/R \
    && rm /usr/local/bin/check.r /usr/local/bin/coverage.r
