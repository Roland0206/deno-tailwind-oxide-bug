FROM denoland/deno:2.5.0

WORKDIR /app

COPY package.json deno.json deno.lock ./

RUN deno install --allow-scripts
COPY . .

EXPOSE 5173

CMD ["deno", "task", "dev"]
