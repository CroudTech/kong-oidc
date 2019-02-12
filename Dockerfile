FROM kong:0.14.1-alpine
RUN apk add --update \
    gcc \
    libc-dev\
    git \
    openssl-dev \
    unzip

# Kong install dir
ENV KONG_HOME /usr/local/share/lua/5.1/kong

# Install OIDC plugin
RUN git clone https://github.com/CroudTech/kong-oidc.git $KONG_HOME/plugins/kong-oidc && \
    (cd $KONG_HOME/plugins/kong-oidc/ && luarocks make)

# # Install CroudTech request-transformer plugin
# RUN git clone https://github.com/CroudTech/devops-kong-plugin-croudtech-request-transformer.git $KONG_HOME/plugins/croudtech-request-transformer && \
#     (cd $KONG_HOME/plugins/croudtech-request-transformer/ && luarocks make)
RUN luarocks install lua-resty-redis-connector && \
    luarocks install kong-plugin-proxy-cache

ENV KONG_PLUGINS=bundled,oidc,proxy-cache

# Patch NGINX config to set the session secret
RUN sed -i '/rewrite_by_lua_block/i \\tset $session_secret nil;\n' /usr/local/share/lua/5.1/kong/templates/nginx_kong.lua


