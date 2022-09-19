ARG base_image="docker.elastic.co/kibana/kibana"
ARG version="7.17.1"

FROM alpine:3.7 as builder
ARG version="7.17.1"
COPY kibana /kibana
RUN sed -i "7s/.*/    \"version\": \"${version}\"/" /kibana/rwi_style/package.json
RUN apk add --no-cache zip
RUN zip -r /rwi_style.zip kibana

FROM $base_image:$version
MAINTAINER nick@runwithitsynthetics.com

# custom favicons
COPY favicons/* /usr/share/kibana/src/legacy/ui/public/assets/favicons/
COPY logo_rwi_kibana.png /usr/share/kibana/node_modules/@elastic/eui/src/components/icon/assets/logo_kibana.png
COPY logo_rwi_kibana.png /usr/share/kibana/node_modules/@elastic/eui/lib/components/icon/assets/logo_kibana.png

# custom throbber
RUN sed -i 's/Loading Kibana/Loading Runwithit Synthetics/g' /usr/share/kibana/src/core/server/rendering/views/template.js
# To customize throbber logo open main.less and edit .kibanaWelcomeLogo { background-image: url(xxx); }

# custom HTML title information
RUN sed -i 's/title Kibana/title Runwithit Synthetics/g' /usr/share/kibana/src/legacy/server/views/index.pug


# custom plugin css
COPY --from=builder /rwi_style.zip /
RUN sed -i 's/reverse()/reverse(),`${regularBundlePath}\/rwi_style.style.css`/g' /usr/share/kibana/src/legacy/ui/ui_render/ui_render_mixin.js

# Modify logoKibana in vendorsDynamicDLL to be empty. Custom icon will be set as background-image in rwi_style plugin css

RUN sed -i 's@evenodd"}.*)))},@evenodd"}))},@g' /usr/share/kibana/node_modules/@kbn/ui-shared-deps/target/icon.logo_kibana-js.js


RUN bin/kibana-plugin install file:///rwi_style.zip
RUN bin/kibana --env.name=production --logging.json=false --optimize
