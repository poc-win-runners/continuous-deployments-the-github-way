FROM node:alpine

WORKDIR /workspace/build

COPY package*.json /workspace/build/
COPY *.mjs /workspace/build/

RUN npm install && npm run build

# -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

FROM nginx:alpine

COPY --from=0 /workspace/build/bundle.js /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
