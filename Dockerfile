# 1. Use Node.js 20 LTS (Stable for network requests)
FROM node:20-slim

# 2. Install Git and Build Tools (Required for OpenClaw dependencies)
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    ca-certificates \
    --no-install-recommends && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 3. Install OpenClaw Globally
RUN npm install -g openclaw@latest

# 4. Set the working directory
WORKDIR /app

# 5. Environment Config
ENV OPENCLAW_HOME=/app/.openclaw
ENV OPENCLAW_DISABLE_BONJOUR=1

# 6. Startup Sequence (The same JSON injection idea)
CMD ["sh", "-c", "mkdir -p $OPENCLAW_HOME && \
    node -e \"const fs=require('fs'); const config={gateway:{port:process.env.PORT||7860,bind:'0.0.0.0',auth:{token:'growthops'}},channels:{telegram:{enabled:true,botToken:(process.env.TELEGRAM_BOT_TOKEN||'').trim(),authorizedUsers:[parseInt((process.env.MY_TELEGRAM_ID||'0').trim(), 10)]}},models:{providers:{google:{apiKey:(process.env.GEMINI_API_KEY||'').trim(),baseUrl:'https://generativelanguage.googleapis.com',models:[{id:'gemini-2.0-pro-exp-02-05',name:'Gemini 2.0 Pro'}]}}}}; fs.writeFileSync('$OPENCLAW_HOME/openclaw.json', JSON.stringify(config));\" && \
    openclaw gateway run --port ${PORT:-7860} --allow-unconfigured"]
